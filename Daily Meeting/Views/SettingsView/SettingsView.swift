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
                        VStack(alignment: .leading) {
                            Text(Localized("settingsViewSetupTeam"))
                                .padding(.leading, 12)
                                .padding(.bottom, -2)
                                .foregroundStyle(.white)
                                .font(.system(size: 14, weight: .thin, design: .default))
                            LazyVGrid(columns: columns, spacing: 8) {
                                ForEach(viewModel.users.sorted(by: { $0.id < $1.id }), id: \.id) { user in
                                    Button(action: {
                                        viewModel.router.showUserSettingsView(userSettings: user,
                                                                              updatedUser: { updatedData in
                                            if let index = viewModel.users.firstIndex(where: { $0.id == updatedData.id }) {
                                                viewModel.users[index] = updatedData
                                            }
                                        })
                                    }) {
                                        AvatarView(user: user, index: 0, isSpeaking: .constant(false))
                                    }
                                }
                            }
                        }
                        ZStack {
                            Color.clear
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(lineWidth: 1)
                                        .fill(.white.opacity(0.1))
                                )
                            HStack {
                                Toggle(Localized("settingsViewVoiceOver"), isOn: $viewModel.voiceOverOn)
                                    .font(.system(size: 15, weight: .regular, design: .default))
                            }.padding(16)
                        }
                        VStack(alignment: .leading) {
                            Text(Localized("settingsViewUserStackDescription"))
                                .padding(.leading, 12)
                                .padding(.bottom, -2)
                                .font(.system(size: 14, weight: .thin, design: .default))
                                .foregroundColor(.white)
                            
                            TextEditor(text: $viewModel.userStackDescription)
                                .frame(height: 150)
                                .hideScrollContentBackground()
                                .foregroundColor(.white)
                                .padding(13)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(lineWidth: 1)
                                        .fill(.white.opacity(0.1))
                                )
                        }
                        VStack(alignment: .leading) {
                            Text(Localized("settingsViewProjectDescription"))
                                .padding(.leading, 12)
                                .padding(.bottom, -2)
                                .font(.system(size: 14, weight: .thin, design: .default))
                                .foregroundColor(.white)
                            
                            TextEditor(text: $viewModel.projectDescription)
                                .frame(height: 150)
                                .hideScrollContentBackground()
                                .foregroundColor(.white)
                                .padding(13)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(lineWidth: 1)
                                        .fill(.white.opacity(0.1))
                                )
                        }
                        if let support = viewModel.contactSupport() {
                            Spacer(minLength: 30)
                            Link(destination: URL(string: Localized("urlPrivacy"))!, label: {
                            Text(Localized("privacyTitle")).underline()
                        })
                            Link(destination: URL(string: Localized("urlTerms"))!, label: {
                                Text(Localized("termsTitle")).underline()
                            })
                            Button(action: {
                                UIApplication.shared.open(support)
                            }, label: {
                                HStack {
                                    Text(Localized("settingsViewAuthor"))
                                        .font(.system(size: 14, weight: .thin, design: .default))
                                        .underline()
                                }
                            })
                    }
                        Spacer(minLength: 100)
                    }.padding(.horizontal, 16)
                        
                        .ipadWidthLimit()
                }.avoidKeyboard(dismissKeyboardByTap: true)
            }
        }.navigationBarHidden(false) //.toolbar(.visible)
            .navigationTitle(Localized("settingsViewTitle"))
            .onDisappear {
                viewModel.saveSetting()
            }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        
        let users: [UserSettings] = [
            UserSettings(id: 0,
                         isBot: true,
                         userName: "Serhii Dorozhny",
                         avatarName: "avatar-2",
                         userRole: .teamLead,
                         englishLevel: .preIntermediate),
            UserSettings(id: 1,
                         isBot: true,
                         userName: "Igor Kondratuk",
                         avatarName: "avatar-5",
                         userRole: .frontend,
                         englishLevel: .preIntermediate),
            UserSettings(id: 2,
                         isBot: true,
                         userName: "Natalie Kovalengo",
                         avatarName: "avatar-15",
                         userRole: .backend,
                         englishLevel: .preIntermediate),
            UserSettings(id: 3,
                         isBot: false,
                         userName: "Ivan Stepanok",
                         avatarName: "avatar-11",
                         userRole: .mobile,
                         englishLevel: .preIntermediate)
        ]
        
        SettingsView(viewModel: SettingsViewModel(users: users,
                                                  router: RouterMock(),
                                                  persistence: ChatPersistenceMock()))
    }
}

struct RainbowBackgroundView: View {
    
    let timeInterval: Double
    
    let images: [Image] = [
        Image("avatar_0"),
        Image("avatar_2"),
        Image("avatar_3"),
        Image("avatar_8"),
        Image("avatar_11"),
        Image("avatar_12"),
        Image("avatar_16")
    ]
    
    func updateImageIndex() {
        Timer.scheduledTimer(withTimeInterval: timeInterval / 2, repeats: true) { timer in
            withAnimation(.linear(duration: timeInterval )) {
                imageIndex = (imageIndex + 1) % images.count
            }
        }
    }
    
    @State var imageIndex: Int = 0
    
    init(timeInterval: Double = 4) {
        self.timeInterval = timeInterval
    }
    
    var body: some View {
        ZStack {
            GeometryReader { reader in
                images[imageIndex]
                    .resizable()
                    .clipped()
                    .scaledToFit()
                    .blur(radius: 100)
                    .frame(width: reader.size.width, height: reader.size.height / 1)
                    .offset(y: -reader.size.height / 4)
                    .clipped()
            }
        }.onFirstAppear { updateImageIndex() }
            .ignoresSafeArea()
    }
}

