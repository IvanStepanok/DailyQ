//
//  MainView.swift
//  Daily Meeting
//
//  Created by  Stepanok Ivan on 06.08.2023.
//

import SwiftUI
import Swinject
import OpenAISwift
import KeychainSwift

class MainViewModel: ObservableObject {
    
    @Published var timeLeftString: String?
    let targetTime: TimeInterval = 24 * 60 * 60
    @Published private var timer: Timer?
    @Published var refreshPage: Bool = true
    let persistence: ChatPersistenceProtocol
    let router: RouterProtocol
    let currentUser: UserSettings?
    let members: [UserSettings]
    let meetings: [LessonType] = [.dailyMeeting, .techInterview, .salaryReview]
    let openAI: OpenAISwift
    var settings: ChatSettings
    
    // DELETE ME
    var bgImages: [String] = [
        "bg12",
        "bg13",
        "bg17",
        "bg24",
        "bg26",
        "bg27",
        "bg28",
        "bg31",
        "bg39",
        "bg40",
        "bg41",
        "bg42",
        "bg52",
        "bg55",
        "bg57",
        "bg60",
    ]
    
    @Published var bgIndex: Int
    
    
    init(persistence: ChatPersistenceProtocol, router: RouterProtocol, openAI: OpenAISwift) {
        self.persistence = persistence
        self.router = router
        self.members = persistence.loadAllUsersSettings()
        self.currentUser = members.first(where: {$0.isBot == false})
        self.openAI = openAI
        self.settings = persistence.loadSettings()
        self.bgIndex = self.settings.bgImageIndex
        startTimer()
    }
    
    enum LessonType {
        case dailyMeeting
        case techInterview
        case salaryReview
        
        func meeting(persistence: ChatPersistenceProtocol, openAI: OpenAISwift) -> MeetingProtocol {
//#if DEBUG
//            switch self {
//            case .dailyMeeting:
//                return DailyMeeting(persistence: ChatPersistenceMock(), openAI: OpenAISwift(authToken: ""))
//            case .techInterview:
//                return TechInterview(persistence: ChatPersistenceMock(), openAI: OpenAISwift(authToken: ""))
//            case .salaryReview:
//                return SalaryReview(persistence: ChatPersistenceMock(), openAI: OpenAISwift(authToken: ""))
//            }
//#else
//            if refreshPage {
                switch self {
                case .dailyMeeting:
                    return Container.shared.resolve(DailyMeeting.self)!
                case .techInterview:
                    return Container.shared.resolve(TechInterview.self)!
                case .salaryReview:
                    return Container.shared.resolve(SalaryReview.self)!
                }
//            } else {
//                switch self {
//                case .dailyMeeting:
//                    return Container.shared.resolve(DailyMeeting.self)!
//                case .techInterview:
//                    return Container.shared.resolve(TechInterview.self)!
//                case .salaryReview:
//                    return Container.shared.resolve(SalaryReview.self)!
//                }
//            }
//#endif
        }
        
        func title() -> String {
            switch self {
            case .dailyMeeting:
                return Localized("mainViewDailyMeetingTitle")
            case .techInterview:
                return Localized("mainViewTechInterviewTitle")
            case .salaryReview:
                return Localized("mainViewSalaryReviewTitle")
            }
        }
        
        func description() -> String {
            switch self {
            case .dailyMeeting:
                return Localized("mainViewDailyMeetingDesc")
            case .techInterview:
                return Localized("mainViewTechInterviewDesc")
            case .salaryReview:
                return Localized("mainViewSalaryReviewDesc")
            }
        }
        
        func isPremium() -> Bool {
            switch self {
            case .dailyMeeting:
                return false
            case .techInterview:
                return true
            case .salaryReview:
                return true
            }
        }
        
        func router(_ router: RouterProtocol, persistence: ChatPersistenceProtocol, openAI: OpenAISwift) {
            switch self {
            case .dailyMeeting:
                router.showMeetingView(meeting: DailyMeeting(persistence: persistence, openAI: openAI))
            case .techInterview:
                router.showMeetingView(meeting: TechInterview(persistence: persistence, openAI: openAI))
            case .salaryReview:
                router.showMeetingView(meeting: SalaryReview(persistence: persistence, openAI: openAI))
            }
        }
    }
    
