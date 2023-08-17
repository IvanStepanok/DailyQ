//
//  TechInterview.swift
//  Daily Meeting
//
//  Created by  Stepanok Ivan on 10.08.2023.
//

import Foundation
import OpenAISwift

class TechInterview: MeetingProtocol {
    
    var tasks: String?
    
    let persistence: ChatPersistenceProtocol
    let openAI: OpenAISwift
    let companyDetails: String
    let members: [UserSettings]
    var meetingName: String = "Tech Interview"
    
    let teamLead = UserSettings(id: 0,
                                isBot: true,
                                userName: "Steve Gates",
                                avatarName: "avatar-3",
                                userRole: .teamLead,
                                englishLevel: .advanced)
    
    init(persistence: ChatPersistenceProtocol,
         openAI: OpenAISwift) {
        self.persistence = persistence
        self.openAI = openAI
        
        self.members = [ teamLead,
            persistence.loadAllUsersSettings()
            .first(where: {$0.isBot == false}) ?? UserSettings(id: 3,
                                                               isBot: false,
                                                               userName: "User",
                                                               userRole: .frontend,
                                                               englishLevel: .advanced)]
        self.companyDetails = persistence.loadSettings().companyDetails
        ?? "classical it company"
    }
    
    func promt() async -> String {
        
        
        let user = members.first(where: { $0.isBot == false })!
        
        let userStackDescription = persistence.loadSettings().userStackDescription ?? "Ask \(user.userName) about their tech stack and technologies in use."
        
        return """
                My name is \(user.userName), i am a \(user.userRole). You are is \(teamLead.userName) and you are is \(teamLead.userRole) of famous IT Company. This conversation is an technical interview. Information about my skills: \(userStackDescription). You can inquire about my experience and the technologies I have used, if necessary. Ask 10 short technical questions, one question by time, about this role. Each of your messages consists of a maximum of 100-300 characters. Before write a message you write your name like this: #\(teamLead.userName)#. After finishing take a quick review, and say interview passed or failed.
                """
    }
    
    func meetingFinishedSuccessfull() {
        Task {
            var settings = persistence.loadSettings()
            settings.techInterviewsCompleted += 1
            await persistence.saveSettings(settings)
        }
    }
}
