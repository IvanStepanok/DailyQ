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
                                avatarName: "director",
                                gender: .male,
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
                                                               gender: .female,
                                                               userRole: .frontend,
                                                               englishLevel: .advanced)]
        self.companyDetails = persistence.loadSettings().companyDetails
        ?? "classical it company"
    }
    
    func promt() async -> String {
        
        
        let user = members.first(where: { $0.isBot == false })!
        
        return """
                My name is \(user.userName), i am a \(user.userRole). You are is \(teamLead.userName) and you are is \(teamLead.userRole) of famous IT Company. This conversation is an technical interview for a iOS developer (SwiftUI) at Junior position. Ask 2 short technical questions, one question by time, about this role. Each of your messages consists of a maximum of 100-300 characters. Before write a message you write your name like this: #\(teamLead.userName)#. After finishing take a quick review, and say interview #passed# or #failed#.
                """
    }
}