    func visitFreeMeeting() {
        persistence.saveNewMeetingVisiting()
    }

    private var timeFormatter: DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }
    
    private func startTimer() {
        if !persistence.loadSettings().isPremium && persistence.getTodayMeetingVisited() > 1 {
            let now = Date().timeIntervalSince1970
            let calendar = Calendar.current
            
            if let tomorrow = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: Date())?.timeIntervalSince1970 {
                let timeUntilTomorrow = tomorrow + targetTime - now
                if timeUntilTomorrow > 0 {
                    timeLeftString = timeFormatter.string(from: timeUntilTomorrow) ?? ""
                    
                    timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
                        guard let self else { return }
                        let now = Date().timeIntervalSince1970
                        let timeUntilTomorrow = tomorrow + targetTime - now
                        if timeUntilTomorrow > 0 {
                            timeLeftString = timeFormatter.string(from: timeUntilTomorrow) ?? ""
                        } else {
                            timer.invalidate()
                        }
                    }
                }
            }
        }
    }

        private func stopTimer() {
            timer?.invalidate()
        }
}

struct MainView: View {
    
    @ObservedObject private var viewModel: MainViewModel
    @State var showPremium: Bool = false
    @State var showDailyChallengesAlert: Bool = false
    @State var alertText: String = ""
    
    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color("bgColor")
                .ignoresSafeArea()
            RainbowBackgroundView(timeInterval: 2)
            ScrollView {
                ZStack {
                    Image(viewModel.bgImages[viewModel.bgIndex])
                        .resizable()
                        .scaleEffect(2.4)
                        .blur(radius: 100)
                        .scaledToFit()
                    ZStack(alignment: .topTrailing) {
                        Image(viewModel.bgImages[viewModel.bgIndex])
                            .resizable()
                            .scaledToFit()
                            .offset(y: -30)
                            .onTapGesture {
                                if viewModel.bgIndex < viewModel.bgImages.count-1 {
                                    self.viewModel.bgIndex += 1
                                    Task {
                                        self.viewModel.settings.bgImageIndex = viewModel.bgIndex
                                        print(self.viewModel.settings)
                                        await self.viewModel.persistence.saveSettings(self.viewModel.settings)
                                    }
                                } else {
                                    self.viewModel.bgIndex = 0

                                    Task {
                                        self.viewModel.settings.bgImageIndex = viewModel.bgIndex
                                        await self.viewModel.persistence.saveSettings(self.viewModel.settings)
                                    }
                                }
                            }
                        //                    .offset(y: 40)
                        //                    .frame(height: 250)
                            .mask {
                                LinearGradient(colors: [.black, .black, .clear],
                                               startPoint: .top,
                                               endPoint: .bottom)
                                .offset(y: -30)
                            }
                        if viewModel.persistence.getTodayMeetingVisited() == 0 {
                            VStack(alignment: .trailing) {
                                Button(action: {
                                    showDailyChallengesAlert = true
                                }, label: {
                                    HStack {
                                        Text(Localized("mainViewDailyChallenge"))
                                            .font(.system(size: 15, weight: .semibold, design: .default))
                                            .shadow(color: .black, radius: 20, x: 0, y: 0)
                                        Text("⭐️")
                                            .font(.system(size: 18, weight: .regular, design: .default))
                                            .font(.headline)
                                            .frame(width: 36, height: 36)
                                            .background(.white.opacity(0.1))
                                            .foregroundColor(.white)
                                            .clipShape(Circle())
                                            .overlay(
                                                Circle()
                                                    .stroke(lineWidth: 1)
                                                    .fill(.white.opacity(0.2))
                                            )
                                            .overlay {
                                                ZStack {
                                                    Circle()
                                                        .frame(width: 16)
                                                        .foregroundColor(.red)
                                                    Text("1")
                                                        .font(.system(size: 12, weight: .semibold, design: .default))
                                                }.offset(x: 15, y: -15)
                                            }
                                    }
                                })
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 40)
                        }
                    }
                }                        .padding(.bottom, -200)

                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Text(Localized("mainViewYourMeetings"))
                            .shadow(color: .black, radius: 5, x: 0, y: 0)
                            .padding(.leading, 16)
                            .font(.system(size: 46, weight: .ultraLight, design: .default))
                        Spacer()
                        Button(action: {
                            viewModel.router.showSettingsView()
                        }, label: {
                            ZStack {
                                VisualEffectView(effect: UIBlurEffect(style: .dark))
                                                                .cornerRadius(18)
                                    .foregroundStyle(Color("secondaryColor"))
                                    .frame(width: 36, height: 36)
                                Image(systemName: "gearshape")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20)
                                    
                                    .foregroundStyle(.white)
                            }.padding(.bottom, -6)
                        })
                    }
