//
//  SettingsViewModel.swift
//  Daily Meeting
//
//  Created by  Stepanok Ivan on 03.08.2023.
//

import Foundation

class SettingsViewModel: ObservableObject {
    
    let router: RouterProtocol

    @Published var users: [UserSettings]
    
    init(users: [UserSettings], router: RouterProtocol) {
        self.users = users
        self.router = router
    }
}
