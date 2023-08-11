//
//  IntroViewModel.swift
//  Daily Meeting
//
//  Created by  Stepanok Ivan on 05.08.2023.
//

import SwiftUI

class IntroViewModel: ObservableObject {
    
    let persistence: ChatPersistenceProtocol
    let router: RouterProtocol
    let openAI: OpenAiManager
    
    @Published var userSettings: UserSettings
    @Published var teamSettings: [UserSettings] = []
    
    let nameMessages: [String] = [
        "Привіт",
        "",
        "Перед початком першого мітінгу",
        "",
        "щоб все виглядало більш реалістично",
        "",
        "зробимо деякі налаштування.",
        "", ""
    ]
    
    let roleMessages: [String] = [
        "",
        "Фантастично!",
        "",
        "І ще декілька питань",
        "", ""
    ]
    
    let englishMessages: [String] = [
        ""
    ]
    
    let membersMessages: [String] = [
        "",
        "І останнє",
        "",
        "Давайте налаштуємо вашу команду",
        "", ""
    ]
    
    
    @Published var currentMessagesIndex = 0
    
    let speed: Double = 2
    
    var allMessages: [[String]] = [[]]
    
    @Published var index: Int = 0
    @Published var showNameInput: Bool = false
    @Published var showUserRole: Bool = false
    @Published var showEnglish: Bool = false
    @Published var showWorkDescription: Bool = false
    @Published var showMembers: Bool = false
    @Published var animation: Bool = false
    @Published var workDescription: String = ""
    @Published var isLoading: Bool = false
    
    init(userSettings: UserSettings,
         persistence: ChatPersistenceProtocol,
         router: RouterProtocol,
         openAI: OpenAiManager) {
        self.userSettings = userSettings
        self.persistence = persistence
        self.router = router
        self.openAI = openAI
        allMessages = [nameMessages, roleMessages, englishMessages, membersMessages]
        generateWorkDescription()
    }
    
    func generateWorkDescription() {
        Task(priority: .userInitiated) {
            DispatchQueue.main.async {
                    self.isLoading = true
                self.workDescription = ""
            }
            let description = await openAI.generateWorkDescription()
            var userSettings = persistence.loadSettings()
            DispatchQueue.main.async {
                withAnimation {
                    self.isLoading = false
                }
                self.workDescription = description
            }
            userSettings.companyDetails = description
            await persistence.saveSettings(userSettings)
        }
    }
    
    func nameMessage() {
        var timer: Timer?
        timer = Timer.scheduledTimer(withTimeInterval: speed, repeats: true) { [weak self] timer in
            guard let self else { return }
            withAnimation(.linear(duration: self.nameMessages[self.index] == "" ? 0.5 : (speed / 1.5))) {
                self.index = (self.index + 1) % self.nameMessages.count
                if self.index == self.nameMessages.count - 1 {
                    self.showNameInput = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation {
                            self.animation = true
                        }
                    }
                    timer.invalidate() // Остановить таймер после первого выполнения
                }
            }
        }
    }
    
    func roleMessage() {
        var timer: Timer?
        timer = Timer.scheduledTimer(withTimeInterval: speed, repeats: true) { [weak self] timer in
            guard let self else { return }
            withAnimation(.linear(duration: self.roleMessages[self.index] == "" ? 0.5 : (speed / 1.5))) {
                self.index = (self.index + 1) % self.roleMessages.count
                if self.index == self.roleMessages.count - 1 {
                    self.showUserRole = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation {
                            self.animation = true
                        }
                    }
                    timer.invalidate() // Остановить таймер после первого выполнения
                }
            }
        }
    }
    
    func englishMessage() {
        var timer: Timer?
        timer = Timer.scheduledTimer(withTimeInterval: speed, repeats: true) { [weak self] timer in
            guard let self else { return }
            withAnimation(.linear(duration: self.englishMessages[self.index] == "" ? 0.5 : (speed / 1.5))) {
                self.index = (self.index + 1) % self.englishMessages.count
                if self.index == self.englishMessages.count - 1 {
                    self.showEnglish = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation {
                            self.animation = true
                        }
                    }
                    timer.invalidate() // Остановить таймер после первого выполнения
                }
            }
        }
    }
    
    func membersMessage() {
        var timer: Timer?
        timer = Timer.scheduledTimer(withTimeInterval: speed, repeats: true) { [weak self] timer in
            guard let self else { return }
            withAnimation(.linear(duration: self.membersMessages[self.index] == "" ? 0.5 : (speed / 1.5))) {
                self.index = (self.index + 1) % self.membersMessages.count
                if self.index == self.membersMessages.count - 1 {
                    self.showMembers = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation {
                            self.animation = true
                        }
                    }
                    timer.invalidate() // Остановить таймер после первого выполнения
                }
            }
        }
    }
    
    func saveUser() {
        Task {
           await persistence.saveUserSettings(settings: userSettings)
        }
        teamSettings = persistence.loadAllUsersSettings()
        teamSettings.append(userSettings)
    }
    
    func saveCompanyDetails() {
        var userSettings = persistence.loadSettings()
        userSettings.companyDetails = workDescription
        let settings = userSettings
        Task {
           await persistence.saveSettings(settings)
        }
    }
}