//                    Spacer(minLength: 20)
                    LazyVStack {
                        ForEach(viewModel.meetings, id: \.self) { meeting in
                            MeetView(title: meeting.title(),
                                     description: meeting.description(),
                                     isPremium: meeting.isPremium(),
                                     membersAvatars: meeting.meeting(persistence: self.viewModel.persistence,
                                                                     openAI: self.viewModel.openAI).members.map({ $0.avatarName ?? "" }),
                                     timeLeft: viewModel.settings.isPremium ? .constant(nil) : $viewModel.timeLeftString,
                                     buttonClicked: {
                                if viewModel.settings.isPremium {
                                    if viewModel.persistence.getTodayMeetingVisited() < 10 {
                                        meeting.router(viewModel.router,
                                                       persistence: viewModel.persistence,
                                                       openAI: viewModel.openAI)
                                    } else {
                                        alertText = Localized("mainViewTeamIsTired")
                                        showPremium = true
                                    }
                                } else {
                                    switch meeting {
                                    case .dailyMeeting:
                                        if viewModel.persistence.getTodayMeetingVisited() < 1 {
                                            meeting.router(viewModel.router,
                                                           persistence: viewModel.persistence,
                                                           openAI: viewModel.openAI)
                                        } else {
                                            alertText = Localized("mainViewFreeMeetingPassed")
                                            showPremium = true
                                        }
                                    case .techInterview, .salaryReview:
                                        alertText = Localized("mainViewPremiumOnly")
                                        showPremium = true
                                    }
                                }
                            })
                        }
                    }.onAppear {
                        viewModel.refreshPage.toggle()
                        viewModel.settings = viewModel.persistence.loadSettings()
                    }
                    
                    Spacer(minLength: 20)
                    ZStack {
                        Color.clear
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(lineWidth: 1)
                                    .fill(.white.opacity(0.1))
                            )
                        VStack {
                            Text(Localized("mainViewDailyChallenges"))
                                .padding(.leading, 12)
                                .padding(.bottom, 12)
                                .foregroundStyle(.white)
                                .font(.system(size: 18, weight: .light, design: .default))
                            CalendarView(winnerDates: viewModel.persistence.challengeDates(), showWinnerAnimation: false)
                        }.padding(16)
                    }
                    Spacer(minLength: 20)
                    HStack {
                        Text(Localized("mainViewUserStatistic"))
                            .padding(.leading, 16)
                            .font(.system(size: 26, weight: .light, design: .default))
                        Spacer()
                    }
                    
                    UserStatistic(data:
                                    [Localized("mainViewStatDaily"): "\(viewModel.settings.dailyMeetingsCompleted)",
                                     Localized("mainViewStatTech"): "\(viewModel.settings.techInterviewsCompleted)",
                                     Localized("mainViewStatPerf"): "\(viewModel.settings.salaryReviewsCompleted)"
                                    ])
                    Spacer(minLength: 70)
                }.padding(24)
                    .ipadWidthLimit()
            }.ignoresSafeArea()
            if showPremium {
                AlertView(text: alertText,
                          yesClicked: { showPremium = false
                    viewModel.router.showPremiumView()
                },
                          cancelClicked: { showPremium = false })
            }
            if showDailyChallengesAlert {
                AlertView(text: Localized("mainViewDailyChallengeDesc"),
                          yesClicked: {
                    showDailyChallengesAlert = false
                    viewModel.router.showMeetingView(meeting: DailyMeeting(
                        persistence: viewModel.persistence,
                        openAI: viewModel.openAI))
                },
                          cancelClicked: { showDailyChallengesAlert = false })
            }
            AdminPanelView(content: {
                Text(viewModel.settings.isPremium ? "Premium" : "Free")
                Text("Visited: \(viewModel.persistence.getTodayMeetingVisited())")
                Button("change Premium", action: {
                    viewModel.settings.isPremium.toggle()
                    Task {
                        await viewModel.persistence.saveSettings(viewModel.settings)
                        viewModel.settings = viewModel.persistence.loadSettings()
                    }
                    viewModel.refreshPage.toggle()
                }).padding(1).background(RoundedRectangle(cornerRadius: 2).foregroundColor(.black.opacity(0.4)))
                
                Button("Add visit", action: {
                    viewModel.persistence.saveNewMeetingVisiting()
                    viewModel.refreshPage.toggle()
                }).padding(1).background(RoundedRectangle(cornerRadius: 2).foregroundColor(.black.opacity(0.4)))
                
                Button("Reset views", action: {
                    KeychainSwift().set("0", forKey: "visitedMeetings")
                    viewModel.refreshPage.toggle()
                }).padding(1).background(RoundedRectangle(cornerRadius: 2).foregroundColor(.black.opacity(0.4)))
                
                Button("Reset onBoarding", action: {
                    viewModel.settings.userOnboarded.toggle()
                    Task {
                        await viewModel.persistence.saveSettings(viewModel.settings)
                        viewModel.settings = viewModel.persistence.loadSettings()
                    }
                    viewModel.refreshPage.toggle()
                }).padding(1).background(RoundedRectangle(cornerRadius: 2).foregroundColor(.black.opacity(0.4)))
            })
        }.navigationBarHidden(true)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(viewModel: MainViewModel(persistence: ChatPersistenceMock(),
                                          router: RouterMock(),
                                          openAI: OpenAISwift(authToken: "")))
    }
}

