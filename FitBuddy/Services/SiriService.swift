import Foundation
import SwiftUI
import AVFoundation
import Speech

class SimpleSiriService: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    @Published var isListening = false
    @Published var isProcessing = false
    @Published var lastRecognizedText = ""
    @Published var canUseSpeech = false
    @Published var isSpeaking = false
    
    private let speechSynthesizer = AVSpeechSynthesizer()
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    // Completion handlers
    private var speechCompletionHandler: (() -> Void)?
    
    // Navigation callbacks - only the two you requested
    var onNavigateToProfile: (() -> Void)?
    var onNavigateToWorkout: (() -> Void)?
    
    override init() {
        super.init()
        speechSynthesizer.delegate = self
        setupPermissions()
    }
    
    deinit {
        // Ensure complete cleanup on deallocation
        isListening = false
        recognitionTask?.cancel()
        recognitionRequest?.endAudio()
        
        if audioEngine.isRunning {
            audioEngine.stop()
        }
        
        // Remove tap safely
        do {
            audioEngine.inputNode.removeTap(onBus: 0)
        } catch {
            // Ignore error if no tap was installed
        }
        
        print("SimpleSiriService deallocated")
    }
    
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
        print("Speech capabilities check:")
        print("  - Speech authorized: \(speechAuth)")
        print("  - Microphone authorized: \(micAuth)")
        print("  - Speech recognizer available: \(recognizerAvailable)")
        print("  - Overall can use speech: \(canUseSpeech)")
    }
    
    func validateAudioSystem() -> Bool {
        do {
            // First, configure the audio session to initialize the audio system
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
            // Ensure audio engine is prepared
            if !audioEngine.isRunning {
                audioEngine.prepare()
            }
            
            let inputNode = audioEngine.inputNode
            let format = inputNode.outputFormat(forBus: 0)
            
            let isValid = format.sampleRate > 0 && 
                         format.channelCount > 0 && 
                         format.sampleRate >= 8000 && 
                         format.sampleRate <= 48000
            
            print("Audio system validation:")
            print("  - Sample rate: \(format.sampleRate)")
            print("  - Channel count: \(format.channelCount)")
            print("  - Format valid: \(isValid)")
            
            // Clean up - deactivate audio session since we're just validating
            try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
            
            return isValid
        } catch {
            print("Audio system validation failed: \(error)")
            return false
        }
    }
    
    private func isRunningOnSimulator() -> Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }
    
    private func getDeviceSpecificMessage() -> String {
        if isRunningOnSimulator() {
            return "Voice recognition isn't available in the simulator. Try running on a real device for full voice features!"
        } else {
            return "Voice recognition isn't available right now, but you can still navigate with touch! Try restarting the app or checking microphone permissions in Settings."
        }
    }
    
    func startVoiceInteraction() {
        // Prevent multiple simultaneous voice interactions
        guard !isListening && !isProcessing && !isSpeaking else {
            print("Voice interaction already in progress")
            return
        }
        
        guard canUseSpeech else {
            speakText("I need microphone and speech recognition permissions to help you. Please enable them in Settings.")
            return
        }
        
        // Reset states
        isListening = false
        isProcessing = false
        lastRecognizedText = ""
        
        // Simple greeting with correct text and start listening
        speakTextWithCompletion("Hi, How can I help you?") {
            // Wait longer for speech to completely finish and audio session to settle
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.startListening()
            }
        }
    }
    
    private func startListening() {
        guard !isListening && canUseSpeech else { return }
        
        // Clean up any existing tasks and audio engine state
        stopListening()
        
        do {
            // Ensure speech synthesis is completely finished
            if speechSynthesizer.isSpeaking {
                speechSynthesizer.stopSpeaking(at: .immediate)
                // Wait for speech to stop
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.startListening()
                }
                return
            }
            
            // Configure audio session for better phone compatibility
            let audioSession = AVAudioSession.sharedInstance()
            
            // First deactivate any existing session to clear conflicts
            do {
                try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
                print("Audio session deactivated")
            } catch {
                print("Could not deactivate audio session (this might be normal): \(error)")
            }
            
            // Longer pause for real device audio session transition
            Thread.sleep(forTimeInterval: 0.3)
            
            // Use playAndRecord for better phone compatibility
            try audioSession.setCategory(.playAndRecord, mode: .spokenAudio, options: [.defaultToSpeaker, .allowBluetooth, .mixWithOthers])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
            print("Audio session configured for recording (phone compatible)")
            
            // Create recognition request
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            guard let recognitionRequest = recognitionRequest else {
                print("Could not create recognition request")
                return
            }
            
            recognitionRequest.shouldReportPartialResults = true
            recognitionRequest.taskHint = .dictation
            
            // Ensure audio engine is completely stopped and reset
            if audioEngine.isRunning {
                audioEngine.stop()
            }
            
            // Remove any existing taps before installing new one (prevents nullptr == Tap() error)
            do {
                audioEngine.inputNode.removeTap(onBus: 0)
            } catch {
                // Ignore error if no tap was installed
                print("No existing tap to remove (this is normal)")
            }
            
            // Prepare and start the audio engine to get proper hardware format
            audioEngine.prepare()
            try audioEngine.start()
            
            // Give the audio engine more time to initialize properly on real devices
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                do {
                    // Double-check microphone permission at system level
                    let micPermission = AVAudioSession.sharedInstance().recordPermission
                    guard micPermission == .granted else {
                        print("Microphone permission not granted: \(micPermission)")
                        self.speakText("I need microphone permission to listen. Please enable it in Settings > FitBuddy > Microphone.")
                        self.stopListening()
                        return
                    }
                    
                    let inputNode = self.audioEngine.inputNode
                    let hardwareFormat = inputNode.outputFormat(forBus: 0)
                    
                    print("Hardware audio format:")
                    print("  - Sample rate: \(hardwareFormat.sampleRate)")
                    print("  - Channel count: \(hardwareFormat.channelCount)")
                    
                    // Check if hardware format is still invalid
                    if hardwareFormat.sampleRate == 0.0 || hardwareFormat.channelCount == 0 {
                        print("Hardware format still invalid after delay")
                        
                        self.speakText(self.getDeviceSpecificMessage())
                        self.stopListening()
                        return
                    }
                    
                    // Use the hardware format
                    self.setupAudioTapWithFormat(hardwareFormat, recognitionRequest: recognitionRequest)
                    
                } catch {
                    print("Error setting up audio tap: \(error)")
                    self.stopListening()
                    self.speakText("Voice recognition isn't working right now, but you can still navigate with touch!")
                }
            }
            
        } catch {
            print("Audio engine error: \(error.localizedDescription)")
            stopListening()
            speakText("Sorry, there was an audio issue. Please check your microphone permissions and try again.")
            
            // Reset states on error
            DispatchQueue.main.async {
                self.isListening = false
                self.isProcessing = false
            }
        }
    }
    
    private func stopListening() {
        isListening = false
        
        // Cancel recognition task first
        recognitionTask?.cancel()
        recognitionTask = nil
        
        // End audio request
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        
        // Stop audio engine safely
        if audioEngine.isRunning {
            audioEngine.stop()
        }
        
        // Remove tap safely (this prevents the nullptr == Tap() error)
        do {
            audioEngine.inputNode.removeTap(onBus: 0)
        } catch {
            // Ignore error if no tap was installed
            print("No tap to remove (this is normal)")
        }
        
        // Reset audio session
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("Error deactivating audio session: \(error)")
        }
        
        print("Stopped listening")
    }
    
    private func setupAudioTapWithFormat(_ format: AVAudioFormat, recognitionRequest: SFSpeechAudioBufferRecognitionRequest) {
        let inputNode = audioEngine.inputNode
        
        // Use the exact hardware format to avoid sample rate mismatch
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            recognitionRequest.append(buffer)
        }
        
        isListening = true
        print("Started listening with format: \(format.sampleRate)Hz, \(format.channelCount) channels")
        
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
        
        // Auto-stop after 5 seconds exactly as requested
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            if self.isListening {
                self.stopListening()
                if self.lastRecognizedText.isEmpty {
                    self.speakText("Sorry I didn't hear anything")
                }
            }
        }
    }
    
    private func processVoiceCommand(_ command: String) {
        isProcessing = true
        let lowercased = command.lowercased()
        
        print("Processing command: \(command)")
        
        // Simple command matching - exactly what you requested
        if lowercased.contains("go to my workouts") || 
           lowercased.contains("workouts") ||
           lowercased.contains("workout") {
            onNavigateToWorkout?()
            isProcessing = false
        }
        else if lowercased.contains("go to profile") || 
                lowercased.contains("profile") {
            onNavigateToProfile?()
            isProcessing = false
        }
        else {
            // If command not recognized, just go back to normal state
            isProcessing = false
        }
    }
    
    private func speakText(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.45  // Slower rate for better understanding
        utterance.volume = 0.8
        utterance.pitchMultiplier = 1.0
        utterance.preUtteranceDelay = 0.1  // Small pause before speaking
        
        isSpeaking = true
        speechSynthesizer.speak(utterance)
        print("Speaking: \(text)")
    }
    
    private func speakTextWithCompletion(_ text: String, completion: @escaping () -> Void) {
        speechCompletionHandler = completion
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.45  // Slower rate for better understanding
        utterance.volume = 0.8
        utterance.pitchMultiplier = 1.0
        utterance.preUtteranceDelay = 0.1  // Small pause before speaking
        
        isSpeaking = true
        speechSynthesizer.speak(utterance)
        print("Speaking with completion: \(text)")
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = false
            print("Speech finished")
            
            // Call completion handler if set
            if let completion = self.speechCompletionHandler {
                self.speechCompletionHandler = nil
                completion()
            }
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = false
            print("Speech cancelled")
            
            // Call completion handler even if cancelled
            if let completion = self.speechCompletionHandler {
                self.speechCompletionHandler = nil
                completion()
            }
        }
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
