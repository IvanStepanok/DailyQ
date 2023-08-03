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
        container.register(Router.self, factory: { _ in
            Router()
        }).inObjectScope(.container)
    }
}
