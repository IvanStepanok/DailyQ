//
//  OpenAiManager.swift
//  Daily Meeting
//
//  Created by  Stepanok Ivan on 02.08.2023.
//

import Foundation
import OpenAISwift
import Swinject
import Mixpanel
import QAHelper

class OpenAiManager: ObservableObject {
//    static let apiKey = "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"
//    private var openAI = OpenAISwift(config: .makeDefaultOpenAI(apiKey: "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"))
    private var openAI: OpenAISwift
    @Published var chatHistory: [ChatMessage] = []
    @Published var isLoading: Bool = false
    private var oneTry: Bool = false
                                            
    var meeting: MeetingProtocol
    
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
        Mixpanel.mainInstance().track(event: "ChatStart", properties: ["meetingName": meeting.meetingName])
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
        isLoading = true
        do {
            let result = try await openAI.sendChat(with: [ChatMessage(role: .user, content: promt)], maxTokens: 100)
            DispatchQueue.main.async {
                self.isLoading = false
            }
            return result.choices.first?.message.content ?? "Content creation error"
        } catch {
            print(">>>> 🤡", error.localizedDescription)
            return "Content creation error: \(error.localizedDescription)"
        }
    }
    
    func getFeedback() async -> String {
        let messages = chatHistory.filter({ $0.role == .user }).enumerated().map { index, message in
            if index != 0 {
               return "\(index)) " + message.content.removeUsernameAndHashtags()
            } else {
                return ""
            }
        }.joined(separator: " \n \n")
        
        let promt = Localized("feedbackPromt") + messages
        QA.Print(">>>> promt getFeedback() \(promt)")
        
        do {
            let result = try await openAI.sendChat(with: [ChatMessage(role: .assistant, content: promt), ChatMessage(role: .user, content: " ")])
            print(result)
            QA.Print(result.choices.first?.message.content)
            return result.choices.first?.message.content ?? "Content creation error"
        } catch {
            print(">>>> 🤡", error.localizedDescription)
            return "Content creation error: \(error.localizedDescription)"
        }
    }
    
    @MainActor
    func sendMessage(message: String) async {
        isLoading = true
        let userMessage = ChatMessage(role: .user, content: "#You# " + message)
            self.chatHistory.append(userMessage)
        do {
            let result = try await openAI.sendChat(with: chatHistory, maxTokens: 200)
            guard let response = result.choices.first?.message else { return }
            QA.Print(">>>> response openAI() \(response.content)")
            if !oneTry {
                if response.content.count < 300 {
                    DispatchQueue.main.async {
                        self.chatHistory.append(response)
                        self.isLoading = false
                    }
                } else {
                    oneTry = true
                    await sendMessage(message: message)
                }
            } else {
                DispatchQueue.main.async {
                    self.chatHistory.append(response)
                    self.isLoading = false
                }
            }
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
