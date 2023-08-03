//
//  SettingsViewModel.swift
//  Daily Meeting
//
//  Created by  Stepanok Ivan on 03.08.2023.
//

import Foundation

class SettingsViewModel: ObservableObject {
    
    let router: Router

    @Published var users: [UserSettings] = [
        UserSettings(id: "0",
                     isBot: false,
                     userName: "Ivan Stepanok",
                     avatarName: "avatar_0",
                     gender: .male,
                     userRole: .teamLead,
                     englishLevel: .preIntermediate),
        UserSettings(id: "1",
                     isBot: true,
                     userName: "Igor Kondratuk",
                     avatarName: "avatar_5",
                     gender: .male,
                     userRole: .teamLead,
                     englishLevel: .preIntermediate),
        UserSettings(id: "2",
                     isBot: true,
                     userName: "Natalie Kovalengo",
                     avatarName: "avatar_4",
                     gender: .female,
                     userRole: .backend,
                     englishLevel: .preIntermediate),
        UserSettings(id: "3",
                     isBot: true,
                     userName: "Serhii Dorozhny",
                     avatarName: "avatar_11",
                     gender: .male,
                     userRole: .designer,
                     englishLevel: .preIntermediate)
    ]
    
    init(router: Router) {
        self.router = router
    }
}
