//
//  SettingsView.swift
//  Daily Meeting
//
//  Created by  Stepanok Ivan on 03.08.2023.
//

import SwiftUI

struct SettingsView: View {
    
    @ObservedObject var viewModel: SettingsViewModel
    @State var voiceOverOn: Bool = true
     
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
                            Text("Налаштуйте свою команду:")
                                .padding(.leading, 12)
                                .padding(.bottom, -2)
                                .foregroundStyle(.white)
                                .font(.system(size: 18, weight: .light, design: .default))
                            LazyVGrid(columns: columns, spacing: 8) {
                                ForEach(viewModel.users.sorted(by: {$0.id < $1.id}), id: \.id) { user in
                                    Button(action: {
                                        viewModel.router.showUserSettingsView(userSettings: user,
                                                                              updatedUser: { updatedData in
                                            if let index = viewModel.users.firstIndex(where: { $0.id == updatedData.id }) {
                                                viewModel.users[index] = updatedData
                                            }
                                        })
                                    }) {
                                        AvatarView(user: user, isSpeaking: .constant(false))
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
                                Toggle("Озвучувати голосом", isOn: $voiceOverOn)
                                    .font(.system(size: 15, weight: .regular, design: .default))
                            }.padding(16)
                        }
                        Spacer(minLength: 100)
                    }.padding(.horizontal, 16)
                }
            }
        }.navigationBarHidden(false) //.toolbar(.visible)
            .navigationTitle("Settings")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        
        let users: [UserSettings] = [
            UserSettings(id: 0,
                         isBot: false,
                         userName: "Ivan Stepanok",
                         avatarName: "avatar_0",
                         gender: .male,
                         userRole: .teamLead,
                         englishLevel: .preIntermediate),
            UserSettings(id: 1,
                         isBot: true,
                         userName: "Igor Kondratuk",
                         avatarName: "avatar_5",
                         gender: .male,
                         userRole: .teamLead,
                         englishLevel: .preIntermediate),
            UserSettings(id: 2,
                         isBot: true,
                         userName: "Natalie Kovalengo",
                         avatarName: "avatar_4",
                         gender: .female,
                         userRole: .backend,
                         englishLevel: .preIntermediate),
            UserSettings(id: 3,
                         isBot: true,
                         userName: "Serhii Dorozhny",
                         avatarName: "avatar_11",
                         gender: .male,
                         userRole: .designer,
                         englishLevel: .preIntermediate)
        ]
        
        SettingsView(viewModel: SettingsViewModel(users: users, router: RouterMock()))
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
        Image("avatar_13"),
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
                    .frame(height: reader.size.height / 1)
                    .offset(y: -reader.size.height / 4)
                    .clipped()
            }
        }.onAppear(perform: updateImageIndex)
            .ignoresSafeArea()

            
    }
}
