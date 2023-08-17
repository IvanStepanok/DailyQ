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
        "avatar-1",
        "avatar-2",
        "avatar-3",
        "avatar-4",
        "avatar-5",
        "avatar-6",
        "avatar-7",
        "avatar-8",
        "avatar-9",
        "avatar-10",
        "avatar-11",
        "avatar-12",
        "avatar-13",
        "avatar-14",
        "avatar-15",
        "avatar-16",
        "avatar-17",
        "avatar-18",
        "avatar-19",
        "avatar-20",
        "avatar-21",
        "avatar-22"
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
            "Alexander Hartman",
            "Benjamin Archer",
            "Caleb Sinclair",
            "Dominic Bennett",
            "Elijah Harrington",
            "Finnegan Monroe",
            "Gabriel Callahan",
            "Harrison Prescott",
            "Isaac Thorne",
            "Jasper Montgomery",
            "Amelia Langley",
            "Bella Harrington",
            "Charlotte Donovan",
            "Daphne Kensington",
            "Eleanor Sinclair",
            "Fiona Caldwell",
            "Grace Thornton",
            "Harper Kensington",
            "Isabella Ramsey",
            "Juliette Carmichael"
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
}
