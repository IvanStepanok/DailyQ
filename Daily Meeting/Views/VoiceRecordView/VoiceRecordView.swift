//
//  VoiceRecordView.swift
//  Daily Meeting
//
//  Created by  Stepanok Ivan on 03.08.2023.
//

import SwiftUI

struct VoiceRecordView: View {
    
    @ObservedObject var viewModel: VoiceRecordViewModel
    private var recognitiedText: (String) -> Void
    
    init(viewModel: VoiceRecordViewModel,
         recognitiedText: @escaping (String) -> Void) {
        self.viewModel = viewModel
        self.recognitiedText = recognitiedText
    }
    
    var body: some View {
        ZStack(alignment: .center) {
            Color("bgColor")
                .ignoresSafeArea()
            LinearGradient(colors: [viewModel.isRecording ? Color.green.opacity(0.3) : .gray.opacity(0.2),
                                    Color("bgColor"),Color("bgColor")], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
            
            VStack {
                VStack {
                        if viewModel.isTextEditMode {
                            TextEditor(text: $viewModel.editText)
                            //                            .hideScrollContentBackground()
                        .frame(maxHeight: 100)
                        } else {
                        Text(viewModel.previewRecognizedText)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.white)
                            .opacity(viewModel.isTextEditMode ? 0 : 1)
                            .padding(.top, 20)
                    }
                    
                    if !viewModel.previewRecognizedText.isEmpty || !viewModel.editText.isEmpty {
                    Button(action: {
                        viewModel.isTextEditMode.toggle()
                    }) {
                        HStack {
                            Image(systemName: viewModel.isTextEditMode ? "checkmark" : "pencil")
                            Text(viewModel.isTextEditMode ? "Завершити редагування" : "Редагувати текст")
                                .foregroundColor(viewModel.isTextEditMode ? .green : .white)
                        }.font(.system(size: 14, weight: .bold, design: .default)).padding(1)
                    }
                    }
                    
                }.padding(.top, 20)
                    .padding(.bottom, -30)
                    .padding(.horizontal, 16)
                    .onChange(of: viewModel.isTextEditMode, perform: { isTextEditMode in
                        if isTextEditMode {
                            viewModel.stopRecording()
                            viewModel.editText = viewModel.previewRecognizedText
                        } else {
                            viewModel.startRecording()
                            viewModel.bufferRecognizedText = (viewModel.editText + " ")
                            
                            
                        }
                    })

                Text(viewModel.isRecording ? "Speak now" : "Press to start")
                    .foregroundColor(.white)
                    .padding(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(lineWidth: 1)
                            .fill(.white)
                    ).offset(y: 50)
                ZStack {
                    if !viewModel.isTextEditMode {
                        AnimatedCircles()
                            .opacity(viewModel.isRecording ? 1 : 0)
                        Button(action: {
                            if viewModel.isRecording {
                                viewModel.stopRecording()
                            } else {
                                viewModel.startRecording()
                            }
                        }, label: {
                            
                            ZStack {
                                
                                Circle()
                                    .frame(width: 220)
                                    .foregroundColor(viewModel.isRecording ? .green : .gray)
                                if viewModel.isRecording {
                                    Circle()
                                        .frame(width: 220)
                                        .foregroundColor(.green)
                                        .blur(radius: 100)
                                }
                                Image(systemName: viewModel.isRecording ? "mic" : "mic.slash")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: viewModel.isRecording ? 60 : 70)
                                    .foregroundStyle(.white)
                            }
                            
                            
                        })
                        
                        ZStack(alignment: .center) {
                            VStack(alignment: .center) {
                                Spacer()
                                HStack(spacing: 16) {
                                    ForEach(Array([".", ",", "!", "?", "erase"].enumerated()), id: \.offset ) { index, symbol in
                                        Button(action: {
                                            if symbol != "erase" {
                                                viewModel.stopRecording()
                                                viewModel.recognizedText.append("\(symbol) ")
                                                //                                            viewModel.recognizedParts.append(viewModel.recognizedText)
                                                viewModel.bufferRecognizedText.append(viewModel.recognizedText)
                                                //                                            viewModel.bufferRecognizedText.append("\(symbol) ")
                                                viewModel.recognizedText = ""
                                                viewModel.startRecording()
                                            } else {
                                                viewModel.stopRecording()
                                                viewModel.bufferRecognizedText.append(viewModel.recognizedText)
                                                viewModel.recognizedText = ""
                                                if !viewModel.bufferRecognizedText.isEmpty {
                                                    viewModel.bufferRecognizedText.deleteLastWord()
                                                }
                                                viewModel.startRecording()
                                            }
                                        }, label: {
                                            ZStack {
                                                Circle()
                                                    .foregroundColor(Color("secondaryColor"))
                                                if symbol != "erase" {
                                                    Text(symbol)
                                                        .foregroundColor(.white)
                                                        .font(Font.system(size: 24))
                                                } else {
                                                    Image(systemName: "delete.backward")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 24)
                                                        .foregroundStyle(.red)
                                                        .offset(x: -2)
                                                }
                                            }
                                        })
                                    }
                                    
                                }.padding(.horizontal, 16)
                                    .offset(y: 10)
                                    .opacity(viewModel.isRecording ? 1 : 0)
                                CustomButton(text: "Send message",
                                             bgColor: Color.green,
                                             action: {
                                    viewModel.stopRecording()
                                    recognitiedText(viewModel.previewRecognizedText)
                                    viewModel.recognizedText = ""
                                    //                                viewModel.recognizedParts = []
                                })
                                .offset(y: viewModel.previewRecognizedText.isEmpty || viewModel.isTextEditMode ? 200 : 50)
                                .animation(.easeInOut, value: viewModel.previewRecognizedText.isEmpty)
                            }
                        }
                    }
                }.offset(y: -60)
            }.scrollAvoidKeyboard(dismissKeyboardByTap: true)
            VStack {
                RoundedRectangle(cornerRadius: 4)
                    .frame(width: 60, height: 8)
                    .foregroundColor(.black.opacity(0.3))
                    .padding(.top, 8)
                Spacer()
            }
        }.onFirstAppear {
            self.viewModel.startRecording()
        }
        .onDisappear {
            viewModel.stopRecording()
            viewModel.audioEngine = nil
            viewModel.recognitionTask = nil
        }
        
        .ignoresSafeArea()
    }
}

struct VoiceRecordView_Previews: PreviewProvider {
    static var previews: some View {
        VoiceRecordView(viewModel: VoiceRecordViewModel(),
                        recognitiedText: { text in
            
        })
    }
}


struct AnimatedCircles: View {
    var body: some View {
        ZStack {
            ForEach(0..<7, id: \.self) { index in
                CircleView()
                    .animation(Animation.easeInOut(duration: 3)
                        .repeatForever(autoreverses: false).delay(Double(index) * 0.5))
            }
        }
    }
}

struct CircleView: View {
    @State private var circleScale: CGFloat = 0.2
    @State private var opacity: Double = 1.0
    
    var body: some View {
        Circle()
            .stroke(Color.green.opacity(0.4), lineWidth: 2)
            .scaleEffect(circleScale)
            .opacity(opacity)
            .onAppear {
                withAnimation {
                    circleScale = 1.5
                    opacity = 0
                }
            }
    }
}


extension String {
    mutating func deleteLastWord() {
        guard let range = self.range(of: #"[^\s]+\s*$"#, options: .regularExpression) else {
            return
        }
        self.removeSubrange(range)
    }
}
