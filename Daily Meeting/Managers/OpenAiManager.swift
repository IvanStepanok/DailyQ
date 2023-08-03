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
    
    private let chatPreset = ChatMessage(role: .system, content: "I want to practice English. My level of English is \"pre-intermediate\". We are at the morning rally. Our team is developing a mobile application. You play the role of Tim Lead, there is also a designer and a back-end developer in the team. You cannot ask questions to the designer or back-end developer, but you can answer on their behalf. You start the morning stand-up as Tim Lead. Each message should contain a question to the user Ivan, who acts as a front-end developer. Short answers from 1 sentence. The beginning of each message must be signed from whom it is. For example Teamlead: Message")
    
    @Published var chatHistory: [ChatMessage] = []
    
    func setupChat() {
        chatHistory.append(chatPreset)
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
            let result = try await openAI.sendChat(with: chatHistory, maxTokens: 150)
            
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
