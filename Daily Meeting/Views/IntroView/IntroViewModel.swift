//
//  IntroViewModel.swift
//  Daily Meeting
//
//  Created by  Stepanok Ivan on 05.08.2023.
//

import SwiftUI
import Mixpanel

class IntroViewModel: ObservableObject {
    
    let persistence: ChatPersistenceProtocol
    let router: RouterProtocol
    let openAI: OpenAiManager
    
    @Published var userSettings: UserSettings
    @Published var teamSettings: [UserSettings] = []
    
    let nameMessages: [String] = [
        Localized("nameMessage1"),
        "",
        Localized("nameMessage2"),
        "",
        Localized("nameMessage3"),
        "",
        Localized("nameMessage4"),
        "", ""
    ]
    
    let roleMessages: [String] = [
        "",
        Localized("roleMessage1"),
        "",
        Localized("roleMessage2"),
        "", ""
    ]
    
    let englishMessages: [String] = [
        ""
    ]
    
    let userStackMessages: [String] = [
        ""
    ]
    
    let membersMessages: [String] = [
        "",
        Localized("membersMessage1"),
        "",
        Localized("membersMessage2"),
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
    @Published var showUserStackDescription: Bool = false
    @Published var showMembers: Bool = false
    @Published var animation: Bool = false
    @Published var workDescription: String = ""
    @Published var userStackDescription: String = ""
    @Published var isLoading: Bool = false
    
    init(userSettings: UserSettings,
         persistence: ChatPersistenceProtocol,
         router: RouterProtocol,
         openAI: OpenAiManager) {
        self.userSettings = userSettings
        self.persistence = persistence
        self.router = router
        self.openAI = openAI
        allMessages = [nameMessages, roleMessages, userStackMessages, englishMessages, membersMessages]
        generateWorkDescription()
    }
    
    func userStackDescriptionExample() -> String {
        switch userSettings.userRole {
        case .teamLead:
            return "Experienced in leading cross-functional teams, project management, and technical decision-making. Proficient in a variety of technologies across both frontend and backend."
        case .designer:
            return "Skilled in UI/UX design, wireframing, and prototyping using tools like Adobe Creative Suite and Figma. Familiar with design principles and user-centered design practices."
        case .mobile:
            return "Proficient in mobile app development using platforms like iOS (Swift) or Android (Kotlin/Java). Familiar with mobile UI/UX patterns, RESTful APIs, and version control (Git)."
        case .qa:
            return "Strong expertise in software testing methodologies, writing test plans, and automated testing using tools like Selenium or JUnit. Skilled in identifying and reporting bugs, and collaborating closely with development teams."
        case .frontend:
            return "Proficient in building responsive and interactive user interfaces using HTML, CSS, and JavaScript frameworks like React or Vue.js. Knowledgeable about cross-browser compatibility and performance optimization."
        case .backend:
            return "Skilled in server-side programming languages like Python, Java, or Node.js. Experienced with database management (SQL/NoSQL), API development, and cloud services such as AWS or Azure"
        case .humanResourse:
            return "Proficient in talent acquisition, recruitment strategies, and HR processes. Strong communication skills, understanding of organizational culture, and ability to foster a positive work environment"
        }
    }
    
    func trackFirstStartFinished() {
        var settings = persistence.loadSettings()
        Mixpanel.mainInstance().track(event: "First start finished", properties: [
            "userName": userSettings.userName,
            "englishLevel": userSettings.englishLevel.rawValue,
            "userRole": userSettings.userRole.rawValue,
            "companyDetails": settings.companyDetails,
            "userStackDescription": settings.userStackDescription
        ])
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
        let timer = Timer.scheduledTimer(withTimeInterval: speed, repeats: true) { [weak self] timer in
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
        let timer = Timer.scheduledTimer(withTimeInterval: speed, repeats: true) { [weak self] timer in
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
    
    func userStackMessage() {
        let timer = Timer.scheduledTimer(withTimeInterval: speed, repeats: true) { [weak self] timer in
            guard let self else { return }
            withAnimation(.linear(duration: self.userStackMessages[self.index] == "" ? 0.5 : (speed / 1.5))) {
                self.index = (self.index + 1) % self.userStackMessages.count
                if self.index == self.userStackMessages.count - 1 {
                    self.showUserStackDescription = true
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
        let timer = Timer.scheduledTimer(withTimeInterval: speed, repeats: true) { [weak self] timer in
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
        let timer = Timer.scheduledTimer(withTimeInterval: speed, repeats: true) { [weak self] timer in
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
    
    func saveUserStackDetails() {
        var userSettings = persistence.loadSettings()
        userSettings.userStackDescription = userStackDescription
        let settings = userSettings
        Task {
           await persistence.saveSettings(settings)
        }
    }
}
