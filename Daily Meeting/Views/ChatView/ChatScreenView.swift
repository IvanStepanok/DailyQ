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
    
    @ObservedObject var viewModel: ChatScreenViewModel
    @ObservedObject var openAI: OpenAiManager

    
    private let columns = [GridItem(.adaptive(minimum: 140, maximum: 200))]
    @State var chatResponse: String = ""
    @State var userMessage: String = ""
    @State var chatExpanded: Bool = false
    @State var openVoiceRecognizer: Bool = false
    @State var isSpeaking: Bool = false
    @State var whoSpeak: String = ""
    
    
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
    
    init(viewModel: ChatScreenViewModel, openAI: OpenAiManager) {
        self.viewModel = viewModel
        self.openAI = openAI
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
                            .font(.system(size: 18, weight: .semibold, design: .default))
                        HStack {
                            Spacer()
                                Button(action: {
                                    viewModel.router.showSettingsView()
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
                        ForEach(viewModel.members.sorted(by: {$0.id < $1.id}), id: \.id) { user in
                                AvatarView(user: user, isSpeaking: whoSpeak == user.userName ? $isSpeaking : .constant(false))
                        }
                    }.padding(.horizontal, 16)
                }
                VStack {
                    Spacer()
                    ChatView(chatHistory: $openAI.chatHistory,
                             chatExpanded: $chatExpanded,
                             whoSpeak: { whoSpeak = $0 },
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
        }.navigationBarHidden(true) //.toolbar(.hidden)
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
        ChatScreenView(viewModel: ChatScreenViewModel(users: [],
                                                      router: RouterMock(),
                                                      persistence: ChatPersistence()),
                       openAI: OpenAiManager(persistence: ChatPersistence()))
    }
}

struct ChatView: View {
    
//    @Binding var chatResponse: String
    @Binding var chatHistory: [ChatMessage]
    @Binding var chatExpanded: Bool
    var whoSpeak: (String) -> Void
    var isClicked: () -> Void
    

    init(chatHistory: Binding<[ChatMessage]>,
         chatExpanded: Binding<Bool>,
         whoSpeak:  @escaping (String) -> Void,
         isClicked: @escaping () -> Void) {
        self._chatHistory = chatHistory
        self._chatExpanded = chatExpanded
        self.whoSpeak = whoSpeak
        self.isClicked = isClicked
    }
    
    func getName(_ content: String) -> String? {
        if content.first == "#" {
            let namePattern = "#(.*?)#"
            let regex = try! NSRegularExpression(pattern: namePattern)
            let range = NSRange(location: 0, length: content.utf16.count)
            if let match = regex.firstMatch(in: content, options: [], range: range) {
                let name = (content as NSString).substring(with: match.range(at: 1))
                whoSpeak(name)
                return name
            }
        }
        return nil
    }
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                ZStack(alignment: .top) {
                    RoundedRectangle(cornerRadius: 15)
                        .foregroundColor(Color.white)
                        .ignoresSafeArea()
                        
                        ScrollViewReader { reader in
                            ScrollView {
                                VStack(alignment: .leading, spacing: 10) {
                                ForEach(chatHistory.filter({ $0.role != .system })) { history in
                                        if history.content != "You: Start" {
                                            if let name = getName(history.content) {
                                                Text(name)
                                                    .font(.system(size: 16, weight: .semibold, design: .default))
                                                    .foregroundColor(.black)
                                                    .onAppear {
                                                        withAnimation {
                                                            reader.scrollTo(1, anchor: .bottom)
                                                        }
                                                    }
                                                Text(
                                                    history.content
                                                        .replacingOccurrences(of: "#\(name)# ", with: "")
                                                        .replacingOccurrences(of: "#", with: "")
                                                )
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
