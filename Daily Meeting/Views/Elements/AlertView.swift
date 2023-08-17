//
//  AlertView.swift
//  Daily Meeting
//
//  Created by  Stepanok Ivan on 07.08.2023.
//

import SwiftUI

struct AlertView: View {
    
    var text: String
    var yesClicked: () -> Void
    var cancelClicked: () -> Void
    var hideCancelButton: Bool
    @State var animate: Bool = false
    @Binding var showProgress: Bool
    
    init(text: String,
         hideCancelButton: Bool = false,
         yesClicked: @escaping () -> Void,
         cancelClicked: @escaping () -> Void,
         showProgress: Binding<Bool> = .constant(false)) {
        self.text = text
        self.hideCancelButton = hideCancelButton
        self.yesClicked = yesClicked
        self.cancelClicked = cancelClicked
        self._showProgress = showProgress
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(animate ? 0.5 : 0)
                .ignoresSafeArea()
                .onTapGesture {
                    cancelClicked()
                }
                .onAppear {
                    withAnimation(Animation.spring(response: 0.6, dampingFraction: 0.6)) {
                        animate = true
                    }
                }
                .onDisappear {
                        withAnimation(Animation.spring(response: 0.6, dampingFraction: 0.6)) {
                            animate = false
                        }
                }
            VStack {
                VStack {
                    ZStack {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .opacity(showProgress ? 1 : 0)
                        if !showProgress {
                            Text(text)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.white)
                                .font(.system(size: 24, weight: .light, design: .default))
                                .padding(.bottom, 20)
                                .padding(.top, 10)
                                .padding(.horizontal, 30)
//                                .opacity(showProgress ? 0 : 1)
                        } else {
                            VStack {}.frame(width: 170, height: 100)
                        }
                    }
                        HStack {
                            if !showProgress {
                                CustomButton(text: Localized("buttonYes"), flexible: true, bgColor: .green, action: { yesClicked() })
                                if !hideCancelButton {
                                    CustomButton(text: Localized("buttonNo"), flexible: true, bgColor: .gray.opacity(0.6), action: { cancelClicked() })
                                }
                            }
                        }.padding(.horizontal, 33)
                }.padding(.horizontal, 30)
                    .padding(.vertical, 16)
                    .background {
                        VisualEffectView(effect: UIBlurEffect(style: .systemThinMaterial))
                            .cornerRadius(16)
                            .padding(.horizontal, 48)
                    }
            }.scaleEffect(animate ? 1 : 0.9)
                .opacity(animate ? 1 : 0)
                .offset(y: animate ? 0 : 100)
                .ipadWidthLimit()
        }
    }
}

struct AlertView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack(alignment: .top) {
            Color("bgColor")
                .ignoresSafeArea()
            RainbowBackgroundView(timeInterval: 3)
                
            AlertView(text: "Цей контент доступний лише для Premium акаунтів. Бажаєте спробувати?",
                      hideCancelButton: true,
                      yesClicked: {},
                      cancelClicked: {}, showProgress: .constant(false))
        }
    }
}
