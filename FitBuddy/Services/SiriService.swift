import Foundation
import SwiftUI
import AVFoundation
import Speech

class SimpleSiriService: NSObject, ObservableObject {
    @Published var isListening = false
    @Published var isProcessing = false
    @Published var lastRecognizedText = ""
    @Published var canUseSpeech = false
    
    private let speechSynthesizer = AVSpeechSynthesizer()
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    // Navigation callbacks
    var onNavigateToProfile: (() -> Void)?
    var onNavigateToWorkout: (() -> Void)?
    
    override init() {
        super.init()
        setupPermissions()
    }
    
    deinit {
        stopListening()
    }
    
    // MARK: - Setup and Permissions
    private func setupPermissions() {
        requestSpeechRecognitionPermission()
        requestMicrophonePermission()
    }
    
    private func requestSpeechRecognitionPermission() {
        SFSpeechRecognizer.requestAuthorization { [weak self] authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    print("Speech recognition authorized")
                    self?.checkOverallPermissions()
                case .denied, .restricted, .notDetermined:
                    print("Speech recognition not authorized")
                    self?.canUseSpeech = false
                @unknown default:
                    print("Unknown speech recognition status")
                    self?.canUseSpeech = false
                }
            }
        }
    }
    
    private func requestMicrophonePermission() {
        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
            DispatchQueue.main.async {
                if granted {
                    print("Microphone permission granted")
                    self?.checkOverallPermissions()
                } else {
                    print("Microphone permission denied")
                    self?.canUseSpeech = false
                }
            }
        }
    }
    
    private func checkOverallPermissions() {
        let speechAuth = SFSpeechRecognizer.authorizationStatus() == .authorized
        let micAuth = AVAudioSession.sharedInstance().recordPermission == .granted
        let recognizerAvailable = speechRecognizer?.isAvailable == true
        
        canUseSpeech = speechAuth && micAuth && recognizerAvailable
        print("Speech capabilities: \(canUseSpeech)")
    }
    
    // MARK: - Main Voice Interaction
    func startVoiceInteraction() {
        guard canUseSpeech else {
            speakText("I need microphone and speech recognition permissions to help you. Please enable them in Settings.")
            return
        }
        
        speakText("Hey, how are you? How can I help you today?")
        
        // Wait for speech to finish, then start listening
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.startListening()
        }
    }
    
    // MARK: - Speech Recognition
    private func startListening() {
        guard !isListening && canUseSpeech else { return }
        
        // Clean up any existing tasks
        stopListening()
        
        do {
            // Configure audio session
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
            // Create recognition request
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            guard let recognitionRequest = recognitionRequest else {
                print("Could not create recognition request")
                return
            }
            
            recognitionRequest.shouldReportPartialResults = true
            recognitionRequest.taskHint = .dictation
            
            // Setup audio engine
            let inputNode = audioEngine.inputNode
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                recognitionRequest.append(buffer)
            }
            
            audioEngine.prepare()
            try audioEngine.start()
            
            isListening = true
            print("Started listening...")
            
            // Start recognition task
            recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
                DispatchQueue.main.async {
                    if let result = result {
                        let recognizedText = result.bestTranscription.formattedString
                        self?.lastRecognizedText = recognizedText
                        print("Recognized: \(recognizedText)")
                        
                        if result.isFinal {
                            self?.processVoiceCommand(recognizedText)
                        }
                    }
                    
                    if error != nil || result?.isFinal == true {
                        self?.stopListening()
                    }
                }
            }
            
            // Auto-stop after 5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                if self.isListening {
                    self.stopListening()
                    if self.lastRecognizedText.isEmpty {
                        self.speakText("I didn't hear anything. Tap the microphone to try again.")
                    }
                }
            }
            
        } catch {
            print("Audio engine error: \(error)")
            stopListening()
        }
    }
    
    private func stopListening() {
        guard isListening else { return }
        
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        
        recognitionRequest = nil
        recognitionTask = nil
        isListening = false
        
        // Reset audio session
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print("Error deactivating audio session: \(error)")
        }
        
        print("Stopped listening")
    }
    
    // MARK: - Voice Command Processing
    private func processVoiceCommand(_ command: String) {
        isProcessing = true
        let lowercased = command.lowercased()
        
        print("Processing command: \(command)")
        
        if lowercased.contains("profile") || lowercased.contains("settings") {
            speakText("Going to your profile page")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.onNavigateToProfile?()
                self.isProcessing = false
            }
        }
        else if lowercased.contains("workout") || lowercased.contains("exercise") || lowercased.contains("start") {
            speakText("Starting your workout")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.onNavigateToWorkout?()
                self.isProcessing = false
            }
        }
        else {
            speakText("I can help you go to your profile or start a workout. What would you like to do?")
            isProcessing = false
        }
    }
    
    // MARK: - Text to Speech
    private func speakText(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5
        utterance.volume = 0.8
        
        speechSynthesizer.speak(utterance)
        print("Speaking: \(text)")
    }
}

// Legacy compatibility - keeping the old class name for existing references
typealias SiriService = SimpleSiriService

// Static method for legacy compatibility
extension SimpleSiriService {
    static func handleSiriActivity(_ userActivity: NSUserActivity) -> Bool {
        print("Received Siri activity: \(userActivity.activityType)")
        return true
    }
}
