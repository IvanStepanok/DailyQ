//
//  DailyMeeting.swift
//  Daily Meeting
//
//  Created by  Stepanok Ivan on 10.08.2023.
//

import Foundation
import OpenAISwift

class DailyMeeting: MeetingProtocol {
    
    let persistence: ChatPersistenceProtocol
    let openAI: OpenAISwift
    let companyDetails: String
    let members: [UserSettings]
    @Published var tasks: String?
    var meetingName: String = "Daily Meeting"
    
    init(persistence: ChatPersistenceProtocol,
         openAI: OpenAISwift) {
        self.persistence = persistence
        self.openAI = openAI
        
        self.members = persistence.loadAllUsersSettings().sorted(by: { $0.id < $1.id })
        self.companyDetails = persistence.loadSettings().companyDetails
        ?? "classical it company"
    }
    
    func promt() async -> String {
        let tasks = await generateTasks()
        self.tasks = tasks
        
        let user = (members[3])
        let bot1 = (members[0])
        let bot2 = (members[1])
        let bot3 = (members[2])
        
        return """
        We are at the morning stand-up. There are four of us here, and you are playing the roles of three of us. They are \(bot1.userName) - \(bot1.userRole.rawValue), \(bot2.userName) - \(bot2.userRole.rawValue), and \(bot3.userName) - \(bot3.userRole.rawValue). Each message starts with the user's name and is enclosed in #hashtags#. For example: #\(bot1.userName)# Test message. \(bot1.userName) always starts first. You can only ask questions to \(user.userName); he is playing the role of \(user.userRole.rawValue). Here is a list of his tasks: [\(tasks)] He should talk about each of them. The project everyone is working on: [\(companyDetails)] You cannot write on behalf of \(user.userName). Each of your messages consists of a maximum of 100-300 characters. If the user has told about all the completed tasks and he has no more questions, end the rally and add #MEETINGEND# at the end.
        """
    }

    private func generateTasks() async -> String {
        let promt = """
\(members[3].userName) have a \(members[3].userRole) role in It company. About company: \(companyDetails)
Generate two tasks that the AUTHOR had to complete yesterday and one that he must complete today. Brief description, something not difficult and very interesting. 1-2 sentences. Rarely with humor. Example or your responce: Task-45: Implement a settings screen. Task-46: Add Google Analytics to the project. Task-50: Add Chinese language support
"""
        do {
            let result = try await self.openAI.sendChat(with: [ChatMessage(role: .user, content: promt)], maxTokens: 500)
            return result.choices.first?.message.content ?? "Content creation error"
        } catch {
            print(">>>> 🤡", error.localizedDescription)
            return "Content creation error: \(error.localizedDescription)"
        }
    }
}
