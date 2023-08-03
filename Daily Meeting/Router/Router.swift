//
//  Router.swift
//  Daily Meeting
//
//  Created by  Stepanok Ivan on 04.08.2023.
//

import Foundation
import SwiftUI

class Router {
    
    private var navigationController: UINavigationController?
    
    init() {}
    
    func configureNavigationController() {
        if navigationController == nil {
            let vc = UIHostingController(rootView: ChatScreenView(router: self))
            navigationController = UINavigationController(rootViewController: vc)
            navigationController?.title = ""
            UIApplication.shared.windows.first?.rootViewController = navigationController
        }
    }
    
    func showSettingsView() {
        let vc = UIHostingController(rootView: SettingsView(viewModel: SettingsViewModel(router: self)))
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .coverVertical
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showUserSettingsView(userSettings: UserSettings) {
        let vc = UIHostingController(rootView: UserSettingsView(isUser: true,
                                                                viewModel: UserSettingsViewModel(userSettings: userSettings)) )
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .coverVertical
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
