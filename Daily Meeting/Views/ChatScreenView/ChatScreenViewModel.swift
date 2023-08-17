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
    @Published var chatSettings: ChatSettings
    @Published var members: [UserSettings]
    @Published var chatResponse: String = ""
    @Published var userMessage: String = ""
    @Published var chatExpanded: Bool = false
    @Published var openVoiceRecognizer: Bool = false
    @Published var isSpeaking: Bool = false
    let router: RouterProtocol
    let persistence: ChatPersistenceProtocol
    let synthesizer: AVSpeechSynthesizer
    var voice: AVSpeechSynthesisVoice?
    
    init(users: [UserSettings], router: RouterProtocol, persistence: ChatPersistenceProtocol,
         synthesizer: AVSpeechSynthesizer) {
        self.userSettings = users.first(where: {$0.isBot == false}) ?? UserSettings(id: 9,
                                                                                    isBot: false,
                                                                                    userName: "User",
                                                                                    userRole: .mobile,
                                                                                    englishLevel: .advanced)
        self.chatSettings = persistence.loadSettings()
        self.members = users
        self.router = router
        self.persistence = persistence
        self.synthesizer = synthesizer
    }
    
    func readTextWithSpeech(_ text: String, isMale: Bool) {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord, mode: .default, options: .defaultToSpeaker)
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: isMale ? "en-GB" : "en-US")
        utterance.postUtteranceDelay = 0.005
        synthesizer.speak(utterance)
        imitateSpeaking(text: text, value: isSpeaking, completion: { self.isSpeaking = $0 })
        
        defer {
            disableAVSession()
        }
    }

    private func disableAVSession() {
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't disable.")
        }
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
    
    func getNameFrom(message: String) -> String {
        if let startIndex = message.firstIndex(of: "#"),
           let endIndex = message.lastIndex(of: "#"),
           startIndex < endIndex {
            let nameRange = message.index(after: startIndex)..<endIndex
            return String(message[nameRange])
        }   
        return ""
    }
    
}
