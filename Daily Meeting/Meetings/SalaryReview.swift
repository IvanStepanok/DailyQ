//
//  SalaryReview.swift
//  Daily Meeting
//
//  Created by  Stepanok Ivan on 10.08.2023.
//

import Foundation
import OpenAISwift

class SalaryReview: MeetingProtocol {
    var tasks: String?
    
    let persistence: ChatPersistenceProtocol
    let openAI: OpenAISwift
    let companyDetails: String
    let members: [UserSettings]
    var meetingName: String = "Salary and Perfomance Review"
    
    let hr = UserSettings(id: 0,
                          isBot: true,
                          userName: "Amanda Jobson",
                          avatarName: "avatar_4",
                          gender: .male,
                          userRole: .humanResourse,
                          englishLevel: .advanced)
    
    init(persistence: ChatPersistenceProtocol,
         openAI: OpenAISwift) {
        self.persistence = persistence
        self.openAI = openAI
        
        self.members = [
            hr,
            persistence.loadAllUsersSettings()
                .first(where: {$0.isBot == false}) ?? UserSettings(id: 3,
                                                                   isBot: false,
                                                                   userName: "User",
                                                                   gender: .female,
                                                                   userRole: .frontend,
                                                                   englishLevel: .advanced)
        ]
        self.companyDetails = persistence.loadSettings().companyDetails
        ?? "classical it company"
    }
    
    func promt() async -> String {
        
        
        let user = members.first(where: { $0.isBot == false })!
        
        return """
                My name is \(user.userName), i am a \(user.userRole). You are is \(hr.userName) and you are is \(hr.userRole) of famous IT Company. This conversation is a perfomance and salary review. Before write a message you write your name like this: #\(hr.userName)#. Each of your messages consists of a maximum of 100-300 characters. After finishing take a quick review, and say interview #passed# or #failed#.
                """
    }
}
