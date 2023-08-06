//
//  ChatScreenView.swift
//  Daily Meeting
//
//  Created by  Stepanok Ivan on 02.08.2023.
//

import SwiftUI
import OpenAISwift
import Combine

struct ChatScreenView: View {
    
    @ObservedObject var viewModel: ChatScreenViewModel
    @ObservedObject var openAI: OpenAiManager
    @State var whoSpeak: String = ""
    @State var chatPosition: CGFloat = 200
    
    private let columns = [GridItem(.adaptive(minimum: 140, maximum: 200))]
    
    
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
                            AvatarView(user: user, isSpeaking: whoSpeak == user.userName ? $viewModel.isSpeaking : .constant(false))
                        }
                    }.padding(.horizontal, 16)
                }
                VStack {
                    Spacer()
                    ChatWindowView(chatHistory: $openAI.chatHistory,
                             chatExpanded: $viewModel.chatExpanded,
                             whoSpeak: { whoSpeak = $0 },
                             isClicked: {
                        viewModel.openVoiceRecognizer = true
                    }).frame(height: viewModel.chatExpanded ? reader.size.height : chatPosition)
                        .onAppear {
                            chatPosition = reader.size.height / 2.3
                        }
                }
            }
            
            .onFirstAppear {
                openAI.setupChat()
                Task {
                    await openAI.sendMessage(message: "Start")
                }
            }
            
            .onChange(of: openAI.chatHistory, perform: { history in
                viewModel.chatResponse = ""
                for message in history {
                    if message.role != .system && message.content != "You: Start" {
                        viewModel.chatResponse = viewModel.chatResponse + "\n" + message.content + "\n"
                    }
                }
                if let lastMessage = history.last?.content {
                    if openAI.chatHistory.count > 2 {
                        if !lastMessage.contains("You:") {
                            viewModel.readTextWithSpeech(lastMessage)
                        }
                    }
                }
            })
            
            //.background(Color("bgColor"))
        }.navigationBarHidden(true) //.toolbar(.hidden)
            .sheet(isPresented: $viewModel.openVoiceRecognizer, content: {
                VoiceRecordView(viewModel: VoiceRecordViewModel(),
                                recognitiedText: { message in
                    viewModel.openVoiceRecognizer = false
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

struct ChatWindowView: View {
    
//    @Binding var chatResponse: String
    @Binding var chatHistory: [ChatMessage]
    @Binding var chatExpanded: Bool
    @State var chevronExpanded: Bool = false
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
                        chevronExpanded.toggle()
                    }, label: {

                        Image(systemName: chevronExpanded ? "chevron.compact.down" : "chevron.compact.up")
                            .resizable()
                            .scaledToFit()
//                        RoundedRectangle(cornerRadius: 4)
                            .frame(height: 10)
                            .foregroundColor(Color("secondaryColor").opacity(0.2))
                            .padding(.top, 8)
                            
                    })
                }
            }
        }
    }
    
}
