//
//  OpenAiManager.swift
//  Daily Meeting
//
//  Created by  Stepanok Ivan on 02.08.2023.
//

import Foundation
import OpenAISwift

class OpenAiManager: ObservableObject {
    static let apiKey = "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"
//    private var openAI = OpenAISwift(config: .makeDefaultOpenAI(apiKey: "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"))
    private var openAI = OpenAISwift(authToken: "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")
    
//    private let chatPreset = ChatMessage(role: .system, content: "")
                                        
    
    let persistence: ChatPersistenceProtocol
    
    init(persistence: ChatPersistenceProtocol) {
        self.persistence = persistence
    }
    
    @Published var chatHistory: [ChatMessage] = []
    
    func setupChat() {
        chatHistory.append(getPromt())
    }
    
    func getPromt() -> ChatMessage {
        let users = persistence.loadAllUsersSettings().sorted(by: { $0.id < $1.id })
        let agenda = persistence.loadSettings().agenda ?? "classical it company"
        let promt = """
 You are participating in a daily standup for an IT Company. Company description: \(agenda) My name is \(users[3].userName), my role is \(users[3].userRole) My level of English is \(users[3].englishLevel), please bear that in mind. We are at the morning rally. You play the role of \(users[0].userRole.rawValue), your name: \(users[0].userName), there is also a \(users[1].userRole) (name: \(users[1].userName) and a \(users[2].userRole.rawValue) (name: \(users[2].userName)) in the team. You can ask questions to the \(users[1].userName) or \(users[2].userName), but you almost must reply from their behalf immideatly. You start the morning stand-up as \(users[0].userRole). Each message should contain a question to the user \(users[3].userName), who acts as a \(users[3].userRole). Short answers from 1-2 sentence. All messages must start with name of author and be signed with characters # from whom it is (by name). For example #\(users[0].userName)#
"""
        return ChatMessage(role: .system, content: promt)
    }
    
    func generateWorkDescription() async -> String {
        let promt = """
A project to imitate work in an IT company.
You need to write a description of the project that the development team is working on. 300-400 characters.
Language: Ukrainian.
"""
        do {
            let result = try await openAI.sendChat(with: [ChatMessage(role: .user, content: promt)], maxTokens: 500)
            return result.choices.first?.message.content ?? "Content creation error"
        } catch {
            print(">>>> 🤡", error.localizedDescription)
            return "Content creation error: \(error.localizedDescription)"
        }
    }
    
    @MainActor
    func sendMessage(message: String) async {
        let userMessage = ChatMessage(role: .user, content: "You: " + message)
            self.chatHistory.append(userMessage)
        do {
//            openAI.sendCompletion(with: message) { result in
//                switch result {
//                   case .success(let success):
//                    print(success.choices?.first?.text ?? "")
//                   case .failure(let failure):
//                       print(failure.localizedDescription)
//                   }
//            }
            let result = try await openAI.sendChat(with: chatHistory, maxTokens: 300)
            
            guard let response = result.choices.first?.message else { return }
                self.chatHistory.append(response)
        } catch {
            print(">>>> 🤡", error.localizedDescription)
        }
    }
    
}

//extension ChatMessage: Hashable {
//    public static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
//        lhs.id == rhs.id &&
//        lhs.content == rhs.content
//    }
//    public func hash(into hasher: inout Hasher) {
//        hasher.combine(id)
//    }
//}

extension ChatMessage: Identifiable, Equatable {
    public var id: UUID {
        return UUID()
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    public static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        return lhs.id == rhs.id
    }
}
