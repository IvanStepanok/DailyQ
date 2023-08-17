//
//  ChatScreenView.swift
//  Daily Meeting
//
//  Created by  Stepanok Ivan on 02.08.2023.
//

import SwiftUI
import OpenAISwift
import Combine
import Speech

struct ChatScreenView: View {
    
    @ObservedObject var viewModel: ChatScreenViewModel
    @ObservedObject var openAI: OpenAiManager
    @State var whoSpeak: String = ""
    @State var chatPosition: CGFloat = 200
    @State var showEndCallAlert: Bool = false
    @State var alertProgress: Bool = false
    @State var navigationTitle = ""
    @State var userOnboarded: Bool
    
    private let columns = [GridItem(.adaptive(minimum: UIDevice.current.userInterfaceIdiom == .pad ? 200 : 140,
                                              maximum: UIDevice.current.userInterfaceIdiom == .pad ? 300 : 200))]
    
    init(viewModel: ChatScreenViewModel, openAI: OpenAiManager) {
        self.viewModel = viewModel
        self.openAI = openAI
        self.userOnboarded = viewModel.chatSettings.userOnboarded
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Color("bgColor")
                .ignoresSafeArea()
            RainbowBackgroundView()
            GeometryReader { reader in
                TabView {
                    VStack {
                        LazyVGrid(columns: columns, spacing: 6) {
                            ForEach(Array(viewModel.members.sorted(by: {$0.id < $1.id}).enumerated()),
                                    id: \.offset) { index, user in
                                AvatarView(user: user,
                                           index: openAI.meeting.tasks == nil ? index : 0,
                                           isSpeaking: whoSpeak == user.userName ? $viewModel.isSpeaking : .constant(false))
                            }
                        }.padding(.horizontal, 16)
                        Spacer()
                    }.frame(maxWidth: 600)
                    .onAppear {
                        navigationTitle = openAI.meeting.meetingName
                    }
                    
                    if let tasks = openAI.meeting.tasks {
                        VStack(alignment: .leading) {
                            ScrollView {
                                Text(tasks)
                                    .font(.system(size: 16, weight: .regular, design: .default))
                                    .padding(16)
                            }
                        }.onAppear {
                            navigationTitle = Localized("chatScreenTasks")
                        }
                    }
                    if !userOnboarded {
                        VStack {}
                    }
                }.tabViewStyle(.page)
                    .indexViewStyle(.page(backgroundDisplayMode: .always))
                    .ignoresSafeArea()
                    .frame(height: reader.size.height / 2)
                ChatWindowView(
                    chatHistory: $openAI.chatHistory,
                    chatExpanded: $viewModel.chatExpanded,
                    isLoading: $openAI.isLoading,
                    membersCount: openAI.meeting.members.count,
                    whoSpeak: { if whoSpeak != $0 { whoSpeak = $0 } },
                    isClicked: {
                        viewModel.synthesizer.stopSpeaking(at: .word)
                        viewModel.openVoiceRecognizer = true
                    }, isCancelCallClicked: { showEndCallAlert = true }
                )
            }
            .onAppear {
                if userOnboarded {
                    Task {
                        await openAI.setupChat()
                        await openAI.sendMessage(message: "Start")
                    }
                }
            }
            
            .onChange(of: openAI.chatHistory, perform: { history in
                viewModel.chatResponse = ""
                for message in history {
                    if message.role != .system && message.content != "#You# Start" {
                        viewModel.chatResponse = viewModel.chatResponse + "\n" + message.content + "\n"
                    }
                }
                if let lastMessage = history.last?.content {
                    if openAI.chatHistory.count > 2 {
                        if !lastMessage.contains("#You#") {
                            let speakerName = viewModel.getNameFrom(message: lastMessage)
                            let gender = viewModel.members.first(where: {$0.userName == speakerName})?.isMale
                            if viewModel.chatSettings.voiceOver {
                                viewModel.readTextWithSpeech(lastMessage.removeUsernameAndHashtags(), isMale: gender ?? false)
                            }
                        }
                    }
                }
            })
            if !userOnboarded {
                DailyMeetingOnboarding(onFinish: {
                    Task {
                      var settings = viewModel.chatSettings
                        settings.userOnboarded = true
                        userOnboarded = true
                        await viewModel.persistence.saveSettings(settings)
                        await openAI.setupChat()
                        await openAI.sendMessage(message: "Start")
                    }
                })
            }
            if showEndCallAlert {
                let userResponses = openAI.chatHistory.filter({ $0.role == .user }).count
                AlertView(
                    text: userResponses >= 5 ? Localized("chatScreenEndMeetTitle")
                    : "\(Localized("chatScreenEndMeetText1")) \(5 - userResponses) \(Localized("chatScreenEndMeetText2"))",
                    yesClicked: {
                        alertProgress = true
                        Task {
                            if userResponses >= 5 {
                                let summury = await openAI.getFeedback()
                                viewModel.persistence.saveNewMeetingVisiting()
                                await viewModel.persistence.challengePassed()
                                openAI.meeting.meetingFinishedSuccessfull()
                                viewModel.router.back(animated: false)
                                viewModel.router.finishMeeting(meetingType: openAI.meeting.meetingName, summary: summury)
                            } else {
                                viewModel.persistence.saveNewMeetingVisiting()
                                viewModel.router.back(animated: true)
                            }
                        }
                        
                    }, cancelClicked: { showEndCallAlert = false },
                    showProgress: $alertProgress
                )
            }
        }.navigationBarHidden(false)
            .navigationTitle(navigationTitle)
            .navigationBarBackButtonHidden(openAI.chatHistory.count > 3)
            .sheet(isPresented: $viewModel.openVoiceRecognizer, content: {
                VoiceRecordView(viewModel: VoiceRecordViewModel(),
                                recognitiedText: { message in
                    viewModel.openVoiceRecognizer = false
                    Task {
                        await openAI.sendMessage(message: message)
                    }
                })
            })
            .onDisappear {
                viewModel.synthesizer.stopSpeaking(at: .immediate)
            }
        
    }
}

