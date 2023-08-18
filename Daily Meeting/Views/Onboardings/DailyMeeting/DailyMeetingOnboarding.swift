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
            Color.black.opacity(0.01)
            TabView(selection: $slidePage) {
                ZStack(alignment: .center) {
                    Color.black.opacity(0.9)
                    .ignoresSafeArea()
                    Color.clear
                        Text(Localized("onBoarding1")).padding(16)
                            .font(.system(size: 22, weight: .thin, design: .default))
                            .multilineTextAlignment(.center)
                }.tag(0)
                ZStack {
                    RadialGradient(colors: [Color.clear,
                                            Color.black.opacity(0.9)],
                                   center: UnitPoint(x: 0.5, y: 0.3),
                                   startRadius: 150,
                                   endRadius: 250)
                    .ignoresSafeArea()
                    VStack {
                        Text(Localized("onBoarding2"))
                            .font(.system(size: 22, weight: .thin, design: .default))
                            .multilineTextAlignment(.center)
                            .padding(16)
                            .offset(y: 200)
                    }.ipadWidthLimit()
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

                        Text(Localized("onBoarding3")).padding(16)
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
                       

                        Text(Localized("onBoarding4"))
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
                .indexViewStyle(.page(backgroundDisplayMode: .never))
                .ignoresSafeArea()
                .disabled(true)
                
            CustomButton(text: slidePage == 3 ?
                         
                         Localized("startMeeting")
                         : Localized("nextHint"),
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
