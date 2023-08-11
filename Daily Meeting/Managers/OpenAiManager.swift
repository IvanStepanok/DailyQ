//
//  OpenAiManager.swift
//  Daily Meeting
//
//  Created by  Stepanok Ivan on 02.08.2023.
//

import Foundation
import OpenAISwift
import Swinject

class OpenAiManager: ObservableObject {
//    static let apiKey = "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"
//    private var openAI = OpenAISwift(config: .makeDefaultOpenAI(apiKey: "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"))
    private var openAI: OpenAISwift
    @Published var chatHistory: [ChatMessage] = []
                                            
    let meeting: MeetingProtocol
    
    init(meeting: MeetingProtocol) {
        self.meeting = meeting
//#if DEBUG
//        self.openAI = OpenAISwift(authToken: "")
//#else
        self.openAI = Container.shared.resolve(OpenAISwift.self)!
//#endif
    }
    
    @MainActor
    func setupChat() async {
        let promt = await getPromt()
            chatHistory.append(promt)
    }
    
    func getPromt() async -> ChatMessage {
        let promt = await meeting.promt()
        return ChatMessage(role: .system, content: promt)
    }
    
    func generateWorkDescription() async -> String {
        let promt = """
A project to imitate work in an IT company.
You need to write a description of the project that the development team is working on. 100-200 characters.
Language: English.
"""
        do {
            let result = try await openAI.sendChat(with: [ChatMessage(role: .user, content: promt)], maxTokens: 100)
            return result.choices.first?.message.content ?? "Content creation error"
        } catch {
            print(">>>> 🤡", error.localizedDescription)
            return "Content creation error: \(error.localizedDescription)"
        }
    }
    
    func getFeedback() async -> String {
        let messages = chatHistory.filter({ $0.role == .user }).map { $0.content }.joined(separator: " \n ")
        
        let promt = """
I am studying English, tell me what mistakes I made in this text? \(messages). Your response in Ukrainian language.
"""
        print(">>>>>", promt)
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
        let userMessage = ChatMessage(role: .user, content: "#You# " + message)
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
            let result = try await openAI.sendChat(with: chatHistory)
            print("result ", result)
            guard let response = result.choices.first?.message else { return }
                self.chatHistory.append(response)
        } catch {
            print(">>>> 🤡", error.localizedDescription)
        }
    }
    
}

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
