//
//  PremiumView.swift
//  Daily Meeting
//
//  Created by  Stepanok Ivan on 07.08.2023.
//

import SwiftUI
import ConfettiSwiftUI

struct PremiumView: View {
    
    enum AccessType {
        case month
        case year
    }
    
    let features: [String] = [
    Localized("premiumFeature1"),
    Localized("premiumFeature2"),
    Localized("premiumFeature3"),
    Localized("premiumFeature4"),
    Localized("premiumFeature5")
    ]
    
    @State var counter: Int = 0
    @State var isYearAccess: Bool = false
    @State var alertMessageText: String = Localized("premiumAlertMessage")
    @State var subscribeSuccess: Bool = false
    @State var alertSubscribeFailureText: String = Localized("premiumFailure")
    @State var showFailureSubscribe: Bool = false
    @State var isLoading: Bool = false
    
    private let router: RouterProtocol
    private let persistence: ChatPersistenceProtocol
    
    init(router: RouterProtocol, persistence: ChatPersistenceProtocol) {
        self.router = router
        self.persistence = persistence
    }
    
    var body: some View {
        ZStack(alignment: .center) {
            Color("bgColor")
                .ignoresSafeArea()
            RainbowBackgroundView(timeInterval: 2)
            VStack {}
                .confettiCannon(counter: $counter,
                                  num: 100,
                                  confettiSize: 15,
                                  closingAngle: .radians(20),
                                  radius: 200
                  )
            ScrollView {
                ZStack(alignment: .topLeading) {
                    Image("premium")
                        .resizable()
                        .scaledToFill()
                        .frame(height: 350)
                        .mask {
                            LinearGradient(colors: [.black, .black, .clear],
                                           startPoint: .top,
                                           endPoint: .bottom)
                        }
                        .padding(.bottom, -180)
                    Image(systemName: "xmark")
                        .padding(.leading, 30)
                        .padding(.top, 50)
                        .opacity(0.6)
                        .onTapGesture {
                            router.back(animated: true)
                        }
                }
                VStack(alignment: .center, spacing: 20) {
                    HStack {
                        Text(Localized("premiumGetPremiumTitle"))
                            .shadow(color: .black, radius: 15)
                            .multilineTextAlignment(.center)
                            .font(.system(size: 48, weight: .thin, design: .default))
                    }
                    //                    Spacer(minLength: 10)
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(Array(features.enumerated()), id: \.offset) { _, text in
                            HStack {
                                Image(systemName: "checkmark")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 10)
                                    .foregroundColor(.green)
                                Text(text)
                                    .font(.system(size: 14, weight: .semibold, design: .default))
                            }
                        }
                    }
                    
                    ZStack {
                        Color.clear
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(lineWidth: 1)
                                    .fill(.white.opacity(!isYearAccess ? 1 : 0.1))
                            )
                        HStack {
                            Toggle(Localized("premiumTrialToggle"), isOn: $isYearAccess.not)
                                .font(.system(size: 15, weight: .regular, design: .default))
                        }.padding(16)
                    }
                    
                    Button(action: {
                        isYearAccess = true
                    }, label: {
                        ZStack(alignment: .topTrailing) {
                            Color.clear
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(lineWidth: 1)
                                        .fill(.white.opacity(isYearAccess ? 1 : 0.1))
                                )
                            Text(Localized("premiumSave20"))
                                .foregroundColor(.black)
                                .font(.system(size: 12, weight: .bold, design: .default))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background {
                                    RoundedRectangle(cornerRadius: 15)
                                        .foregroundColor(.green)
                                }.offset(x: -16, y: -10)
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(Localized("premiumYearlySub"))
                                    Text("47,99$")
                                }.font(.system(size: 15, weight: .regular, design: .default))
                                Spacer()
                                SelectorView(isSelected: $isYearAccess)
                            }.padding(16)
                        }
                    })
                    
                    Button(action: {
                        isYearAccess = false
                    }, label: {
                        ZStack {
                            Color.clear
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(lineWidth: 1)
                                        .fill(.white.opacity(!isYearAccess ? 1 : 0.1))
                                )
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(Localized("premium3DaysFree"))
                                    Text(Localized("premiumAfter3Days"))
                                }.font(.system(size: 15, weight: .regular, design: .default))
                                Spacer()
                                SelectorView(isSelected: .constant(!isYearAccess))
                            }.padding(16)
                        }
                    })
                    
                    CustomButton(text: isYearAccess ? Localized("premiumContinueButton") : Localized("premiumFreePeriodButton"),
                                 flexible: true,
                                 bgColor: .green,
                                 action: {
                        Task {
                            isLoading = true
                            if await router.getPremium(isYearAccess: isYearAccess) {
                                isLoading = false
                                subscribeSuccess = true
                                counter += 1
                                
                            } else {
                                isLoading = false
                                subscribeSuccess = false
                                
                                    
                            }
                        }
                    })
                    HStack {
                        Image(systemName: "bolt.shield.fill")
                            .foregroundColor(.green)
                        Text(Localized("premiumNotPayNow"))
                    }.padding(.top, -10)
                    
                    HStack {
                        Link(destination: URL(string: "https://stepanok.com/privacy-and-policy.html")!, label: {
                        Text("Privacy Policy").underline()
                    })
                        Spacer()
                        Button {
                            isLoading = true
                            router.restorePurchases(isPremium: { isPremium in
                                if isPremium {
                                    isLoading = false
                                    subscribeSuccess = true
                                    counter += 1
                                } else {
                                    isLoading = false
                                }
                            })
                        } label: {
                            Text("Resote Purchases").underline()
                        }

                        
                        Spacer()
                        Link(destination: URL(string: "https://stepanok.com/terms-and-conditions.html")!, label: {
                            Text("Terms of Service").underline()
                        })
                            .underline()
                    }.font(.system(size: 10, weight: .thin, design: .default))
                        
                    Text(Localized("premiumDescription"))
                        .padding(.top, 30)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 14, weight: .thin, design: .default))
                    Spacer(minLength: 70)
                }.padding(.horizontal, UIDevice.current.userInterfaceIdiom == .pad ? 170 : 28)
            }.ignoresSafeArea()
            
            
            if subscribeSuccess {
                AlertView(text: alertMessageText,
                          hideCancelButton: true,
                          yesClicked: {
                    withAnimation {
                        subscribeSuccess = false
                        router.back(animated: true)
                    }
                }, cancelClicked: {}
                )
            }
            if showFailureSubscribe {
                AlertView(text: alertSubscribeFailureText,
                          hideCancelButton: true,
                          yesClicked: {
                    withAnimation {
                        showFailureSubscribe = false
                    }
                }, cancelClicked: {})
            }
            if isLoading {
                Color.black.opacity(0.7)
                    .ignoresSafeArea()
                    ZStack {
                        VisualEffectView(effect: UIBlurEffect(style: .dark))
                            .cornerRadius(16)
                        ProgressView()
                            .progressViewStyle(.circular)
                }.frame(width: 120, height: 120)
            }
        }.navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
    }
}



struct PremiumView_Previews: PreviewProvider {
    static var previews: some View {
        PremiumView(router: RouterMock(),
                    persistence: ChatPersistenceMock())
    }
}

struct SelectorView: View {
    
    @Binding var isSelected: Bool
    
    var body: some View {
        ZStack {
            if isSelected {
                Circle()
                    .frame(width: 22)
            }
            Circle()
                .stroke(lineWidth: 2)
                .fill(.white)
        }.frame(width: 28)
    }
}

extension Binding where Value == Bool {
    var not: Binding<Value> {
        Binding<Value>(
            get: { !self.wrappedValue },
            set: { self.wrappedValue = !$0 }
        )
    }
}
