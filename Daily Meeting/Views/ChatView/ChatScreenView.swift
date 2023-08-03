//
//  ChatScreenView.swift
//  Daily Meeting
//
//  Created by  Stepanok Ivan on 02.08.2023.
//

import SwiftUI
import OpenAISwift
import Combine
import OSSSpeechKit
import Speech

struct ChatScreenView: View {
    
    private let columns = [GridItem(.adaptive(minimum: 140, maximum: 200))]
    @State var chatResponse: String = ""
    @State var userMessage: String = ""
    @State var chatExpanded: Bool = false
    @State var openVoiceRecognizer: Bool = false
    @State var isSpeaking: Bool = false
    private let router: Router
    
    @ObservedObject private var openAI: OpenAiManager
    
    private static func randomColor() -> Color {
        [Color.yellow,
         Color.red,
         Color.green,
         Color.orange,
         Color.pink,
         Color.purple,
         Color.cyan,
         Color.brown,
         Color.blue,
         Color.indigo,
         Color.mint,
         Color.teal].randomElement()!
    }
    
    func readTextWithSpeech(_ text: String) {
        let speechKit = OSSSpeech.shared
        speechKit.voice = OSSVoice(quality: .enhanced, language: .UnitedStatesEnglish)
        
        speechKit.speakText(text)
        imitateSpeaking(text: text, value: isSpeaking, completion: { isSpeaking = $0 })
    }
    
    func imitateSpeaking(text: String, value: Bool, completion: @escaping (Bool) -> Void) {
       let duration = estimateSpeechDuration(for: text)
        withAnimation {
            completion(true)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(duration ?? 0)) {
            withAnimation {
                completion(false)
            }
        }
    }
    
    func estimateSpeechDuration(for text: String) -> Int? {
        // You can adjust the average speaking rate as needed
        let averageSpeakingRate: Double = 150.0 // words per minute
        let wordsPerSecond = averageSpeakingRate / 60.0
        let wordCount = Double(text.split(separator: " ").count)
        let estimatedDuration = wordCount / wordsPerSecond
        return Int(estimatedDuration.rounded())
    }
    
    private static func randomName() -> String {
        [
            "Emma Johnson",
            "Daniel Williams",
            "Sophia Martinez",
            "Ethan Thompson",
            "Olivia Davis",
            "Benjamin Garcia",
            "Ava Anderson",
            "William Rodriguez"
        ].randomElement()!
    }
    
    private let user1: UserSettings
    private let user2: UserSettings
    private let user3: UserSettings
    
    init(router: Router) {
        self.router = router
        self.openAI = OpenAiManager()
        self.user1 = UserSettings(id: "1",
                                  isBot: true,
                                  userName: "Igor Kondratuk",
                                  avatarName: "avatar_5",
                                  gender: .male,
                                  userRole: .teamLead,
                                  englishLevel: .preIntermediate)
        
        self.user2 = UserSettings(id: "2",
                                  isBot: true,
                                  userName: "Natalie Kovalengo",
                                  avatarName: "avatar_4",
                                  gender: .female,
                                  userRole: .backend,
                                  englishLevel: .preIntermediate)
        
        self.user3 = UserSettings(id: "3",
                                  isBot: true,
                                  userName: "Serhii Dorozhny",
                                  avatarName: "avatar_11",
                                  gender: .male,
                                  userRole: .designer,
                                  englishLevel: .preIntermediate)
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Color("bgColor")
                .ignoresSafeArea()
            RainbowBackgroundView()
            GeometryReader { reader in
                VStack {
                    ZStack {
                        Text("Daily Meeting")
                            .foregroundStyle(.white)
                            .fontWeight(.semibold)
                        HStack {
                            Spacer()
                                Button(action: {
                                    router.showSettingsView()
                                }, label: {
                                    ZStack {
                                Circle()
                                    .foregroundStyle(Color("secondaryColor"))
                                    .frame(width: 36)
                                Image(systemName: "gearshape")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20)
                                    .foregroundStyle(.white)
                                    }.padding(.trailing, 16)
                                })
                        }
                    }
                    
                    LazyVGrid(columns: columns, spacing: 6) {
                        AvatarView(user: user1, isSpeaking: $isSpeaking)
                        AvatarView(user: user2, isSpeaking: .constant(false))
                        AvatarView(user: user3, isSpeaking: .constant(false))
                        AvatarView(user: user3, isSpeaking: .constant(false))
                    }.padding(.horizontal, 16)
                }
                VStack {
                    Spacer()
                    ChatView(chatResponse: $chatResponse,
                             userMessage: $userMessage,
                             chatExpanded: $chatExpanded,
                             isClicked: {
                        openVoiceRecognizer = true
                    }).frame(height: chatExpanded ? reader.size.height : reader.size.height / 2.3)
                }
            }
            