struct ChatScreenView_Previews: PreviewProvider {
    static var previews: some View {
        let users: [UserSettings] = [
            UserSettings(id: 0,
                         isBot: false,
                         userName: "Ivan Stepanok",
                         avatarName: "avatar-1",
                         userRole: .teamLead,
                         englishLevel: .preIntermediate),
            UserSettings(id: 1,
                         isBot: true,
                         userName: "Igor Kondratuk",
                         avatarName: "avatar-5",
                         userRole: .teamLead,
                         englishLevel: .preIntermediate),
            UserSettings(id: 2,
                         isBot: true,
                         userName: "Natalie Kovalenko",
                         avatarName: "avatar-14",
                         userRole: .backend,
                         englishLevel: .preIntermediate),
            UserSettings(id: 3,
                         isBot: true,
                         userName: "Serhii Dorozhny",
                         avatarName: "avatar-11",
                         userRole: .designer,
                         englishLevel: .preIntermediate)
        ]
        ChatScreenView(viewModel: ChatScreenViewModel(users: users,
                                                      router: RouterMock(),
                                                      persistence: ChatPersistenceMock(), synthesizer: AVSpeechSynthesizer()),
                       openAI: OpenAiManager(meeting: DailyMeeting(persistence: ChatPersistenceMock(), openAI: OpenAISwift(authToken: ""))))
    }
}

struct ChatWindowView: View {
    
    @Binding var chatHistory: [ChatMessage]
    @Binding var chatExpanded: Bool
    @Binding var isLoading: Bool
    @State var expandIndex: Int = 0
    var membersCount: Int
    var whoSpeak: (String) -> Void
    var isClicked: () -> Void
    var isCancelCallClicked: () -> Void
    
    @State var geometry: GeometryProxy?
    
