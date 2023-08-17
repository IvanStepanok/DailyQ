//
//  IntroView.swift
//  Daily Meeting
//
//  Created by  Stepanok Ivan on 05.08.2023.
//

import SwiftUI
import OpenAISwift
import Swinject

struct IntroView: View {
    
    @ObservedObject var viewModel: IntroViewModel
//    private static var avatarSize: CGFloat = 120
    private let columns = [GridItem(.flexible()), GridItem(.flexible())]
        
    init(viewModel: IntroViewModel) {
        self.viewModel = viewModel
    }    
    
    var body: some View {
        ZStack {
            Color("bgColor").ignoresSafeArea()
            RainbowBackgroundView(timeInterval: 3)//.scaleEffect(1.4)
            VStack {
                //                if true {
                if viewModel.showNameInput {
                    Group {
                    Text(Localized("introViewYourNameTitle"))
                        .font(.system(size: 36, weight: .thin, design: .default))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        VStack(alignment: .leading) {
                            Text(Localized("introViewYourNameDescription"))
                                .padding(.leading, 12)
                                .padding(.bottom, -2)
                                .font(.system(size: 14, weight: .thin, design: .default))
                                .foregroundColor(.white)
                            ZStack(alignment: .trailing) {
                                if viewModel.userSettings.userName == "" {
                                    HStack {
                                        Text("Taras Shevchenko")
                                            .font(.system(size: 16, weight: .regular, design: .default))
                                            .opacity(0.2)
                                        Spacer()
                                    }.padding(.leading, 12)
                                }
                                TextField("", text: $viewModel.userSettings.userName)
                                    .foregroundColor(.white)
                                    .padding(13)
                                
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(lineWidth: 1)
                                            .fill(.white.opacity(0.1))
                                    )
                                if viewModel.userSettings.userName != "" {
                                    CustomButton(text: Localized("introViewNextButton"), action: {
                                        withAnimation {
                                            viewModel.index = 0
                                            viewModel.showNameInput = false
                                            viewModel.currentMessagesIndex = 1
                                            viewModel.animation = false
                                            viewModel.roleMessage()
                                        }
                                    }).padding(.trailing, 2)
                                }
                            }
                        }
                    }.opacity(viewModel.animation ? 1 : 0).padding(24)
                } else if viewModel.showUserRole {
                    // Add the Picker for userRole
                    ZStack {
                        VStack {
                            Text(Localized("introViewRoleTitle"))
                                .font(.system(size: 36, weight: .thin, design: .default))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                            ZStack(alignment: .bottomTrailing) {
                                Menu {
                                    Picker(selection: $viewModel.userSettings.userRole) {
                                        ForEach(UserRole.allCases, id: \.self) { role in
                                            Text(role.rawValue).tag(role)
                                        }
                                    } label: {}
                                } label: {
                                    
                                    VStack(alignment: .leading) {
                                        Text(Localized("introViewYourRole"))
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
                                CustomButton(text: Localized("introViewNextButton"), action: {
                                    viewModel.index = 0
                                    viewModel.showUserRole = false
                                    viewModel.currentMessagesIndex = 2
                                    viewModel.animation = false
                                    viewModel.englishMessage()
                                })
                                .padding(.trailing, 1)
                                .padding(.bottom, 1)
                            }
                        }.opacity(viewModel.animation ? 1 : 0).padding(24)
                    }
                } else if viewModel.showEnglish {
                    // Add the Picker for userRole
                    ZStack {
                        VStack {
                            Text(Localized("introViewEnglishLevel"))
                                .font(.system(size: 36, weight: .thin, design: .default))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                            ZStack(alignment: .bottomTrailing) {
                                Menu {
                                    Picker(selection: $viewModel.userSettings.englishLevel) {
                                        ForEach(EnglishLevel.allCases.reversed(), id: \.self) { role in
                                            Text(role.rawValue).tag(role)
                                        }
                                    } label: {}
                                } label: {
                                    VStack(alignment: .leading) {
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
                                CustomButton(text: Localized("introViewNextButton"), action: {
                                    viewModel.saveUser()
                                    viewModel.index = 0
                                    viewModel.showEnglish = false
                                    viewModel.animation = false
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5
                                    ) {
                                        withAnimation {
                                            viewModel.animation = true
                                        }
                                    }
                                    viewModel.showWorkDescription = true
                                })
                                .padding(.trailing, 1)
                                .padding(.bottom, 1)
                            }
                        }.opacity(viewModel.animation ? 1 : 0).padding(24)
                    }
                } else if viewModel.showWorkDescription {
                    VStack(spacing: 20) {
                    Text(Localized("introViewProjectTitle"))
                        .font(.system(size: 36, weight: .thin, design: .default))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                        VStack(alignment: .leading) {
                            Text(Localized("introViewProjectDescription"))
                                .padding(.leading, 12)
                                .padding(.bottom, -2)
                                .font(.system(size: 14, weight: .thin, design: .default))
                                .foregroundColor(.white)
                            ZStack(alignment: .topTrailing) {
                                
                                    TextEditor(text: $viewModel.workDescription)
                                                       .frame(height: 150)
                                                       .hideScrollContentBackground()
                                                       .foregroundColor(.white)
                                                       .padding(13)
                                                       .overlay(
                                                           RoundedRectangle(cornerRadius: 12)
                                                               .stroke(lineWidth: 1)
                                                               .fill(.white.opacity(0.1))
                                                       )
                                Button(action: {
                                    viewModel.generateWorkDescription()
                                }, label: {
                                    Image(systemName: "arrow.clockwise")
                                }).padding(10)
                            }
                            HStack {
                                Spacer()
                                CustomButton(text: Localized("introViewContinueButton"), action: {
                                    viewModel.saveCompanyDetails()
                                    viewModel.index = 0
                                    viewModel.showWorkDescription = false
                                    viewModel.currentMessagesIndex = 3
                                    viewModel.animation = false
                                    viewModel.userStackMessage()
                                })
                                Spacer()
                            }
                        }
                    }.opacity(viewModel.animation ? 1 : 0).padding(24)
                        .padding(.top, 100)
                        .avoidKeyboard(dismissKeyboardByTap: true)
                } else if viewModel.showUserStackDescription {
                    VStack(spacing: 20) {
                    Text(Localized("introViewRoleTitle"))
                        .font(.system(size: 36, weight: .thin, design: .default))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                        VStack(alignment: .leading) {
                            Text(Localized("introViewRoleDescription"))
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
                                .onAppear {
                                    viewModel.userStackDescription = viewModel.userStackDescriptionExample()
                                }
                        }
                            HStack {
                                Spacer()
                                CustomButton(text: Localized("introViewContinueButton"), action: {
                                    viewModel.saveUserStackDetails()
                                    viewModel.index = 0
                                    viewModel.showUserStackDescription = false
                                    viewModel.currentMessagesIndex = 4
                                    viewModel.animation = false
                                    viewModel.membersMessage()
                                })
                                Spacer()
                            }
                    }.opacity(viewModel.animation ? 1 : 0).padding(24)
                        .padding(.top, 100)
                        .avoidKeyboard(dismissKeyboardByTap: true)
                } else if viewModel.showMembers {
                    VStack(alignment: .center, spacing: 20) {
                        VStack {}.frame(height: 30)
                        VStack(alignment: .leading) {
                            Text(Localized("introViewTeamSetup"))
                                .padding(.leading, 12)
                                .padding(.bottom, -2)
                                .foregroundStyle(.white)
                                .font(.system(size: 18, weight: .thin, design: .default))
                            LazyVGrid(columns: columns, spacing: 8) {
                                ForEach(viewModel.teamSettings, id: \.id) { user in
                                    Button(action: {
                                        viewModel.router.showUserSettingsView(userSettings: user,
                                                                              updatedUser: { updatedData in
                                            if let index = viewModel.teamSettings.firstIndex(where: { $0.id == updatedData.id }) {
                                                viewModel.teamSettings[index] = updatedData
                                            }
                                        })
                                    }) {
                                        AvatarView(user: user, index: 0, isSpeaking: .constant(false))
                                    }
                                }
                            }
                        }
                        CustomButton(text: Localized("introViewStartFirstMeeting"), action: {
                            viewModel.router.startFirstMeeting()
                        })
                    }.padding(.horizontal, 16)
                        .opacity(viewModel.animation ? 1 : 0).padding(24)
                    } else {
                    Text(viewModel.allMessages[viewModel.currentMessagesIndex][viewModel.index])
                        .font(.system(size: 36, weight: .thin, design: .default))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(24)
                }
            }.ipadWidthLimit()
            if viewModel.isLoading && viewModel.showWorkDescription {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            }
        }.onFirstAppear {
            viewModel.nameMessage()
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
    }
}

struct IntroView_Previews: PreviewProvider {
    static var previews: some View {
        IntroView(viewModel: IntroViewModel(
            userSettings: UserSettings(
                id: 0,
                isBot: false,
                userName: "dfg",
                userRole: .mobile,
                englishLevel: .advanced
            ), persistence: ChatPersistenceMock(),
            router: RouterMock(),
            openAI: OpenAiManager(meeting: DailyMeeting(persistence: ChatPersistenceMock(), openAI: OpenAISwift(authToken: ""))))
        )
    }
}
