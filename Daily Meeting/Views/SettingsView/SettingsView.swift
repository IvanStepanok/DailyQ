//
//  SettingsView.swift
//  Daily Meeting
//
//  Created by  Stepanok Ivan on 03.08.2023.
//

import SwiftUI

struct SettingsView: View {
    
    @ObservedObject var viewModel: SettingsViewModel
     
    private static var avatarSize: CGFloat = 120
    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    init(viewModel: SettingsViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            ZStack(alignment: .top) {
                Color("bgColor")
                    .ignoresSafeArea()
                RainbowBackgroundView()
                ScrollView {
                    VStack(spacing: 20) {
                        VStack {}.frame(height: 30)
                        VStack(alignment: .leading) {
                            Text("Customize your team:")
                                .padding(.leading, 12)
                                .padding(.bottom, -2)
                                .foregroundStyle(.white)
                                .fontWeight(.thin)
                            LazyVGrid(columns: columns, spacing: 8) {
                                ForEach(Array(viewModel.users.enumerated()), id: \.offset) { _, user in
                                    Button(action: {
                                        viewModel.router.showUserSettingsView(userSettings: user)
                                    }) {
                                        AvatarView(user: user, isSpeaking: .constant(false))
                                    }
                                }
                            }
                        }
                    }.padding(.horizontal, 16)
                }
            }
        }.toolbar(.visible)
            .navigationTitle("Settings")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(viewModel: SettingsViewModel(router: Router()))
    }
}

struct RainbowBackgroundView: View {
    
    let images: [Image] = [
        Image("avatar_0"),
        Image("avatar_1"),
        Image("avatar_2"),
        Image("avatar_3"),
        Image("avatar_4"),
        Image("avatar_5"),
        Image("avatar_6"),
        Image("avatar_7"),
        Image("avatar_8"),
        Image("avatar_9"),
        Image("avatar_11"),
        Image("avatar_10"),
        Image("avatar_12")
    ]
    
    func updateImageIndex() {
        Timer.scheduledTimer(withTimeInterval: 12, repeats: true) { timer in
            withAnimation(.linear(duration: 6)) {
                imageIndex = (imageIndex + 1) % images.count
            }
                }
    }
    
    @State var imageIndex: Int = 0
    
    var body: some View {
        ZStack {
            images[imageIndex]
                .resizable()
                .scaledToFit()
                .ignoresSafeArea()
                .blur(radius: 100)
        }.onAppear(perform: updateImageIndex)
    }
}
