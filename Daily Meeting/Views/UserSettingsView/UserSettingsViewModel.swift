//
//  UserSettingsViewModel.swift
//  Daily Meeting
//
//  Created by  Stepanok Ivan on 03.08.2023.
//

import Foundation

class UserSettingsViewModel: ObservableObject {
    
    @Published var userSettings: UserSettings
    
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
        "avatar_12"
    ]
    
    init(userSettings: UserSettings) {
        self.userSettings = userSettings
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
    }
    
    // Functions to update the user settings
       func updateUserName(_ name: String) {
           userSettings.userName = name
       }
       
       func updateAvatarName(_ avatarName: String?) {
           userSettings.avatarName = avatarName
       }
       
       func updateUserRole(_ role: UserRole) {
           userSettings.userRole = role
       }
       
       func updateEnglishLevel(_ level: EnglishLevel) {
           userSettings.englishLevel = level
       }
       
       func updateGender(_ gender: UserGender) {
           userSettings.gender = gender
       }
}
