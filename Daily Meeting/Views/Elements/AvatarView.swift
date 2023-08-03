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
    init(user: UserSettings, isSpeaking: Binding<Bool>) {
        self.user = user
        self._isSpeaking = isSpeaking
    }
    
    var body: some View {
        ZStack {
            VisualEffectView(effect: UIBlurEffect(style: .dark))
                                            .cornerRadius(15)
                .scaledToFit()

        VStack {
            ZStack {
                if isSpeaking {
                    TalkingIndicatorView()
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
                        .fontWeight(.medium)
                        .scaledToFit()
                        .scaleEffect(2)
                        .foregroundColor(Color.white)
                }
            }.frame(width: 60, height: 60)
            Text(user.userName)
                .foregroundColor(Color.white)
            Text(user.userRole.rawValue)
                    .fontWeight(.thin)
                    .foregroundColor(Color.gray)
            }
        }
    }
}

struct AvatarView_Previews: PreviewProvider {
    static var previews: some View {
        
        let userSetting = UserSettings(id: "1",
                                       isBot: true,
                                       userName: "Igor Kondratuk",
                                       gender: .male,
                                       userRole: .mobile,
                                       englishLevel: .preIntermediate)
        ZStack {
            
            Color("bgColor")
            RainbowBackgroundView()
            AvatarView(user: userSetting,
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
