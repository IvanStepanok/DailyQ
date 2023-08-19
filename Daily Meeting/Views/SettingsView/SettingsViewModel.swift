//
//  SettingsViewModel.swift
//  Daily Meeting
//
//  Created by  Stepanok Ivan on 03.08.2023.
//

import Foundation
import UIKit

class SettingsViewModel: ObservableObject {
    
    let router: RouterProtocol
    let persistence: ChatPersistenceProtocol
    var chatSettings: ChatSettings

    @Published var users: [UserSettings]
    @Published var userStackDescription = ""
    @Published var projectDescription = ""
    @Published var voiceOverOn: Bool
    
    init(users: [UserSettings], router: RouterProtocol, persistence: ChatPersistenceProtocol) {
        self.users = users
        self.router = router
        self.persistence = persistence
        self.chatSettings = persistence.loadSettings()
        self.userStackDescription = self.chatSettings.userStackDescription ?? ""
        self.projectDescription = self.chatSettings.companyDetails ?? ""
        self.voiceOverOn = self.chatSettings.voiceOver
    }
    
    func saveSetting() {
        Task {
            self.chatSettings.userStackDescription = self.userStackDescription
            self.chatSettings.companyDetails = self.projectDescription
            self.chatSettings.voiceOver = self.voiceOverOn
            await persistence.saveSettings(self.chatSettings)
        }
    }
    
    func contactSupport() -> URL? {
        let osVersion = UIDevice.current.systemVersion
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let deviceModel = UIDevice.current.model
        let feedbackDetails = "OS version: \(osVersion)\nApp version: \(appVersion)\nDevice model: \(deviceModel)"
        
        let recipientAddress = "stepanokdev@gmail.com"
        let emailSubject = "Feedback"
        let emailBody = "\n\n\(feedbackDetails)\n".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let emailURL = URL(string: "mailto:\(recipientAddress)?subject=\(emailSubject)&body=\(emailBody)")
        return emailURL
    }
}
