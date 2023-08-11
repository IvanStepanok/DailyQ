//
//  PremiumView.swift
//  Daily Meeting
//
//  Created by  Stepanok Ivan on 07.08.2023.
//

import SwiftUI

struct PremiumView: View {
    
    enum AccessType {
        case month
        case year
    }
    
    let features: [String] = [
    "До десяти мітингів на день",
    "Розбір граматики після кожного мітингу",
    "Технічні співбесіди",
    "Perfomance та Salary review",
    "Жодних зобов'язань, скасування будь-коли."
    ]
    
    let description = """
Ваша безкоштовна пробна версія розпочнеться протягом 3 днів, а потім з вас щомісяця стягуватиметься 3,99 доларів США. Відповідно до Умов використання iTunes Store, з якими ми рекомендуємо ознайомитися, перш ніж здійснювати будь-яку онлайн-транзакцію: оплата буде стягнена з вашого облікового запису iTunes після підтвердження покупки; Ваша підписка на наші преміум-сервіси або продукти через програму буде автоматично поновлена ​​на ту саму підписку з тією ж ціною, що й ви спочатку підписалися, якщо ви не скасуєте свою підписку, вимкнувши автоматичне поновлення принаймні за 24 години до закінчення поточного періоду; За 24 години до закінчення поточного періоду з вашого облікового запису стягуватиметься плата за оновлення за тією ж ставкою, що й у початковій підписці; Ви можете керувати підписками, а автоматичне поновлення можна вимкнути, перейшовши до налаштувань облікового запису в розділі iTunes & App Store у налаштуваннях вашого пристрою. Будь-яка невикористана частина безкоштовного пробного періоду, якщо вона пропонується, буде втрачена, коли користувач придбає підписку, де це можливо.
"""
    
    @State var isYearAccess: Bool = false
    @State var isAlertMessageShow: Bool = false
    @State var alertMessageText: String = ""
    @State var showAlertProgress: Bool = false
    
    private let router: RouterProtocol
    private let persistence: ChatPersistenceProtocol
    
    init(router: RouterProtocol, persistence: ChatPersistenceProtocol) {
        self.router = router
        self.persistence = persistence
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Color("bgColor")
                .ignoresSafeArea()
            RainbowBackgroundView(timeInterval: 2)
            ScrollView {
                Image("image-25")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 350)
                    .mask {
                        LinearGradient(colors: [.black, .black, .clear],
                                       startPoint: .top,
                                       endPoint: .bottom)
                    }
                    .padding(.bottom, -80)
                VStack(alignment: .center, spacing: 20) {
                    HStack {
                        Text("Отримайте Premium акаунт")
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
                            Toggle("Безкоштовний період", isOn: $isYearAccess.not)
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
                            Text("збережи 20%")
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
                                    Text("Річна підписка")
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
                                    Text("3 дні безкоштовно")
                                    Text("Потім 4,99$ на Місяць")
                                }.font(.system(size: 15, weight: .regular, design: .default))
                                Spacer()
                                SelectorView(isSelected: .constant(!isYearAccess))
                            }.padding(16)
                        }
                    })
                    
                    CustomButton(text: isYearAccess ? "Продовжити" : "Безкоштовний період",
                                 flexible: true,
                                 bgColor: .green,
                                 action: {
                        alertMessageText = "Спробувати Premium підписку?"
                        isAlertMessageShow = true
                    })
                    HStack {
                        Image(systemName: "bolt.shield.fill")
                            .foregroundColor(.green)
                        Text("Без сплати зараз")
                    }.padding(.top, -10)
                    
                    HStack {
                        Text("Privacy Policy").underline()
                        Spacer()
                        Text("Resote Purchases").underline()
                        Spacer()
                        Text("Terms of Service").underline()
                    }.font(.system(size: 10, weight: .thin, design: .default))
                        
                    Text(description)
                        .padding(.top, 30)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 14, weight: .thin, design: .default))
                    Spacer(minLength: 70)
                }.padding(.horizontal, 28)
            }.ignoresSafeArea()
            if isAlertMessageShow {
                AlertView(text: alertMessageText, yesClicked: {
                        var settings = persistence.loadSettings()
                        settings.isPremium = true
                        let savedSettings = settings
                        Task {
                            showAlertProgress = true
                            await persistence.saveSettings(savedSettings)
                        }
                    withAnimation {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            isAlertMessageShow = false
                        }
                    }
                }, cancelClicked: {
                    withAnimation {
                        isAlertMessageShow = false
                    }
                }, showProgress: $showAlertProgress)
            }
        }
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
