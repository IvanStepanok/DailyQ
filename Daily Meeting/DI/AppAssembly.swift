//
//  AppAssembly.swift
//  Daily Meeting
//
//  Created by  Stepanok Ivan on 04.08.2023.
//

import Foundation
import Swinject

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
        
        // MARK: OpenAI
        container.register(OpenAiManager.self) { r in
            OpenAiManager(persistence: r.resolve(ChatPersistenceProtocol.self)!)
        }
    }
}
