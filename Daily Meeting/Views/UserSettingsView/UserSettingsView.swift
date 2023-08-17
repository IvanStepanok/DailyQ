//
//  UserSettingsView.swift
//  Daily Meeting
//
//  Created by  Stepanok Ivan on 03.08.2023.
//

import SwiftUI

struct UserSettingsView: View {
    
    private var isUser: Bool
    private static var avatarSize: CGFloat = 50
    @ObservedObject var viewModel: UserSettingsViewModel
    
    private let columns = [GridItem(.flexible()),
                           GridItem(.flexible()),
                           GridItem(.flexible()),
                           GridItem(.flexible()),
                           GridItem(.flexible()),
                           GridItem(.flexible())]
    
    init(isUser: Bool, viewModel: UserSettingsViewModel) {
        self.isUser = isUser
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Color("bgColor")
                .ignoresSafeArea()
            if let avatarName = viewModel.userSettings.avatarName {
                Image(avatarName)
                    .resizable()
                    .scaledToFit()
                    .ignoresSafeArea()
                    .blur(radius: 100)
            } else {
             
                LinearGradient(colors: [Color(uiColor: viewModel.userSettings.color).opacity(0.1),
                                        Color("bgColor")], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            }
            ScrollView {
                VStack {
                    VStack(spacing: 15) {
                        ZStack {
                            if let avatarName = viewModel.userSettings.avatarName {
                             Image(avatarName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 120, height: 120)
                                    .cornerRadius(60)
                            } else {
                                Circle()
                                    .foregroundColor(Color(uiColor: viewModel.userSettings.color))
                                Text(viewModel.userSettings.userName.prefix(1))
                                    .fontWeight(.medium)
                                    .scaledToFit()
                                    .scaleEffect(2)
                                    .foregroundColor(Color.white)
                            }
                        }.frame(width: 120, height: 120)
                        Text(viewModel.userSettings.userName)
                            .scaleEffect(1.4)
                            .foregroundColor(Color.white)
                        Text(viewModel.userSettings.userRole.rawValue)
                            .scaleEffect(1.4)
                            .font(.system(size: 18, weight: .thin, design: .default))
                            .foregroundColor(Color.white.opacity(0.5))
                        
                        Spacer(minLength: 20)
                        
                        VStack(spacing: 24) {
                            
                            VStack(alignment: .leading) {
                                Text(Localized("userSettingsAvatar"))
                                    .padding(.leading, 12)
                                    .padding(.bottom, -2)
                                    .foregroundStyle(.white)
                                    .font(.system(size: 18, weight: .thin, design: .default))
                                LazyVGrid(columns: columns) {
                                    ForEach(viewModel.avatars, id: \.self) { avatar in
                                        Button(action: {
                                            withAnimation {
                                                viewModel.updateAvatarName(avatar)
                                            }
                                        }) {
                                            Image(avatar)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: UserSettingsView.avatarSize,
                                                       height: UserSettingsView.avatarSize)
                                                .cornerRadius(UserSettingsView.avatarSize / 2)
                                                .padding(.horizontal, 4)
                                        }
                                    }
                                        Button(action: {
                                            viewModel.updateAvatarName(nil)
                                        }, label: {
                                            ZStack {
                                            Circle()
                                                .foregroundStyle(.clear)
    //                                            .foregroundStyle(Color("secondaryColor"))
                                                .overlay(
                                                    Circle()
                                                        .stroke(lineWidth: 1)
                                                        .fill(.white.opacity(0.1))
                                                )
                                            Image(systemName: "xmark")
                                                .foregroundColor(.white)
                                            }.frame(width: UserSettingsView.avatarSize)

                                        })
                                        
                                }
                            }
                            
                            VStack(alignment: .leading) {
                                Text(Localized("userSettingsUsername"))
                                    .padding(.leading, 12)
                                    .padding(.bottom, -2)
                                    .font(.system(size: 18, weight: .thin, design: .default))
                                HStack {
                                    TextField("", text: $viewModel.userSettings.userName)
                                        
                                    Spacer()
                                    Button(action: {
                                        viewModel.randomName()
                                    }, label: {
                                        Image(systemName: "arrow.clockwise")
                                    })
                                }.padding(13)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(lineWidth: 1)
                                            .fill(.white.opacity(0.1))
                                    )
                            }.foregroundStyle(.white)
                            
                            // Add the Picker for userRole
                            Menu {
                                Picker(selection: $viewModel.userSettings.userRole) {
                                    ForEach(UserRole.allCases, id: \.self) { role in
                                        Text(role.rawValue).tag(role)
                                    }
                                } label: {}
                            } label: {
                                VStack(alignment: .leading) {
                                    Text(Localized("userSettingsRole"))
                                        .padding(.leading, 12)
                                        .padding(.bottom, -2)
                                        .font(.system(size: 18, weight: .thin, design: .default))
                                    HStack {
                                        Text(viewModel.userSettings.userRole.rawValue)
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                    }.padding(13)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(lineWidth: 1)
                                                .fill(.white.opacity(0.1))
                                        )
                                }.foregroundStyle(.white)
                            }
                            
                            if !viewModel.userSettings.isBot {
                                Menu {
                                    Picker(selection: $viewModel.userSettings.englishLevel) {
                                        ForEach(EnglishLevel.allCases.reversed(), id: \.self) { level in
                                            Text(level.rawValue).tag(level)
                                        }
                                    } label: {}
                                } label: {
                                    VStack(alignment: .leading) {
                                        Text(Localized("userSettingsEnglishLevel"))
                                            .padding(.leading, 12)
                                            .padding(.bottom, -2)
                                            .font(.system(size: 18, weight: .thin, design: .default))
                                        HStack {
                                            Text(viewModel.userSettings.englishLevel.rawValue)
                                            Spacer()
                                            Image(systemName: "chevron.down")
                                        }.padding(13)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(lineWidth: 1)
                                                    .fill(.white.opacity(0.1))
                                            )
                                    }.foregroundStyle(.white)
                                }
                            }
                        }
                        
                    }.padding(.horizontal, 16)
                        .padding(.top, 24)
                }.ipadWidthLimit()
                .onDisappear {
                    viewModel.updateUserName(viewModel.userSettings.userName)
                }
                Spacer(minLength: 160)
            }
        }.navigationBarHidden(false)
            .navigationTitle("")
    }
}

struct UserSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        
        let userSetting = UserSettings(id: 1,
                                       isBot: false,
                                       userName: "Igor Kondratuk",
                                       userRole: .mobile,
                                       englishLevel: .preIntermediate)
        
        UserSettingsView(isUser: true, viewModel: UserSettingsViewModel(userSettings: userSetting,
                                                                        persistence: ChatPersistence(),
                                                                        updatedUser: {_ in }))
    }
}
