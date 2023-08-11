//
//  VoiceRecordViewModel.swift
//  Daily Meeting
//
//  Created by  Stepanok Ivan on 03.08.2023.
//

import Foundation
import Speech

class VoiceRecordViewModel: ObservableObject {
    
    @Published var isRecording = false
    @Published var recognizedText = ""
    
    var previewRecognizedText: String {
        return bufferRecognizedText + recognizedText
    }
    var bufferRecognizedText = ""
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    
    func startRecording() {
        guard let recognizer = speechRecognizer else {
            print("Speech recognition not supported for current locale.")
            return
        }
        
        if !recognizer.isAvailable {
            print("Speech recognition is not available at the moment.")
            return
        }
        
        SFSpeechRecognizer.requestAuthorization { [weak self] authStatus in
            guard let self else { return }
            if authStatus == .authorized {
                let audioSession = AVAudioSession.sharedInstance()
                do {
                    try audioSession.setCategory(.record, mode: .default)
                    try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
                } catch {
                    print("Audio session setup failed: \(error)")
                }
                DispatchQueue.main.async {
                    self.isRecording = true
                }
                
                let recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
                let inputNode = audioEngine.inputNode
                
                recognitionRequest.shouldReportPartialResults = true
                
                let _ = recognizer.recognitionTask(with: recognitionRequest) { result, error in
                    if let result = result {
                        let transcribedText = result.bestTranscription.formattedString
                        self.recognizedText = transcribedText
                    } else if let error = error {
                        print("Recognition task error: \(error)")
                    }
                }
                
                let recordingFormat = inputNode.outputFormat(forBus: 0)
                inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                    recognitionRequest.append(buffer)
                }
                
                audioEngine.prepare()
                
                do {
                    try audioEngine.start()
                } catch {
                    print("Audio engine start error: \(error)")
                }
                
            }
        }
    }
    
    func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionTask?.cancel()
        self.isRecording = false
    }
    
    private let audioEngine = AVAudioEngine()
    private var recognitionTask: SFSpeechRecognitionTask?
}
