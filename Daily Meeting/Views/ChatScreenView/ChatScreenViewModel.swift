//
//  ChatScreenViewModel.swift
//  Daily Meeting
//
//  Created by  Stepanok Ivan on 05.08.2023.
//

import Foundation
import SwiftUI
import Speech

class ChatScreenViewModel: ObservableObject {
    
    @Published var userSettings: UserSettings
    @Published var members: [UserSettings]
    @Published var chatResponse: String = ""
    @Published var userMessage: String = ""
    @Published var chatExpanded: Bool = false
    @Published var openVoiceRecognizer: Bool = false
    @Published var isSpeaking: Bool = false
    let router: RouterProtocol
    let persistence: ChatPersistenceProtocol
    let synthesizer = AVSpeechSynthesizer() // TODO: Hide to DI
    
    init(users: [UserSettings], router: RouterProtocol, persistence: ChatPersistenceProtocol) {
        self.userSettings = users.first(where: {$0.isBot == false}) ?? UserSettings(id: 9,
                                                                                    isBot: false,
                                                                                    userName: "User",
                                                                                    gender: .male,
                                                                                    userRole: .mobile,
                                                                                    englishLevel: .advanced)
        self.members = users
        self.router = router
        self.persistence = persistence
    }
    
    func readTextWithSpeech(_ text: String, gender: UserGender) {
        let voice: AVSpeechSynthesisVoice?
        
        switch gender {
        case .male:
            voice = AVSpeechSynthesisVoice(language: "en-US")
        case .female:
            voice = AVSpeechSynthesisVoice(language: "en-GB")
        }
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = AVSpeechUtteranceMaximumSpeechRate / 2.0
        utterance.voice = voice
        synthesizer.speak(utterance)
        imitateSpeaking(text: text, value: isSpeaking, completion: { self.isSpeaking = $0 })
    }
    
    func imitateSpeaking(text: String, value: Bool, completion: @escaping (Bool) -> Void) {
       let duration = estimateSpeechDuration(for: text)
        withAnimation {
            completion(true)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(duration ?? 0)) {
            withAnimation {
                completion(false)
            }
        }
    }
    
    func estimateSpeechDuration(for text: String) -> Int? {
        // You can adjust the average speaking rate as needed
        let averageSpeakingRate: Double = 150.0 // words per minute
        let wordsPerSecond = averageSpeakingRate / 60.0
        let wordCount = Double(text.split(separator: " ").count)
        let estimatedDuration = wordCount / wordsPerSecond
        return Int(estimatedDuration.rounded())
    }
    
}
