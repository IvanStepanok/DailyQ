//
//  MainView.swift
//  Daily Meeting
//
//  Created by  Stepanok Ivan on 06.08.2023.
//

import SwiftUI
import Swinject
import OpenAISwift

class MainViewModel: ObservableObject {
    
    @Published var timeLeftString: String?
    let targetTime: TimeInterval = 24 * 60 * 60
    @Published private var timer: Timer?
    let persistence: ChatPersistenceProtocol
    let router: RouterProtocol
    let currentUser: UserSettings?
    let members: [UserSettings]
    let meetings: [LessonType] = [.dailyMeeting, .techInterview, .salaryReview]
    let openAI: OpenAISwift
    
    // DELETE ME
    var bgImages: [String] = [
        "image-12",
        "image-13",
        "image-14",
        "image-15",
        "image-19",
        "image-20",
        "image-21",
        "image-22",
        "image-24",
        "image-25",
        "image-26"
    ]
    
    @Published var bgIndex: Int = 0
    
    
    init(persistence: ChatPersistenceProtocol, router: RouterProtocol, openAI: OpenAISwift) {
        self.persistence = persistence
        self.router = router
        self.members = persistence.loadAllUsersSettings()
        self.currentUser = members.first(where: {$0.isBot == false})
        self.openAI = openAI
        startTimer()
        print(">>>>> SETTINGS", persistence.loadSettings())
        print(">>>>> SETTINGS", persistence.loadSettings().userCanVisit)

    }
    
    enum LessonType {
        case dailyMeeting
        case techInterview
        case salaryReview
        
        func meeting(persistence: ChatPersistenceProtocol, openAI: OpenAISwift) -> MeetingProtocol {
#if DEBUG
            switch self {
            case .dailyMeeting:
                return DailyMeeting(persistence: ChatPersistenceMock(), openAI: OpenAISwift(authToken: ""))
            case .techInterview:
                return TechInterview(persistence: ChatPersistenceMock(), openAI: OpenAISwift(authToken: ""))
            case .salaryReview:
                return SalaryReview(persistence: ChatPersistenceMock(), openAI: OpenAISwift(authToken: ""))
            }
#else
            switch self {
            case .dailyMeeting:
                return Container.shared.resolve(DailyMeeting.self)!
            case .techInterview:
                return Container.shared.resolve(TechInterview.self)!
            case .salaryReview:
                return Container.shared.resolve(SalaryReview.self)!
            }
#endif
        }
        
        func title() -> String {
            switch self {
            case .dailyMeeting:
                return "Daily meeting with team"
            case .techInterview:
                return "Technical job interview"
            case .salaryReview:
                return "Salary review"
            }
        }
        
        func description() -> String {
            switch self {
            case .dailyMeeting:
                return "Щоденні мітинги з командою для відточення навиків обговореня виконаних та поточних задач."
            case .techInterview:
                return "Підготуйся до технічного інтервʼю і дізнайся про свої сильні і слабкі сторони."
            case .salaryReview:
                return "Давай перевіримо, чи готові ви до підвищення?"
            }
        }
        
        func members(currentUser: UserSettings?) -> [String] {
            switch self {
            case .dailyMeeting:
                return ["avatar_0", "avatar_1", "avatar_2", "avatar_3"]
            case .techInterview:
                return [currentUser?.avatarName ?? "avatar_12", "avatar_12"]
            case .salaryReview:
                return ["avatar_0", "avatar_1", "avatar_2"]
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
        var settings = persistence.loadSettings()
        settings.meetingsVisited += 1
        settings.lastMeetingDate = Date()
        let save = settings
        Task {
            await persistence.saveSettings(save)
        }
    }

    private var timeFormatter: DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }
    
    private func startTimer() {
        if !persistence.loadSettings().userCanVisit {
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
                ZStack(alignment: .topTrailing) {
                    Image(viewModel.bgImages[viewModel.bgIndex])
                        .resizable()
                        .scaledToFill()
                        .onTapGesture {
                            if viewModel.bgIndex < viewModel.bgImages.count-1 {
                                viewModel.bgIndex += 1
                            } else {
                                viewModel.bgIndex = 0
                            }
                        }
                    //                    .offset(y: 40)
                    //                    .frame(height: 250)
                        .mask {
                            LinearGradient(colors: [.black, .black, .clear],
                                           startPoint: .top,
                                           endPoint: .bottom)
                        }
                        .padding(.bottom, -200)
                    Button(action: {
                        
                    }, label: {
                        HStack {
                            Text("Доступні нові цілі!")
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
                    
                    .padding(.horizontal, 24)
                    .padding(.top, 40)
                }
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Text("Ваші мітинги:")
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
                                     membersAvatars: meeting.meeting(persistence: self.viewModel.persistence, openAI: self.viewModel.openAI).members.map({ $0.avatarName ?? "" }),
                                     timeLeft: $viewModel.timeLeftString,
                                     buttonClicked: {
                                if !viewModel.persistence.loadSettings().userCanVisit {
                                    if meeting != .dailyMeeting && !viewModel.persistence.loadSettings().isPremium {
                                        showPremium = true
                                    } else {
                                        if meeting == .dailyMeeting {
                                            alertText = "Ви вже скористались безкоштовним мітингом. Наступний буде доступний через \(viewModel.timeLeftString?.dropLast(3) ?? "") \n \n Спробувати Premium?"
                                        } else {
                                            alertText = "Цей контент доступний лише для Premium акаунтів. Бажаєте спробувати?"
                                        }
                                        showPremium = true
                                    }
                                } else {
                                    viewModel.visitFreeMeeting()
                                    meeting.router(viewModel.router,
                                                   persistence: viewModel.persistence,
                                                   openAI: viewModel.openAI)
                                }
                            })
                        }
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
                            Text("Щоденні челенджі")
                                .padding(.leading, 12)
                                .padding(.bottom, 12)
                                .foregroundStyle(.white)
                                .font(.system(size: 18, weight: .light, design: .default))

                            CalendarView()
                        }.padding(16)
                    }
                    Spacer(minLength: 20)
                    HStack {
                        Text("Загальна статистика")
                            .padding(.leading, 16)
                            .font(.system(size: 26, weight: .light, design: .default))
                        Spacer()
                    }
                    
                    UserStatistic(data:
                                    ["Мітингів пройдено": "13",
                                     "Технічних інтервʼю": "34",
                                     "Переглядів зарплати": "2"
                                    ])
                    Spacer(minLength: 70)
                }.padding(24)
            }.ignoresSafeArea()
            if showPremium {
                AlertView(text: alertText,
                          yesClicked: { showPremium = false
                    viewModel.router.showPremiumView()
                },
                          cancelClicked: { showPremium = false })
            }
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

                    Text(isPremium ? "Преміум" : "Безкоштовно")
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
                                Text("Залишилось: \(timeLeft)")
                                    .font(.system(size: 10, weight: .regular, design: .default))
                            }
                        }
                        CustomButton(text: "Приєднатися", action: {
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
