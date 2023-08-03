//
//  Daily_MeetingApp.swift
//  Daily Meeting
//
//  Created by  Stepanok Ivan on 02.08.2023.
//

import SwiftUI
import Swinject

@main
struct Daily_MeetingApp: App {
    var body: some Scene {
        WindowGroup {
            VStack {}
                .onAppear {
                    _ = Assembler([AppAssembly()],
                                  container: Container.shared)
                    Container.shared.resolve(Router.self)!.configureNavigationController()
                }
//            ChatScreenView()
//            VoiceRecordView(viewModel: VoiceRecordViewModel(), recognitiedText: { text in
//                print(">>>> TEXT", text)
//            })
        }
    }
}
