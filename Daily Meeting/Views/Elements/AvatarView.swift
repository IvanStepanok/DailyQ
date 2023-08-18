//
//  AvatarView.swift
//  Daily Meeting
//
//  Created by  Stepanok Ivan on 03.08.2023.
//

import SwiftUI

struct AvatarView: View {
    
    @Binding var isSpeaking: Bool
    
    var user: UserSettings
    var index: Int
    @State private var showView = false
    init(user: UserSettings, index: Int, isSpeaking: Binding<Bool>) {
        self.user = user
        self.index = index
        self._isSpeaking = isSpeaking
    }
    
    var body: some View {
        ZStack {
            ZStack {
                VisualEffectView(effect: UIBlurEffect(style: .dark))
                    .cornerRadius(15)
                    .scaledToFit()
                    .overlay {
                        if !user.isBot {
                            ZStack(alignment: .topLeading) {
                                VStack {
                                    HStack(spacing: 3) {
                                        Image(systemName: "person.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 10)
                                        Text("YOU")
                                            .font(.system(size: 12, weight: .regular, design: .default))
                                        Spacer()
                                    }.padding(.top, 8)
                                        .padding(.leading, 12)
                                        .opacity(0.3)
                                    Spacer()
                                }
                            }
                        } else if user.id == 1 {
                            ZStack(alignment: .topLeading) {
                                VStack {
                                    HStack {
                                        Image(systemName: "crown.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 12)
                                        Spacer()
                                    }.padding(.top, 8)
                                        .padding(.leading, 12)
                                        .opacity(0.3)
                                    Spacer()
                                }
                            }
                        }
                    }
                VStack {
                    ZStack {
                        if isSpeaking {
//                                                TalkingIndicatorView()
                            Group {
                                SiriIndicatorView(offsetX: 0, offsetY: -7, color: Color.cyan, opacity: 1)
                                SiriIndicatorView(offsetX: 7, offsetY: 7, color: .blue, opacity: 1)
                                SiriIndicatorView(offsetX: -7, offsetY: 7, color: .purple, opacity: 0.7)
                            }.opacity(0.5)
                        }
                        if let avatarName = user.avatarName {
                            Image(avatarName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                                .cornerRadius(30)
                        } else {
                            Circle()
                                .foregroundColor(Color(uiColor: user.color))
                            Text(user.userName.prefix(1))
                                .font(.system(size: 16, weight: .medium, design: .default))
                                .scaledToFit()
                                .foregroundColor(Color.white)
                        }
                    }.frame(width: 60, height: 60)
                    Text(user.userName)
                        .padding(.top, 8)
                        .foregroundColor(Color.white)
                    Text(user.userRole.rawValue)
                        .font(.system(size: 12, weight: .thin, design: .default))
                        .foregroundColor(Color.gray)
                }
            }.opacity(showView ? 1 : 0)
                .scaleEffect(showView ? 1 : 0.5)
        }.onFirstAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + (Double(index) * CGFloat.random(in: 0.1...0.9)) ) {
                withAnimation(.interactiveSpring(response: 0.4, dampingFraction: 0.6)) {
                    showView = true
                }
            }
        }
    }
}

struct AvatarView_Previews: PreviewProvider {
    static var previews: some View {
        
        let userSetting = UserSettings(id: 1,
                                       isBot: false,
                                       userName: "Igor Kondratuk",
                                       userRole: .mobile,
                                       englishLevel: .preIntermediate)
        ZStack {
            
            Color("bgColor")
            RainbowBackgroundView()
            AvatarView(user: userSetting,
                       index: 1,
                       isSpeaking: .constant(true))
                .padding(48)
        }.ignoresSafeArea()
    }
}

// Helper View to apply the blur effect
struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView {
        return UIVisualEffectView()
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) {
        uiView.effect = effect
    }
}

struct TalkingIndicatorView: View {
    @State private var isAnimating = false
    @State private var scale: CGFloat = 1.0

    var body: some View {
        Circle()
            .foregroundColor(.white.opacity(0.07)) // Цвет круга
            .frame(width: 60, height: 60)
            .scaleEffect(scale) // Используем переменную scale для масштабирования
            .onAppear {
                animate()
            }
    }

    func animate() {
        withAnimation(Animation.easeInOut(duration: 0.2)) {
            isAnimating = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.randomizeScale()
        }
    }
    
    func randomizeScale() {
        // Генерируем случайное значение для масштабирования
        let randomScale = CGFloat.random(in: 1.1...1.5)
        withAnimation(Animation.easeInOut(duration: 0.2)) {
            scale = randomScale
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.randomizeScale()
        }
    }
}

struct SiriIndicatorView: View {
    @State private var isAnimating = false
    @State private var scale: CGFloat = 1.0
    var offsetX: CGFloat
    var offsetY: CGFloat
    
    let color: Color
    let opacity: CGFloat

    var body: some View {
        Circle()
            .offset(x: offsetX, y: offsetY)
            .blur(radius: 7)
            .foregroundColor(color.opacity(opacity)) // Цвет круга
            .frame(width: 60, height: 60)
            .scaleEffect(scale) // Используем переменную scale для масштабирования
            .onAppear {
                animate()
            }
    }

    func animate() {
        withAnimation(Animation.easeInOut(duration: 0.2)) {
            isAnimating = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.randomizeScale()
        }
    }
    
    func randomizeScale() {
        let randomScale = CGFloat.random(in: 0.7...1.5)
        withAnimation(Animation.easeInOut(duration: 0.5)) {
            scale = randomScale
        }
        
        let randomOffsetX = CGFloat.random(in:-3...3)
        withAnimation(Animation.easeInOut(duration: 0.5)) {
//            offsetX = randomOffsetX
        }
        
        let randomOffsetY = CGFloat.random(in: -3...3)
        withAnimation(Animation.easeInOut(duration: 0.5)) {
//            offsetY = randomOffsetY
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.randomizeScale()
        }
    }
}
