//
//  UserSettingsViewModel.swift
//  Daily Meeting
//
//  Created by  Stepanok Ivan on 03.08.2023.
//

import Foundation

class UserSettingsViewModel: ObservableObject {
    
    @Published var userSettings: UserSettings
    let persistence: ChatPersistenceProtocol
    
    let avatars: [String] = [
        "avatar_0",
        "avatar_1",
        "avatar_2",
        "avatar_3",
        "avatar_4",
        "avatar_5",
        "avatar_6",
        "avatar_7",
        "avatar_8",
        "avatar_9",
        "avatar_10",
        "avatar_11",
        "avatar_12",
        "avatar_13",
        "avatar_14",
        "avatar_15",
        "avatar_16"
    ]
    
    var updatedUser: (UserSettings) -> Void
    
    init(userSettings: UserSettings, persistence: ChatPersistenceProtocol, updatedUser: @escaping (UserSettings) -> Void) {
        self.userSettings = userSettings
        self.persistence = persistence
        self.updatedUser = updatedUser
    }

    func randomName() {
        userSettings.userName =
        [
            "Emma Johnson",
            "Daniel Williams",
            "Sophia Martinez",
            "Ethan Thompson",
            "Olivia Davis",
            "Benjamin Garcia",
            "Ava Anderson",
            "William Rodriguez"
        ].randomElement()!
        
        updateUserName(userSettings.userName)
    }
    
    private func saveSetting() {
        Task {
           await persistence.saveUserSettings(settings: userSettings)
        }
        updatedUser(userSettings)
    }
    
    // Functions to update the user settings
       func updateUserName(_ name: String) {
           userSettings.userName = name
           saveSetting()
       }
       
       func updateAvatarName(_ avatarName: String?) {
           userSettings.avatarName = avatarName
           saveSetting()
       }
       
       func updateUserRole(_ role: UserRole) {
           userSettings.userRole = role
           saveSetting()
       }
       
       func updateEnglishLevel(_ level: EnglishLevel) {
           userSettings.englishLevel = level
           saveSetting()
       }
       
       func updateGender(_ gender: UserGender) {
           userSettings.gender = gender
           saveSetting()
       }
}