    @State private var currentDragPosition: CGFloat = 0
    @State private var maxHeight: CGFloat = 100
    
    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 30, coordinateSpace: .local)
            .onChanged { value in
                if value.location.y >= 0 && value.location.y <= geometry!.size.height {
                    self.currentDragPosition = value.location.y
                    let halfHeight = geometry!.size.height / maxHeight
                    let maxHeight = geometry!.size.height - 80
                    
                    if value.location.y >= halfHeight && value.location.y <= maxHeight {
                    } else if value.location.y > maxHeight {
                        withAnimation {
                            currentDragPosition = maxHeight
                        }
                    }
                }
            }
            .onEnded { value in
                let halfHeight = geometry!.size.height / maxHeight
                let maxHeight = geometry!.size.height - 80
                if value.location.y <= 100 {
                    withAnimation {
                        currentDragPosition = 1
                    }
                } else if value.location.y > 100 && value.location.y <= maxHeight {
                    withAnimation {
                        currentDragPosition = halfHeight
                    }
                } else if value.location.y > maxHeight + 200 {
                    withAnimation {
                        currentDragPosition = maxHeight
                    }
                }
            }
    }
    
    
    init(chatHistory: Binding<[ChatMessage]>,
         chatExpanded: Binding<Bool>,
         isLoading: Binding<Bool>,
         membersCount: Int,
         whoSpeak:  @escaping (String) -> Void,
         isClicked: @escaping () -> Void,
         isCancelCallClicked: @escaping () -> Void) {
        self._chatHistory = chatHistory
        self._chatExpanded = chatExpanded
        self._isLoading = isLoading
        self.membersCount = membersCount
        self.whoSpeak = whoSpeak
        self.isClicked = isClicked
        self.isCancelCallClicked = isCancelCallClicked
    }
    
    func getName(_ content: String) -> String? {
        //        if content.first == "#" {
        let namePattern = "#(.*?)#"
        let regex = try! NSRegularExpression(pattern: namePattern)
        let range = NSRange(location: 0, length: content.utf16.count)
        if let match = regex.firstMatch(in: content, options: [], range: range) {
            let name = (content as NSString).substring(with: match.range(at: 1))
            //                whoSpeak(name)
            return name
        }
        //        }
        return nil
    }
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                VStack {
                    ZStack(alignment: .top) {
                        RoundedRectangle(cornerRadius: 15)
                            .onAppear {
                                self.geometry = geometry
                                maxHeight = membersCount > 2 ? 1.9 : 3.5
                                currentDragPosition = geometry.size.height / maxHeight
                            }
                            .foregroundColor(Color.white)
                            .ignoresSafeArea()
                        ScrollViewReader { reader in
                            ScrollView {
                                VStack(alignment: .leading, spacing: 10) {
                                    ForEach(chatHistory.filter({ $0.role != .system })) { history in
                                        if history.content != "#You# Start" {
                                            if let name = getName(history.content) {
                                                Text(name)
                                                    .font(.system(size: 16, weight: .semibold, design: .default))
                                                    .foregroundColor(.black)
                                                    .padding(.bottom, -5)
                                                    .onAppear {
                                                        withAnimation {
                                                            reader.scrollTo(1, anchor: .bottom)
                                                        }
                                                    }
                                                let text = history.content
                                                    .replacingOccurrences(of: "#\(name)# ", with: "")
                                                    .replacingOccurrences(of: "#", with: "")
                                                Text(LocalizedStringKey(text))
                                                .font(.system(size: 16, weight: .regular, design: .default))
                                                .foregroundColor(.black)
                                                .multilineTextAlignment(.leading)
                                            } else {
                                                Text(history.content)
                                                    .font(.system(size: 16, weight: .regular, design: .default))
                                                    .foregroundColor(.black)
                                                    .multilineTextAlignment(.leading)
                                            }
                                        }
                                    }
                                    VStack{}.id(1)
                                }.padding(26)
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(.circular)
                                        .colorInvert()
                                }
                            }.padding(.top, 8)
                            ZStack {
                                HStack(spacing: 0) {
                                    Button(action: {
                                        isClicked()
                                    }, label: {
                                        ZStack {
                                            Circle()
                                                .frame(width: 60, height: 60)
                                                .foregroundColor(.green)
                                            Image(systemName: "mic.fill")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 20)
                                                .foregroundColor(.white)
                                        }
                                    })
                                    Spacer()
                                    Button(action: {
                                        isCancelCallClicked()
                                    }, label: {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 30)
                                                .frame(width: 90, height: 60)
                                                .foregroundColor(Color("redColor"))
                                            Image(systemName: "phone.down.fill")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 30)
                                                .foregroundColor(.white)
                                        }
                                    })
                                }.padding(.horizontal, 30)
                            }.background(Color.white.cornerRadius(15).ignoresSafeArea())
                            //                                .offset(y: -currentDragPosition)
                            
                            
                            
                        }
                        ZStack {
                            RoundedRectangle(cornerRadius: 6)
                                .frame(width: 60, height: 6)
                                .foregroundColor(.gray.opacity(0.7))
                                .padding(.top, 8)
                        }
                    }.offset(y: currentDragPosition)
                        .gesture(dragGesture)
                }.frame(height: geometry.size.height - currentDragPosition)
            }
        }.onChange(of: chatHistory, perform: { messages in
            guard let lastMessage = messages.last,
                  let name = getName(lastMessage.content)  else { return }
            whoSpeak(name)
        })
    }
}

extension String {
    func removeUsernameAndHashtags() -> String {
        var cleanedContent = self
        let namePattern = "#(.*?)#"
        let regex = try! NSRegularExpression(pattern: namePattern)
        let range = NSRange(location: 0, length: self.utf16.count)
        
        if let match = regex.firstMatch(in: self, options: [], range: range) {
            let matchedText = (self as NSString).substring(with: match.range)
            if self.hasPrefix(matchedText) {
                cleanedContent = self.replacingOccurrences(of: matchedText, with: "")
            }
        }
        
        return cleanedContent.trimmingCharacters(in: .whitespaces)
    }
}
