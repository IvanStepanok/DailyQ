//
//  AppAssembly.swift
//  Daily Meeting
//
//  Created by  Stepanok Ivan on 04.08.2023.
//

import Foundation
import Swinject
import OpenAISwift

class AppAssembly: Assembly {
    func assemble(container: Container) {
        
        // MARK: - Managers
        container.register(RouterProtocol.self, factory: { _ in
            Router()
        }).inObjectScope(.container)
        
        // MARK: Persistence
        container.register(ChatPersistenceProtocol.self, factory: { _ in
            ChatPersistence()
        }).inObjectScope(.container)
        
        // MARK: OpenAIKey
        container.register(OpenAISwift.self, factory: { _ in
            OpenAISwift(authToken: "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")
        }).inObjectScope(.container)
        
        // MARK: DailyMeeting
        container.register(DailyMeeting.self) { r in
            DailyMeeting(
                persistence: r.resolve(ChatPersistenceProtocol.self)!,
                openAI: r.resolve(OpenAISwift.self)!
            )
        }.inObjectScope(.weak)
        
        // MARK: TechInterview
        container.register(TechInterview.self) { r in
            TechInterview(
                persistence: r.resolve(ChatPersistenceProtocol.self)!,
                openAI: r.resolve(OpenAISwift.self)!
            )
        }.inObjectScope(.weak)
        
        // MARK: SalaryReview
        container.register(SalaryReview.self) { r in
            SalaryReview(
                persistence: r.resolve(ChatPersistenceProtocol.self)!,
                openAI: r.resolve(OpenAISwift.self)!
            )
        }.inObjectScope(.weak)
    }
}
