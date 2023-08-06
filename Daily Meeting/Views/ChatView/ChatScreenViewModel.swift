//
//  ChatScreenViewModel.swift
//  Daily Meeting
//
//  Created by  Stepanok Ivan on 05.08.2023.
//

import Foundation

class ChatScreenViewModel: ObservableObject {
    
    @Published var userSettings: UserSettings
    @Published var members: [UserSettings]
    let router: RouterProtocol
    let persistence: ChatPersistenceProtocol
    
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
    
   
    
}