            .onFirstAppear {
                openAI.setupChat()
                Task {
                    await openAI.sendMessage(message: "Start")
                }
            }
            
            .onChange(of: openAI.chatHistory, perform: { history in
                chatResponse = ""
                for message in history {
                    if message.role != .system && message.content != "You: Start" {
                        chatResponse = chatResponse + "\n" + message.content + "\n"
                    }
                }
                if let lastMessage = history.last?.content {
                    if openAI.chatHistory.count > 2 {
                        if !lastMessage.contains("You:") {
                            readTextWithSpeech(lastMessage)
                        }
                    }
                }
            })
            
            //.background(Color("bgColor"))
        }.toolbar(.hidden)
        .sheet(isPresented: $openVoiceRecognizer, content: {
            VoiceRecordView(viewModel: VoiceRecordViewModel(),
                            recognitiedText: { message in
                openVoiceRecognizer = false
                Task {
                    await openAI.sendMessage(message: message)
                }
            })
        })
        
    }
}

struct ChatScreenView_Previews: PreviewProvider {
    static var previews: some View {
        ChatScreenView(router: Router())
    }
}

struct ChatView: View {
    
    @Binding var chatResponse: String
    @Binding var userMessage: String
    @Binding var chatExpanded: Bool
    var isClicked: () -> Void

    init(chatResponse: Binding<String>,
         userMessage: Binding<String>,
         chatExpanded: Binding<Bool>,
         isClicked: @escaping () -> Void) {
        self._chatResponse = chatResponse
        self._userMessage = userMessage
        self._chatExpanded = chatExpanded
        self.isClicked = isClicked
    }
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                ZStack(alignment: .top) {
                    RoundedRectangle(cornerRadius: 15)
                        .foregroundColor(Color.white)
                        .ignoresSafeArea()
                        
                    VStack {
                        ScrollViewReader { reader in
                            ScrollView {
                                Text(chatResponse)
                                    .multilineTextAlignment(.leading)
                                    .foregroundColor(.black)
                                    .padding(26)
                                VStack{}.id(1)
                            }
                            .onChange(of: chatResponse.publisher, perform: { _ in
                                withAnimation {
                                    reader.scrollTo(1, anchor: .bottom)
                                }
                            })
                        }

                        HStack(spacing: 0) {
                            Button(action: {
                                isClicked()
                            }, label: {
                                ZStack {
                                    Circle()
                                        .frame(width: 60)
                                        .foregroundColor(.green)
                                    Image(systemName: "mic.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20)
                                        .foregroundColor(.white)
                                }
                            })
                            Spacer()
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
                        }.padding(.horizontal, 30)
                            
                    }
                    Button(action: {
                        withAnimation {
                            chatExpanded.toggle()
                        }
                    }, label: {
                        
                    
                    RoundedRectangle(cornerRadius: 4)
                        .frame(width: 60, height: 6)
                        .foregroundColor(Color("secondaryColor").opacity(0.2))
                        .padding(.top, 12)
                    })
                }
            }
        }
    }
    
}
