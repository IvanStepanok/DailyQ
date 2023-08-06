//
//  Router.swift
//  Daily Meeting
//
//  Created by  Stepanok Ivan on 04.08.2023.
//

import Foundation
import SwiftUI
import Swinject

protocol RouterProtocol {
    func configureNavigationController()
    func showMeetingView(users: [UserSettings])
    func showSettingsView()
    func showUserSettingsView(userSettings: UserSettings, updatedUser: @escaping (UserSettings) -> Void)
}

class RouterMock: RouterProtocol {
    func configureNavigationController() {}
    func showMeetingView(users: [UserSettings]) {}
    func showSettingsView() {}
    func showUserSettingsView(userSettings: UserSettings, updatedUser: @escaping (UserSettings) -> Void) {}
}

class Router: RouterProtocol {
    
    private var navigationController: UINavigationController?
    private let persistence = Container.shared.resolve(ChatPersistenceProtocol.self)!
    private let openAI = Container.shared.resolve(OpenAiManager.self)!

    init() {}
    
    func configureNavigationController() {
        if navigationController == nil {
            let users = persistence.loadAllUsersSettings()
            if users.contains(where: {$0.isBot == false}) {
                let viewModel = ChatScreenViewModel(users: users, router: self, persistence: persistence)
                let vc = UIHostingController(rootView: ChatScreenView(viewModel: viewModel, openAI: openAI))
                navigationController = UINavigationController(rootViewController: vc)
                navigationController?.title = ""
                UIApplication.shared.windows.first?.rootViewController = navigationController
            } else {
                let viewModel = IntroViewModel(userSettings: UserSettings(id: 4,
                                                                          isBot: false,
                                                                          userName: "",
                                                                          gender: .female,
                                                                          userRole: .backend,
                                                                          englishLevel: .beginner),
                                               persistence: persistence,
                                               router: self,
                                               openAI: openAI)
                let vc = UIHostingController(rootView: IntroView(viewModel: viewModel))
                navigationController = UINavigationController(rootViewController: vc)
                navigationController?.title = ""
                UIApplication.shared.windows.first?.rootViewController = navigationController
            }
        }
    }
    
    func showMeetingView(users: [UserSettings]) {
        let viewModel = ChatScreenViewModel(users: users, router: self, persistence: persistence)
        let vc = UIHostingController(rootView: ChatScreenView(viewModel: viewModel, openAI: openAI))
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showSettingsView() {
        let users = persistence.loadAllUsersSettings()
        let vc = UIHostingController(rootView: SettingsView(viewModel: SettingsViewModel(users: users, router: self)))
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .coverVertical
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showUserSettingsView(userSettings: UserSettings, updatedUser: @escaping (UserSettings) -> Void) {
        let viewModel = UserSettingsViewModel(userSettings: userSettings,
                                              persistence: persistence,
                                              updatedUser: {updatedUser($0)})
        let vc = UIHostingController(rootView: UserSettingsView(isUser: true,
                                                                viewModel: viewModel))
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .coverVertical
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
