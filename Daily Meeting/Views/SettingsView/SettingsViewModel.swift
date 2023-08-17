//
//  SettingsViewModel.swift
//  Daily Meeting
//
//  Created by  Stepanok Ivan on 03.08.2023.
//

import Foundation

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
            DispatchQueue.main.async {
                self.router.back(animated: true)
            }
        }
    }
}
