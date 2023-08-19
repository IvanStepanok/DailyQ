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
                                 showWinnerAnimation: persistence.getTodayMeetingVisited() > 1)
                    Spacer(minLength: 60)
                    
                    HStack {
                        Text(Localized("completedSummary"))
                            .multilineTextAlignment(.leading)
                            .font(.system(size: 16, weight: .regular, design: .default))
                            .padding(.leading, 14)
                        Spacer()
                    }
                    ZStack(alignment: .bottom) {
                            Text(LocalizedStringKey(summary))
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
                            Text(LocalizedStringKey(summary)).blur(radius: 3)
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
1) Hey hello team, I finished task number one yesterday. I had to pay a fine for a few bucks and fixed them.\n\nOriginal: Hey hello team, I finished task number one yesterday. I had to pay a fine for a few bucks and fixed them.\nCorrected: Hello team, I finished task number one yesterday. I had to pay a fine of a few bucks and fixed it.\nExplanation: The greeting \"Hey hello\" is not commonly used in formal or professional communication. Also, instead of saying \"fixed them,\" it should be \"fixed it\" since the fine is a singular item.\n\n2) That task number two is very broad, I need more specific knowledge about this task. First, I need a design. Is Sophia\'s design ready?\n\nOriginal: That task number two is very broad, I need more specific knowledge about this task. First, I need a design. Is Sophia\'s design ready?\nCorrected: Task number two is very broad, I need more specific information about this task. Firstly, I need a design. Is Sophia\'s design ready?\nExplanation: Instead of saying \"That task number two,\" it should be \"Task number two\" for clarity and correctness. \"First\" should be changed to \"Firstly\" for better sentence structure.\n\n3) Sophia?\nOriginal: Sophia?\nCorrected: Sophia?\nExplanation: No mistake made.\n\n4) No, I will be waiting for Sophia. But today I can start task number three. I will go to the comment section on the App Store and read the feedback. I hope users\' feedback will help me propose new features.\n\nOriginal: No, I will be waiting for Sophia. But today I can start task number three. I will go to the comment section on the App Store and read the feedback. I hope users\' feedback will help me propose new features.\nCorrected: No, I will wait for Sophia, but today I can start task number three. I will go to the comment section of the App Store and read the feedback. I hope the users\' feedback will help me propose new features.\nExplanation: Instead of saying \"I will be waiting,\" it should be \"I will wait.\" Also, \"on\" should be changed to \"of\" in \"the comment section on the App Store\" for correct preposition usage.\n\n5) Sophia, Are you still not here right now?\n\nOriginal: Sophia, Are you still not here right now?\nCorrected: Sophia, are you not here yet?\nExplanation: The phrase \"right now\" is not necessary as \"yet\" already implies the present moment. Also, the word \"still\" is not needed for clarity.\n\n6) Yes, Danielle?\n\nOriginal: Yes, Danielle?\nCorrected: Yes, Danielle?\nExplanation: No mistake made.\n\n7) Sorry, Danielle. My bad.\n\nOriginal: Sorry, Danielle. My bad.\nCorrected: Sorry, Danielle. It\'s my fault.\nExplanation: Instead of saying \"My bad,\" it is more formal to say \"It\'s my fault.\"\n\n8) Not right now, I will start task number three today.\n\nOriginal: Not right now, I will start task number three today.\nCorrected: Not right now, I will start task number three later today.\nExplanation: Adding \"later\" clarifies that the task will be started at a future time on the same day."))
""", persistence: ChatPersistenceMock(), router: RouterMock())
    }
}
