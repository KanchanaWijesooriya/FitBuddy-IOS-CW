import Foundation
import Intents
import IntentsUI
import SwiftUI
import AVFoundation
import Speech

@available(iOS 12.0, *)
class SiriService: NSObject, ObservableObject {
    @Published var isSiriEnabled = false
    @Published var isListening = false
    @Published var isWaitingForResponse = false
    
    private var navigationCoordinator: NavigationCoordinator?
    private let speechSynthesizer = AVSpeechSynthesizer()
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private var isAudioEngineRunning = false
    
    override init() {
        super.init()
        checkSiriAuthorization()
        requestSpeechRecognitionPermission()
    }
    
    deinit {
        // Clean up audio resources
        stopListening()
        NotificationCenter.default.removeObserver(self)
    }
    
    func setNavigationCoordinator(_ coordinator: NavigationCoordinator) {
        self.navigationCoordinator = coordinator
    }
    
    // Check current Siri authorization status
    func checkSiriAuthorization() {
        let status = INPreferences.siriAuthorizationStatus()
        DispatchQueue.main.async {
            self.isSiriEnabled = (status == .authorized)
        }
    }
    
    // Request speech recognition permission
    private func requestSpeechRecognitionPermission() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    Swift.print("✅ Speech recognition authorized")
                case .denied, .restricted, .notDetermined:
                    Swift.print("❌ Speech recognition not authorized")
                @unknown default:
                    Swift.print("❌ Unknown speech recognition status")
                }
            }
        }
    }
    
    // Request Siri permission
    func requestSiriPermission(completion: @escaping (Bool) -> Void) {
        Swift.print("🎤 Requesting Siri permission...")
        INPreferences.requestSiriAuthorization { [weak self] status in
            Swift.print("🎤 Siri authorization status: \(status.rawValue)")
            DispatchQueue.main.async {
                let granted = (status == .authorized)
                self?.isSiriEnabled = granted
                
                if granted {
                    Swift.print("✅ Siri permission granted")
                } else {
                    Swift.print("❌ Siri permission denied - Status: \(status)")
                }
                
                completion(granted)
            }
        }
    }
    
    // Start Siri interaction with greeting
    func startSiriInteraction() {
        guard isSiriEnabled else {
            Swift.print("❌ Siri not authorized")
            return
        }
        
        // Check microphone permission first
        checkMicrophonePermission { [weak self] granted in
            if granted {
                self?.isListening = true
                self?.createWorkoutVoiceShortcuts()
                self?.handleSiriGreeting()
            } else {
                Swift.print("❌ Microphone permission required for voice commands")
                self?.speakText("I need microphone permission to listen to your voice commands. Please enable it in Settings.")
            }
        }
    }
    
    // Check microphone permission
    private func checkMicrophonePermission(completion: @escaping (Bool) -> Void) {
        let audioSession = AVAudioSession.sharedInstance()
        
        switch audioSession.recordPermission {
        case .granted:
            Swift.print("✅ Microphone permission already granted")
            completion(true)
        case .denied:
            Swift.print("❌ Microphone permission denied")
            completion(false)
        case .undetermined:
            Swift.print("🎤 Requesting microphone permission...")
            audioSession.requestRecordPermission { granted in
                DispatchQueue.main.async {
                    Swift.print(granted ? "✅ Microphone permission granted" : "❌ Microphone permission denied")
                    completion(granted)
                }
            }
        @unknown default:
            completion(false)
        }
    }
    
    // Create voice shortcuts programmatically
    private func createWorkoutVoiceShortcuts() {
        // Create NSUserActivity for Siri shortcuts
        let activity = NSUserActivity(activityType: "com.fitbuddy.startWorkout")
        activity.title = "Start Workout"
        activity.suggestedInvocationPhrase = "Start my workout"
        activity.isEligibleForSearch = true
        activity.isEligibleForPrediction = true
        activity.persistentIdentifier = "startWorkout"
        
        // Add additional phrases
        let phrases = [
            "Start workout",
            "Start my workout", 
            "Go to workout",
            "Open workout exercises",
            "Let's exercise"
        ]
        
        // Donate the activity to Siri
        activity.becomeCurrent()
        
        Swift.print("✅ Created voice shortcuts for: \(phrases.joined(separator: ", "))")
    }
    
    private func showSiriInterface() {
        // Try to create custom intent, fallback if it fails
        let intent: INIntent
        
        if let startWorkoutIntent = NSClassFromString("StartWorkoutIntent") as? INIntent.Type {
            intent = startWorkoutIntent.init()
        } else if let intentIntent = NSClassFromString("IntentIntent") as? INIntent.Type {
            intent = intentIntent.init()
        } else {
            // If custom intent fails, just use the fallback
            handleFallbackSiri()
            return
        }
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootViewController = window.rootViewController {
            
            // Present Siri interface
            let siriVC = INUIAddVoiceShortcutViewController(shortcut: INShortcut(intent: intent)!)
            siriVC.delegate = self
            
            // Find the top-most view controller
            var topVC = rootViewController
            while let presentedVC = topVC.presentedViewController {
                topVC = presentedVC
            }
            
            topVC.present(siriVC, animated: true) {
                // After presenting, we can simulate Siri greeting
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.handleSiriGreeting()
                }
            }
        }
    }
    
    private func handleSiriGreeting() {
        // This makes Siri actually speak and ask what you need
        Swift.print("🎤 Siri: Hi, how are you? What can I help you with today?")
        speakText("Hi, how are you? What can I help you with today?")
        
        // Wait for Siri to finish speaking, then start listening
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            self.startListeningForUserResponse()
        }
    }
    
    // Start listening for user's voice response
    private func startListeningForUserResponse() {
        // Stop any existing listening session first
        stopListening()
        
        isWaitingForResponse = true
        
        // Check if we're on simulator (speech recognition doesn't work well)
        #if targetEnvironment(simulator)
        Swift.print("⚠️ Running on simulator - speech recognition may not work properly")
        speakText("I'm listening, but speech recognition works better on a real device.")
        
        // On simulator, provide a longer timeout and fallback
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            if self.isWaitingForResponse {
                self.speakText("Since you're on simulator, I'll take you to the workout now.")
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.navigateToWorkout()
                }
            }
        }
        return
        #endif
        
        guard let speechRecognizer = speechRecognizer,
              speechRecognizer.isAvailable else {
            Swift.print("❌ Speech recognizer not available")
            handleListeningTimeout()
            return
        }
        
        // Configure audio session
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .measurement, options: [.duckOthers, .defaultToSpeaker])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            Swift.print("❌ Audio session setup failed: \(error)")
            handleListeningTimeout()
            return
        }
        
        // Create recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            Swift.print("❌ Unable to create recognition request")
            handleListeningTimeout()
            return
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        // Ensure audio engine is stopped and reset
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        
        // Start audio engine
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        // Remove any existing tap first
        inputNode.removeTap(onBus: 0)
        
        // Install new tap
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
            isAudioEngineRunning = true
            Swift.print("🎤 Listening for your response...")
            
            // Delay the "I'm listening" message slightly
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.speakText("I'm listening for your command...")
            }
        } catch {
            Swift.print("❌ Audio engine start failed: \(error)")
            handleListeningTimeout()
            return
        }
        
        // Start recognition
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            
            if let result = result {
                let spokenText = result.bestTranscription.formattedString.lowercased()
                Swift.print("🎤 You said: '\(spokenText)'")
                
                // Check if user wants workout
                if spokenText.contains("workout") || spokenText.contains("exercise") || 
                   spokenText.contains("fitness") || spokenText.contains("gym") ||
                   spokenText.contains("training") || spokenText.contains("yes") ||
                   spokenText.contains("go") || spokenText.contains("start") {
                    
                    DispatchQueue.main.async {
                        self.stopListening()
                        self.speakText("Great! Taking you to your workout now!")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            self.navigateToWorkout()
                        }
                    }
                    return
                } else if spokenText.contains("no") || spokenText.contains("nothing") || 
                         spokenText.contains("cancel") || spokenText.contains("stop") {
                    
                    DispatchQueue.main.async {
                        self.stopListening()
                        self.speakText("Okay, let me know if you need anything!")
                        self.isListening = false
                        self.isWaitingForResponse = false
                    }
                    return
                }
                
                // If final result but no match, continue listening briefly
                if result.isFinal {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        if self.isWaitingForResponse {
                            self.speakText("I didn't catch that. Say 'workout' to continue or 'no' to cancel.")
                        }
                    }
                }
            }
            
            if let error = error {
                Swift.print("❌ Recognition error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.stopListening()
                    self.handleListeningTimeout()
                }
            }
        }
        
        // Set a timeout for listening (longer for real device)
        DispatchQueue.main.asyncAfter(deadline: .now() + 12.0) {
            if self.isWaitingForResponse {
                Swift.print("⏰ Listening timeout reached")
                self.stopListening()
                self.handleListeningTimeout()
            }
        }
    }
    
    // Stop listening
    private func stopListening() {
        guard isAudioEngineRunning else { return }
        
        // Stop audio engine safely
        if audioEngine.isRunning {
            audioEngine.stop()
        }
        
        // Remove tap safely
        audioEngine.inputNode.removeTap(onBus: 0)
        
        // End recognition
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        
        recognitionTask?.cancel()
        recognitionTask = nil
        
        // Reset audio session
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            Swift.print("⚠️ Audio session deactivation failed: \(error)")
        }
        
        isAudioEngineRunning = false
        isWaitingForResponse = false
    }
    
    // Handle timeout when user doesn't respond
    private func handleListeningTimeout() {
        Swift.print("⏰ No response detected, offering workout navigation")
        
        // Stop listening properly first
        stopListening()
        
        speakText("I didn't catch that. Would you like me to open your workout exercises?")
        
        // Give user another chance or navigate automatically
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.navigateToWorkout()
        }
    }
    
    // Make Siri speak text
    private func speakText(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5
        utterance.pitchMultiplier = 1.0
        utterance.volume = 0.8
        
        speechSynthesizer.speak(utterance)
    }
    
    // Fallback Siri method if custom intent fails
    private func handleFallbackSiri() {
        Swift.print("🎤 Siri: Hi, how are you? What can I help you with today?")
        speakText("Hi, how are you? What can I help you with today?")
        
        // Wait for Siri to finish speaking, then start listening
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            self.startListeningForUserResponse()
        }
    }
    
    // Handle NSUserActivity from Siri
    static func handleSiriActivity(_ userActivity: NSUserActivity) -> Bool {
        guard userActivity.activityType == "com.fitbuddy.startWorkout" else {
            return false
        }
        
        Swift.print("🎤 Siri activated: \(userActivity.title ?? "Start Workout")")
        
        // Post notification to trigger workout navigation
        NotificationCenter.default.post(
            name: NSNotification.Name("SiriStartWorkout"),
            object: nil
        )
        
        return true
    }
    
    // Setup notification observer for Siri commands
    func setupSiriNotificationObserver() {
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("SiriStartWorkout"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.navigateToWorkout()
        }
    }
    
    // Navigate to workout page
    func navigateToWorkout() {
        Swift.print("🏃‍♂️ Navigating to Workout Exercise View...")
        speakText("Opening your workout exercises. Let's get fit!")
        
        DispatchQueue.main.async {
            self.navigationCoordinator?.navigateToWorkoutExercise()
            self.isListening = false
        }
    }
    
    // Add Siri shortcut for workout navigation
    func addWorkoutShortcut() {
        // Try to create intent, but handle if it fails
        if let startWorkoutIntent = NSClassFromString("StartWorkoutIntent") as? INIntent.Type {
            let intent = startWorkoutIntent.init()
            let shortcut = INShortcut(intent: intent)!
            let viewController = INUIAddVoiceShortcutViewController(shortcut: shortcut)
            viewController.delegate = self
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let rootViewController = window.rootViewController {
                
                var topVC = rootViewController
                while let presentedVC = topVC.presentedViewController {
                    topVC = presentedVC
                }
                
                topVC.present(viewController, animated: true)
            }
        } else {
            // Fallback: just navigate directly
            Swift.print("⚠️ Custom intent not available, using direct navigation")
            handleFallbackSiri()
        }
    }
}

// MARK: - INUIAddVoiceShortcutViewControllerDelegate
@available(iOS 12.0, *)
extension SiriService: INUIAddVoiceShortcutViewControllerDelegate {
    func addVoiceShortcutViewController(_ controller: INUIAddVoiceShortcutViewController, didFinishWith voiceShortcut: INVoiceShortcut?, error: Error?) {
        controller.dismiss(animated: true) {
            if let error = error {
                Swift.print("❌ Error adding voice shortcut: \(error)")
            } else if voiceShortcut != nil {
                Swift.print("✅ Voice shortcut added successfully")
            }
        }
    }
    
    func addVoiceShortcutViewControllerDidCancel(_ controller: INUIAddVoiceShortcutViewController) {
        controller.dismiss(animated: true)
        isListening = false
    }
}
