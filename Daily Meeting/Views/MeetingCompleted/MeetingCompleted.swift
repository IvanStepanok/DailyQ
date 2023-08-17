//
//  MeetingCompleted.swift
//  Daily Meeting
//
//  Created by  Stepanok Ivan on 07.08.2023.
//

import SwiftUI
import ConfettiSwiftUI

struct MeetingCompleted: View {
    
    @State var counter: Int = 0
    @State var isLoaded: Bool = false
    @State var isPremium: Bool = false
    
    var meetingType: String
    var summary: String
    
    let persistence: ChatPersistenceProtocol
    let router: RouterProtocol
    
    init(meetingType: String, summary: String, persistence: ChatPersistenceProtocol, router: RouterProtocol) {
        self.router = router
        self.persistence = persistence
        self.meetingType = meetingType
        self.summary = summary
        startConfetti()
    }
    
    func startConfetti() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            self.counter = 1
        }
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Color("bgColor")
                .ignoresSafeArea()
            RainbowBackgroundView(timeInterval: 2)
//            Color.
//                .ignoresSafeArea()
//                .opacity(isLoaded ? 0 : 1)
                .confettiCannon(counter: $counter,
                                num: 50,
                                confettiSize: 15,
                                closingAngle: .radians(20),
                                radius: 200
                )
                .scaleEffect(2)
                .blur(radius: 10)
            ScrollView {
                VStack {
                    HStack {
                        Spacer()
                    }
                    VStack(alignment: .center, spacing: 14) {
                        ZStack {
                            Circle()
                                .frame(width: 120)
                                .foregroundColor(.white)
                                .blur(radius: 40)
                            HStack {
                                Text("🏆")
                                    .font(.system(size: isLoaded ? 140 : 0, weight: .ultraLight, design: .default))
                                    .confettiCannon(counter: $counter,
                                                    num: 50,
                                                    confettiSize: 15,
                                                    closingAngle: .radians(60),
                                                    radius: 300
                                    )
                            }
                                .onAppear {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        withAnimation(Animation.spring(response: 1, dampingFraction: 0.2, blendDuration: 1)) {
                                            isLoaded = true
                                        }
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                                        counter += 1
                                    }
                                }
                        }
                        
                        
                        .onTapGesture {
                                counter += 1
                        }
                        Text(Localized("completedCongratsTitle"))
                            .font(.system(size: 46, weight: .ultraLight, design: .default))
                    }
                    Text("\(Localized("completedCompleted1")) \(meetingType)\(Localized("completedCompleted2"))")
                        .multilineTextAlignment(.center)
                        .font(.system(size: 16, weight: .regular, design: .default))
                    Spacer(minLength: 60)
                    CalendarView(winnerDates: persistence.challengeDates(),
                                 showWinnerAnimation: true)
                    Spacer(minLength: 60)
                    
                    HStack {
                        Text(Localized("completedSummary"))
                            .multilineTextAlignment(.leading)
                            .font(.system(size: 16, weight: .regular, design: .default))
                            .padding(.leading, 14)
                        Spacer()
                    }
                    ZStack(alignment: .bottom) {
                            Text(summary)
                                .font(.system(size: 16, weight: .thin, design: .default))
                                .padding(14)
                                .mask {
                                    LinearGradient(
                                        colors: isPremium
                                        ? [Color.black]
                                        : [Color.clear, Color.clear, Color.clear, Color.black],
                                        startPoint: .bottom,
                                        endPoint: .top)
                                }
                        if !isPremium {
                            Text(summary).blur(radius: 3)
                                .font(.system(size: 16, weight: .thin, design: .default))
                                .foregroundColor(.gray)
                                .padding(14)
                                .mask {
                                    LinearGradient(colors: [Color.black, Color.black, Color.clear], startPoint: .bottom, endPoint: .top)
                                }
                        }
                    }.overlay(
                            ZStack(alignment: .center) {
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(lineWidth: 1)
                                    .fill(.white.opacity(0.1))
                                if !isPremium {
                                    CustomButton(text: Localized("completedGetFullReview"),
                                                 bgColor: .green, action: {
                                        router.dismiss(animated: false)
                                        router.showPremiumView()
                                    })
                                }
                        }
                    )
//                    }
                    
                    
                    Spacer(minLength: 60)
                }.padding(.horizontal, 24)
                    .ipadWidthLimit()
                       
            }
        }.navigationBarHidden(false)
            .navigationTitle("")
            .onAppear {
                isPremium = persistence.loadSettings().isPremium
            }
    }
}

struct MeetingCompleted_Previews: PreviewProvider {
    static var previews: some View {
        MeetingCompleted(meetingType: "Daily Meeting", summary: """
Здається, ви робите декілька помилок у ваших фразах. Давайте розглянемо їх:

"You: Hi Sophia, Yesterday I was finish task number 773, So today I get no tasks so I am ready to work. Did you have any tasks for me?"
Правильний варіант: "Hi Sophia, yesterday I finished task number 773, so today I don't have any tasks, and I am ready to work. Do you have any tasks for me?"
У фразі "Yesterday I was finish" слід використовувати "I finished", оскільки "was finish" - неправильний часовий аспект.
У фразі "So today I get no tasks" більш коректно звучатиме "so today I don't have any tasks".
Замість "Did you have any tasks for me?" використовуйте "Do you have any tasks for me?", оскільки це питання в Present Simple.
"You: Yeah Ava, What about settings screen, Is it ready?"
Правильний варіант: "Yeah, Ava, what about the settings screen? Is it ready?"
У фразі слід розділити запитання від ремарки до Ави комами, та використовувати з малої літери слово "what" (запитання).
"You: Could you please add some animations the login screen?"
Правильний варіант: "Could you please add some animations to the login screen?"
У фразі слід додати перед словом "to" (пропущена передача напрямку дії).
Загалом, у вас є невеликі помилки, але ви вже дуже близькі до коректного використання англійської мови.
""", persistence: ChatPersistenceMock(), router: RouterMock())
    }
}
