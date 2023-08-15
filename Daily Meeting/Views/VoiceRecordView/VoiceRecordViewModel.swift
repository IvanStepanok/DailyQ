//
//  VoiceRecordViewModel.swift
//  Daily Meeting
//
//  Created by  Stepanok Ivan on 03.08.2023.
//

import Foundation
import Speech

class VoiceRecordViewModel: ObservableObject {
    
    var audioEngine: AVAudioEngine? = AVAudioEngine()
    var recognitionTask: SFSpeechRecognitionTask?
    
    @Published var isRecording = false
    @Published var recognizedText = ""
    
    @Published var editText = ""
    @Published var isTextEditMode: Bool = false
    
    var previewRecognizedText: String {
        return bufferRecognizedText + recognizedText
    }
    @Published var bufferRecognizedText: String = ""
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    
    let audioSession = AVAudioSession.sharedInstance()
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    
    func startRecording() {
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let recognitionRequest else { return }
        
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
                do {
                    try audioSession.setCategory(.record, mode: .default)
                    try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
                } catch {
                    print("Audio session setup failed: \(error)")
                }
                DispatchQueue.main.async {
                    self.isRecording = true
                }
                
                let inputNode = audioEngine?.inputNode
                
                recognitionRequest.shouldReportPartialResults = true
                
                let _ = recognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
                    guard let self else { return }
                    if let result = result {
                        let transcribedText = result.bestTranscription.formattedString
                        print(">>>>> 🏆 RECOGNIZED", self.recognizedText)
                        print(">>>>> 🏆 BUFFER", self.bufferRecognizedText)
                        self.recognizedText = transcribedText
                    } else if let error = error {
                        print("Recognition task error: \(error)")
                    }
                }
                
                let recordingFormat = inputNode?.outputFormat(forBus: 0)
                inputNode?.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                    self.recognitionRequest?.append(buffer)
                }
                
                audioEngine?.prepare()
                
                do {
                    try audioEngine?.start()
                } catch {
                    print("Audio engine start error: \(error)")
                }
                
            }
        }
    }
    
    func stopRecording() {
        audioEngine?.stop()
        audioEngine?.reset()
        audioEngine?.inputNode.removeTap(onBus: 0)
//        recognitionTask?.cancel()
//        recognitionTask?.finish()
//        recognitionRequest?.endAudio()
        self.isRecording = false
    }
}
