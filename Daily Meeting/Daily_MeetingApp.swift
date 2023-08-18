//
//  Daily_MeetingApp.swift
//  Daily Meeting
//
//  Created by  Stepanok Ivan on 02.08.2023.
//

import SwiftUI
import Swinject
import Mixpanel

@main
struct Daily_MeetingApp: App {
    var body: some Scene {
        WindowGroup {
            VStack {}
                .onAppear {
                    Mixpanel.initialize(token: "18733af02b623b28c4560e68e67d444a", trackAutomaticEvents: true)

                    _ = Assembler([AppAssembly()],
                                  container: Container.shared)
                    Container.shared.resolve(RouterProtocol.self)!.configureNavigationController()
                }
        }
    }
}

// Global func for localization
func Localized(_ string: String) -> String {
    return NSLocalizedString(string, comment: "")
}
