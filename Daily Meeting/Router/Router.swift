//
//  Router.swift
//  Daily Meeting
//
//  Created by  Stepanok Ivan on 04.08.2023.
//

import Foundation
import SwiftUI
import Swinject
import OpenAISwift
import Speech

protocol RouterProtocol {
    func configureNavigationController()
    func showMeetingView(meeting: MeetingProtocol)
    func startFirstMeeting()
    func showSettingsView()
    func showUserSettingsView(userSettings: UserSettings, updatedUser: @escaping (UserSettings) -> Void)
    func finishMeeting(meetingType: String, summary: String)
    func showPremiumView()
    func dismiss(animated: Bool)
    func back(animated: Bool)
}

class RouterMock: RouterProtocol {
    func configureNavigationController() {}
    func showMeetingView(meeting: MeetingProtocol) {}
    func startFirstMeeting() {}
    func showSettingsView() {}
    func showUserSettingsView(userSettings: UserSettings, updatedUser: @escaping (UserSettings) -> Void) {}
    func finishMeeting(meetingType: String, summary: String) {}
    func showPremiumView() {}
    func dismiss(animated: Bool) {}
    func back(animated: Bool) {}
}

class Router: RouterProtocol {
    
    private var navigationController: UINavigationController?
    private let persistence = Container.shared.resolve(ChatPersistenceProtocol.self)!
    private let openAI = Container.shared.resolve(OpenAISwift.self)!
    private let synthesizer = AVSpeechSynthesizer()
    
    init() {}
    
    func configureNavigationController() {
        if navigationController == nil {
            let users = persistence.loadAllUsersSettings()
            if users.contains(where: {$0.isBot == false}) {
                let viewModel = MainViewModel(persistence: self.persistence, router: self, openAI: self.openAI)
                let vc = UIHostingController(rootView: MainView(viewModel: viewModel))
                navigationController = UINavigationController(rootViewController: vc)
                navigationController?.title = ""
                UIApplication.shared.windows.first?.rootViewController = navigationController
            } else {
                let openAImanager = OpenAiManager(
                    meeting:
                        DailyMeeting(
                            persistence: persistence,
                            openAI: self.openAI
                        )
                )
               
                let viewModel = IntroViewModel(
                    userSettings:
                        UserSettings(
                            id: 4,
                            isBot: false,
                            userName: "",
                            gender: .female,
                            userRole: .backend,
                            englishLevel: .beginner),
                    persistence: persistence,
                    router: self,
                    openAI: openAImanager)
                let vc = UIHostingController(rootView: IntroView(viewModel: viewModel))
                navigationController = UINavigationController(rootViewController: vc)
                navigationController?.title = ""
                UIApplication.shared.windows.first?.rootViewController = navigationController
            }
        }
    }
    
    func showPremiumView() {
        let vc = UIHostingController(rootView: PremiumView(router: self, persistence: persistence))
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .coverVertical
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func finishMeeting(meetingType: String, summary: String) {
        let vc = UIHostingController(rootView: MeetingCompleted(meetingType: meetingType,
                                                                summary: summary,
                                                                persistence: self.persistence,
                                                                router: self))
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .coverVertical
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showMeetingView(meeting: MeetingProtocol) {
        let openAImanager = OpenAiManager(meeting: meeting)
        let members = openAImanager.meeting.members
        let viewModel = ChatScreenViewModel(users: members, router: self, persistence: persistence, synthesizer: synthesizer)
        let vc = UIHostingController(rootView: ChatScreenView(viewModel: viewModel, openAI: openAImanager))
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func startFirstMeeting() {
        let openAImanager = OpenAiManager(meeting: DailyMeeting(persistence: self.persistence, openAI: self.openAI))
        let members = openAImanager.meeting.members
        
        let mainViewModel = MainViewModel(persistence: self.persistence, router: self, openAI: self.openAI)
        let mainVC = UIHostingController(rootView: MainView(viewModel: mainViewModel))
        
        let chatViewModel = ChatScreenViewModel(users: members, router: self, persistence: persistence, synthesizer: synthesizer)
        let chatView = UIHostingController(rootView: ChatScreenView(viewModel: chatViewModel, openAI: openAImanager))
        guard var controllers = navigationController?.viewControllers else { return }
        controllers.removeLast(1)
        controllers.append(contentsOf: [mainVC, chatView])
        navigationController?.setViewControllers(controllers, animated: true)
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
    
    func dismiss(animated: Bool = true) {
        self.navigationController?.dismiss(animated: animated)
    }
    
    func back(animated: Bool = true) {
        self.navigationController?.popViewController(animated: animated)
    }
}
