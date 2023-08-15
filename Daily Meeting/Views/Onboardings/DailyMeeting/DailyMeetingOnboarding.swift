//
//  DailyMeetingOnboarding.swift
//  Daily Meeting
//
//  Created by  Stepanok Ivan on 12.08.2023.
//

import SwiftUI
import OpenAISwift

struct DailyMeetingOnboarding: View {
    
    @State var slidePage: Int = 0
    var onFinish: () -> Void
    
    var body: some View {
        ZStack(alignment: .bottom) {
               
            TabView(selection: $slidePage) {
                ZStack(alignment: .topTrailing) {
                    RadialGradient(colors: [Color.clear,
                                            Color.black.opacity(0.9)],
                                   center: UnitPoint(x: 0.93, y: 0.08),
                                   startRadius: 10,
                                   endRadius: 100)
                    .ignoresSafeArea()
                    Color.clear
                    HStack(alignment: .top) {
                        Text("Якщо вам не сподобалось як розпочався діалог, ви можете перегенерувати початок розмови").padding(16)
                            .font(.system(size: 22, weight: .thin, design: .default))
                            .multilineTextAlignment(.trailing)
                        Image(systemName: "arrowshape.turn.up.backward")
                            .rotationEffect(Angle(degrees: 90))
                    }.padding(.top, 45)
                        .padding(.trailing, 16)
                }.tag(0)
                ZStack {
                    RadialGradient(colors: [Color.clear,
                                            Color.black.opacity(0.9)],
                                   center: UnitPoint(x: 0.5, y: 0.5),
                                   startRadius: 30,
                                   endRadius: 100)
                    .ignoresSafeArea()
                    VStack {
                        Text("Гортайте вправо щоб знайти опис тасок, про які вам треба відчитатись сьогодні.")
                            .font(.system(size: 22, weight: .thin, design: .default))
                            .multilineTextAlignment(.center)
                            .padding(16)
                            .offset(y: 100)
                    }
                }.tag(1)
                ZStack(alignment: .bottomLeading) {
                    RadialGradient(colors: [Color.clear,
                                            Color.black.opacity(0.9)],
                                   center: UnitPoint(x: 0.15, y: 0.925),
                                   startRadius: 0,
                                   endRadius: 100)
                    .ignoresSafeArea()
                    Color.clear
                    HStack(alignment: .bottom) {
                        Image(systemName: "arrowshape.turn.up.backward")
                            .rotationEffect(Angle(degrees: -90))

                        Text("Для того, щоб відповісти на питання, натисніть на цю кнопку. Говоріть голосом. Якщо щось не вийде, зможете відредагувати.").padding(16)
                            .font(.system(size: 22, weight: .thin, design: .default))
                            .multilineTextAlignment(.leading)
                    }.padding(.bottom, 80)
                        .padding(.leading, 50)
                }.tag(2)
                ZStack(alignment: .bottomTrailing) {
                    RadialGradient(colors: [Color.clear,
                                            Color.black.opacity(0.9)],
                                   center: UnitPoint(x: 0.80, y: 0.925),
                                   startRadius: 0,
                                   endRadius: 100)
                    .ignoresSafeArea()
                    Color.clear
                    HStack(alignment: .bottom) {
                       

                        Text("Якщо ви росказали про всі свої таски і в команди більше немає до вас питань, ви можете завершити мітинг.")
                            .padding(.bottom, 16)
                            .padding(.leading, 16)
                            .font(.system(size: 22, weight: .thin, design: .default))
                            .multilineTextAlignment(.trailing)
                        Image(systemName: "arrowshape.turn.up.backward")
                            .rotationEffect(Angle(degrees: -90))
                        .scaleEffect(x: -1, y: 1)
                    }.padding(.bottom, 80)
                        .padding(.trailing, 50)
                }.tag(3)
            }.tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                .ignoresSafeArea()
                .disabled(true)
                
            CustomButton(text: slidePage == 3 ? "Розпочати мітинг" : "Наступна підказка",
                         bgColor: .green,
                         action: { withAnimation {
                if slidePage != 3 {
                    slidePage += 1
                } else {
                    onFinish()
                }
                
            } })
                .padding(26)
        }
    }
}

struct DailyMeetingOnboarding_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Image("onboardDemo")
                .resizable()
                .ignoresSafeArea()
            DailyMeetingOnboarding(onFinish: {
                
            })
        }
    }
}