struct MeetView: View {
    
    var title: String
    var description: String
    var isPremium: Bool
    var membersAvatars: [String]
    @Binding var timeLeft: String?
    var buttonClicked: () -> Void
    
    
    var body: some View {
        ZStack {
//            Color.black.opacity(0.1)
            VisualEffectView(effect: UIBlurEffect(style: .regular))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(lineWidth: 1)
                        .fill(.white.opacity(0.1))
                )
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(title)
                        .font(.system(size: 15, weight: .semibold, design: .default))
                    Spacer()

                    Text(isPremium ? Localized("mainViewPremium") : Localized("mainViewFree"))
                        .opacity(0.5)
                        .font(.system(size: 15, weight: .light, design: .default))
                        .padding(.vertical, 4)
                }
                Text(description)
                    .font(.system(size: 13, weight: .thin, design: .default))
                Spacer()
                HStack(spacing: -20) {
                    ForEach(Array(membersAvatars.enumerated()), id: \.offset) { _, avatar in
                        Avatar(image: avatar)
                    }
                    
                    Spacer()
                    VStack(alignment: .center) {
                        if !isPremium {
                            if let timeLeft {
                                Text("\(Localized("mainViewTimeLeft")) \(timeLeft)")
                                    .font(.system(size: 10, weight: .regular, design: .default))
                            }
                        }
                        CustomButton(text: Localized("mainViewConnect"), action: {
                            buttonClicked()
                        })
                    }
                }.frame(minHeight: 60)
            }.padding(16)
            
            
        }//.frame(height: 160)
    }
}

struct Avatar: View {
    
var image: String
    
    var body: some View {
        ZStack {
            Circle()
                .foregroundColor(.white)
                
            Image(image)
                .resizable()
                .scaledToFit()
                .clipShape(Circle())
                .frame(width: 49)
        }.frame(width: 50)
    }
    
}

struct UserStatistic: View {
    
    var data: [String: String]
    
    var body: some View {
        ZStack {
            LazyVStack(spacing: 10) {
                ForEach (Array(data.enumerated()), id: \.offset) { index, data in
                    HStack {
                        Text(data.key)
                            .font(.system(size: 16, weight: .thin, design: .default))
                        Spacer()
                        Text(data.value)
                    }
                }
            }.padding(.horizontal, 16)
        }
    }
}
