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
import Mixpanel
import RevenueCat
import QAHelper

protocol RouterProtocol {
    func configureNavigationController()
    func showMeetingView(meeting: MeetingProtocol)
    func startFirstMeeting()
    func showSettingsView()
    func showUserSettingsView(userSettings: UserSettings, updatedUser: @escaping (UserSettings) -> Void)
    func finishMeeting(meetingType: String, summary: String)
    func showPremiumView()
    func checkSubscriptionStatus(isPremium: @escaping (Bool) -> Void)
    func restorePurchases(isPremium: @escaping (Bool) -> Void)
    func getPremium(isYearAccess: Bool) async -> Bool
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
    func checkSubscriptionStatus(isPremium: @escaping (Bool) -> Void) {}
    func restorePurchases(isPremium: @escaping (Bool) -> Void) {}
    func getPremium(isYearAccess: Bool) async -> Bool { true }
    func dismiss(animated: Bool) {}
    func back(animated: Bool) {}
}

class Router: RouterProtocol {
    
    private var navigationController: UINavigationController?
    private let persistence = Container.shared.resolve(ChatPersistenceProtocol.self)!
    private let openAI = Container.shared.resolve(OpenAISwift.self)!
    private let synthesizer = AVSpeechSynthesizer()
    
    init() {}
    
    private func updatePremiumState(isPremium: Bool) {
        var settings = self.persistence.loadSettings()
        settings.isPremium = isPremium
        let saveSettings = settings
        Task {
           await self.persistence.saveSettings(saveSettings)
        }
    }
    
    func checkSubscriptionStatus(isPremium: @escaping (Bool) -> Void) {
        Purchases.shared.getCustomerInfo { [weak self] customerInfo, error in
            guard let self else { return }
            if let customerInfo {
                QA.Print(customerInfo.description)
                if customerInfo.entitlements["Pro"]?.isActive == true {
                    self.updatePremiumState(isPremium: true)
                    isPremium(true)
                } else {
                    self.updatePremiumState(isPremium: false)
                    isPremium(false)
                }
            }
        }
    }
    
    func restorePurchases(isPremium: @escaping (Bool) -> Void) {
        Purchases.shared.restorePurchases { [weak self] customerInfo, error in
            guard let self else { return }
            if let customerInfo {
                QA.Print(customerInfo.description)
                if customerInfo.entitlements["Pro"]?.isActive == true {
                    self.updatePremiumState(isPremium: true)
                    isPremium(true)
                } else {
                    self.updatePremiumState(isPremium: false)
                    isPremium(false)
                }
            }
        }
    }
    
    func getPremium(isYearAccess: Bool) async -> Bool {
        do {
            let offerings = try await Purchases.shared.offerings()
            QA.Print(offerings.current?.description ?? "")
            print(">>>", offerings)
            if let packages = offerings.current?.availablePackages {
                let result = try await Purchases.shared.purchase(package: isYearAccess ? packages[1] : packages[0])
                if result.customerInfo.entitlements["Pro"]?.isActive == true {
                    updatePremiumState(isPremium: true)
                    return true
                } else {
                    updatePremiumState(isPremium: false)
                    return false
                }
            } else {
                return false
            }
        } catch {
            QA.Print(error.localizedDescription)
            print(">>>>> ⛔️ checkPremium Error: ", error.localizedDescription)
            updatePremiumState(isPremium: false)
            return false
        }
    }
    
    func configureNavigationController() {
        if navigationController == nil {
            checkSubscriptionStatus(isPremium: {_ in})
            let users = persistence.loadAllUsersSettings()
            let settings = persistence.loadSettings()
            if let curentUser = users.first(where: {$0.isBot == false}) {
                
                Mixpanel.mainInstance().track(event: "Start App", properties: [
                    "userName": curentUser.userName,
                    "englishLevel": curentUser.englishLevel.rawValue,
                    "userRole": curentUser.userRole.rawValue,
                    "companyDetails": settings.companyDetails,
                    "userStackDescription": settings.userStackDescription,
                    "isPremium": settings.isPremium,
                    "bgImageIndex": settings.bgImageIndex,
                    "dailyMeetingsCompleted": settings.dailyMeetingsCompleted,
                    "salaryReviewsCompleted": settings.salaryReviewsCompleted,
                    "techInterviewsCompleted": settings.techInterviewsCompleted,
                    "voiceOver": settings.voiceOver
                ])
                
                let viewModel = MainViewModel(persistence: self.persistence, router: self, openAI: self.openAI)
                let vc = UIHostingController(rootView: MainView(viewModel: viewModel))
                navigationController = UINavigationController(rootViewController: vc)
                navigationController?.title = ""
                UIApplication.shared.windows.first?.rootViewController = navigationController
            } else {
                Mixpanel.mainInstance().track(event: "First start")
                
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
        Mixpanel.mainInstance().track(event: "showPremiumView")
        let vc = UIHostingController(rootView: PremiumView(router: self, persistence: persistence))
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .coverVertical
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func finishMeeting(meetingType: String, summary: String) {
        Mixpanel.mainInstance().track(event: "finishMeeting", properties: [
            "meetingType": meetingType,
            "summary": summary
        ])

        let vc = UIHostingController(rootView: MeetingCompleted(meetingType: meetingType,
                                                                summary: summary,
                                                                persistence: self.persistence,
                                                                router: self))
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .coverVertical
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showMeetingView(meeting: MeetingProtocol) {
        Mixpanel.mainInstance().track(event: "showMeetingView", properties: [
            "meetingType": meeting.meetingName
        ])
        let openAImanager = OpenAiManager(meeting: meeting)
        let members = openAImanager.meeting.members
        let viewModel = ChatScreenViewModel(users: members, router: self, persistence: persistence, synthesizer: synthesizer)
        let vc = UIHostingController(rootView: ChatScreenView(viewModel: viewModel, openAI: openAImanager))
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func startFirstMeeting() {
        Mixpanel.mainInstance().track(event: "startFirstMeeting")
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
        if users.count >= 4 {
            Mixpanel.mainInstance().track(event: "showSettingsView", properties: [
                "user0userName":   users[0].userName,
                "user0userRole":   users[0].userRole.rawValue,
                "user0avatarName": users[0].avatarName,
                "user1userName":   users[1].userName,
                "user1userRole":   users[1].userRole.rawValue,
                "user1avatarName": users[1].avatarName,
                "user2userName":   users[2].userName,
                "user2userRole":   users[2].userRole.rawValue,
                "user2avatarName": users[2].avatarName,
                "user3userName":   users[3].userName,
                "user3userRole":   users[3].userRole.rawValue,
                "user3avatarName": users[3].avatarName
            ])
        }

        let vc = UIHostingController(rootView: SettingsView(viewModel: SettingsViewModel(users: users,
                                                                                         router: self,
                                                                                         persistence: persistence)))
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .coverVertical
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showUserSettingsView(userSettings: UserSettings, updatedUser: @escaping (UserSettings) -> Void) {
        Mixpanel.mainInstance().track(event: "showUserSettingsView", properties: [
            "userName": userSettings.userName,
            "avatarName": userSettings.avatarName,
            "userRole": userSettings.userRole.rawValue,
            "isBot": userSettings.isBot
        ])
        let viewModel = UserSettingsViewModel(userSettings: userSettings,
                                              persistence: persistence,
                                              updatedUser: {updatedUser($0)})
        let vc = UIHostingController(rootView: UserSettingsView(isUser: !userSettings.isBot,
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
