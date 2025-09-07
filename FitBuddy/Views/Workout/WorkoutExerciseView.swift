import SwiftUI
import AVKit
import CoreData

struct WorkoutExerciseView: View {
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) private var dismiss
    @State private var currentExerciseIndex = 0
    @State private var isWorkoutPaused = false
    @State private var isWorkoutStarted = false
    @State private var isWorkoutCompleted = false
    @State private var showingCompletionAlert = false
    @State private var showControlCard = false
    
    // Apple Blue theme
    private let primaryAccent = Color(red: 0.0, green: 0.478, blue: 1.0) // Apple system blue
    
    // Get workout data from NavigationCoordinator
    private var workoutName: String {
        return navigationCoordinator.workoutData["workoutName"] as? String ?? "Workout"
    }
    
    private var exercises: [Exercise] {
        let exerciseData = navigationCoordinator.workoutData["exercises"] as? [[String: String]] ?? []
        return exerciseData.map { Exercise(name: $0["name"] ?? "Exercise", duration: $0["duration"] ?? "00:00") }
    }
    
    struct Exercise {
        let name: String
        let duration: String
    }
    
    // Timer states
    @State private var timerMinutes = 0
    @State private var timerSeconds = 0
    @State private var timerMilliseconds = 0
    @State private var workoutTimer: Timer?
    @State private var totalWorkoutTime = 0 // in milliseconds
    
    // Video player state
    @State private var player: AVPlayer?
    @State private var isVideoPlaying = false
    
    // Exercise data with background images
    let workoutExercises = [
        WorkoutExercise(
            name: "Crunches",
            description: "Lie flat on your back with your knees bent and feet flat on the floor. Place your hands behind your head and lift your shoulders off the ground.",
            videoURL: "https://www.youtube.com/watch?v=MKmrqcoCZ-M",
            duration: 180, // 3 minutes in seconds
            sets: 3,
            reps: 15,
            backgroundImage: "bgimage-step"
        ),
        WorkoutExercise(
            name: "Barbell training",
            description: "Keep your core tight and maintain proper form throughout the movement. Focus on controlled movements.",
            videoURL: "https://www.youtube.com/watch?v=example2",
            duration: 300, // 5 minutes
            sets: 4,
            reps: 12,
            backgroundImage: "onboarding-screen-3"
        ),
        WorkoutExercise(
            name: "Kettlebell training",
            description: "Use full body movement and engage your core. Keep the kettlebell close to your body.",
            videoURL: "https://www.youtube.com/watch?v=example3",
            duration: 240, // 4 minutes
            sets: 3,
            reps: 10,
            backgroundImage: "squats"
        )
    ]
    
    struct WorkoutExercise: Identifiable {
        let id = UUID()
        let name: String
        let description: String
        let videoURL: String
        let duration: Int // in seconds
        let sets: Int
        let reps: Int
        let backgroundImage: String
    }
    
    var currentExercise: WorkoutExercise {
        workoutExercises[currentExerciseIndex]
    }
    
    var body: some View {
        ZStack {
            // Background image with gradient overlay (same style as WorkoutDetailView)
            backgroundView
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Video Section
                videoSection
                
                // Exercise Title
                exerciseTitleSection
                
                // Control buttons positioned after timer
                controlButtonsAfterTimer
                
                Spacer()
            }
        }
        .overlay(
            // Overlay control card - positioned to not cover video
            Group {
                if showControlCard {
                    VStack {
                        Spacer()
                        controlCardView
                    }
                }
            }
        )
        .navigationBarHidden(true)
        .onAppear {
            setupVideoPlayer()
        }
        .onDisappear {
            cleanupTimer()
            player?.pause()
        }
        .alert("Workout Complete!", isPresented: $showingCompletionAlert) {
            Button("Save & Continue") {
                saveWorkoutData()
            }
            Button("Discard") {
                // Just dismiss
            }
        } message: {
            Text("Great job! Your workout data will be saved.")
        }
    }
    
    // MARK: - UI Components
    private var backgroundView: some View {
        GeometryReader { geometry in
            Image(currentExercise.backgroundImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: geometry.size.width, height: geometry.size.height)
                .clipped()
                .overlay(backgroundGradient)
        }
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.black.opacity(0.7),
                Color.black.opacity(0.3),
                Color.black.opacity(0.8)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    private var headerView: some View {
        HStack {
            Button(action: {
                if currentExerciseIndex > 0 {
                    previousExercise()
                } else {
                    pauseWorkout()
                    navigationCoordinator.goBack()
                }
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(primaryAccent)
                    .font(.title2)
            }
            
            Spacer()
            
            Text("\(currentExerciseIndex + 1)/\(workoutExercises.count)")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            Spacer()
            
            Button(action: {
                pauseWorkout()
                navigationCoordinator.goBack()
            }) {
                Image(systemName: "xmark")
                    .foregroundColor(primaryAccent)
                    .font(.title2)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    private var videoSection: some View {
        VStack(spacing: 12) {
            // Progress bar
            ProgressView(value: Double(currentExerciseIndex), total: Double(workoutExercises.count))
                .progressViewStyle(LinearProgressViewStyle(tint: primaryAccent))
                .scaleEffect(x: 1, y: 2, anchor: .center)
                .padding(.horizontal, 20)
            
            // Video player
            if let player = player {
                VideoPlayer(player: player)
                    .frame(height: 180)
                    .cornerRadius(16)
                    .padding(.horizontal, 20)
            } else {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray5))
                    .frame(height: 180)
                    .overlay(
                        VStack {
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(primaryAccent)
                            Text("Loading video...")
                                .foregroundColor(.secondary)
                                .font(.subheadline)
                        }
                    )
                    .padding(.horizontal, 20)
            }
        }
        .padding(.top, 10)
    }
    
    private var exerciseTitleSection: some View {
        VStack(spacing: 12) {
            Text(currentExercise.name)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white) // Changed to white
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Timer display in a box
            HStack(spacing: 10) {
                Image(systemName: "timer")
                    .foregroundColor(.white)
                    .font(.title)
                
                Text(String(format: "%02d:%02d:%02d", timerMinutes, timerSeconds, timerMilliseconds/10))
                    .font(.system(size: 30, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 20)
        }
        .padding(.top, 16)
    }
    
    private var controlButtonsAfterTimer: some View {
        VStack(spacing: 16) {
            // Show Details button - always visible
            Button(action: {
                withAnimation(.easeInOut(duration: 0.6)) {
                    showControlCard = true
                }
            }) {
                Text("Show Exercise Details")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(primaryAccent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
            }
            .padding(.horizontal, 20)
            
            // Control buttons based on workout state
            HStack(spacing: 12) {
                if !isWorkoutStarted {
                    // Start button - only shown when workout hasn't started
                    Button(action: {
                        startWorkout()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "play.fill")
                                .font(.title3)
                            Text("Start")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [primaryAccent, primaryAccent.opacity(0.8)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                    }
                } else {
                    // Pause/Resume button
                    Button(action: {
                        if isWorkoutPaused {
                            resumeWorkout()
                        } else {
                            pauseWorkout()
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: isWorkoutPaused ? "play.fill" : "pause.fill")
                                .font(.title3)
                            Text(isWorkoutPaused ? "Resume" : "Pause")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [primaryAccent, primaryAccent.opacity(0.8)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                    }
                    
                    // Stop button
                    Button(action: {
                        stopWorkout()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "stop.fill")
                                .font(.title3)
                            Text("Stop")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.red.opacity(0.8))
                        .cornerRadius(12)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.top, 24) // Space after the timer
    }
    
    private var fixedControlButtonsSection: some View {
        VStack(spacing: 16) {
            // Show Details button - always visible
            Button(action: {
                withAnimation(.easeInOut(duration: 0.6)) {
                    showControlCard = true
                }
            }) {
                Text("Show Exercise Details")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(primaryAccent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
            }
            .padding(.horizontal, 20)
            
            // Control buttons based on workout state
            HStack(spacing: 12) {
                if !isWorkoutStarted {
                    // Start button - only shown when workout hasn't started
                    Button(action: {
                        startWorkout()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "play.fill")
                                .font(.title3)
                            Text("Start")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [primaryAccent, primaryAccent.opacity(0.8)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                    }
                } else {
                    // Pause/Resume button
                    Button(action: {
                        if isWorkoutPaused {
                            resumeWorkout()
                        } else {
                            pauseWorkout()
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: isWorkoutPaused ? "play.fill" : "pause.fill")
                                .font(.title3)
                            Text(isWorkoutPaused ? "Resume" : "Pause")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [primaryAccent, primaryAccent.opacity(0.8)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                    }
                    
                    // Stop button
                    Button(action: {
                        stopWorkout()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "stop.fill")
                                .font(.title3)
                            Text("Stop")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.red.opacity(0.8))
                        .cornerRadius(12)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 34) // Safe area padding
        .background(
            Color(.systemBackground)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -5)
        )
    }
    
    private var controlButtonsSection: some View {
        VStack(spacing: 16) {
            // Primary control buttons
            Button(action: {
                if !isWorkoutStarted {
                    startWorkout()
                } else if isWorkoutPaused {
                    resumeWorkout()
                } else {
                    pauseWorkout()
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: !isWorkoutStarted ? "play.fill" : (isWorkoutPaused ? "play.fill" : "pause.fill"))
                        .font(.title3)
                    Text(!isWorkoutStarted ? "Start" : (isWorkoutPaused ? "Resume" : "Pause"))
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [primaryAccent, primaryAccent.opacity(0.8)]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
            }
            .padding(.horizontal, 20)
            
            // Show Details button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.6)) {
                    showControlCard = true
                }
            }) {
                Text("Show Exercise Details")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(primaryAccent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
            }
            .padding(.horizontal, 20)
        }
        .padding(.top, 20)
    }
    
    private var controlCardView: some View {
        VStack(spacing: 0) {
            // Drag indicator
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 5)
                .padding(.top, 8)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    exerciseDescriptionSection
                    exerciseStatsSection
                    exerciseControlsSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 30)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .ignoresSafeArea(.container, edges: .bottom)
        )
        .frame(maxHeight: UIScreen.main.bounds.height * 0.55) // Increased to cover Show Details button but stop at timer
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .gesture(swipeDownGesture)
    }
    
    private var exerciseDescriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Exercise Guide")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(currentExercise.description)
                .font(.body)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    private var exerciseStatsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Exercise Stats")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            HStack(spacing: 24) {
                VStack(spacing: 4) {
                    Text("SETS")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(primaryAccent)
                    Text("\(currentExercise.sets)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                VStack(spacing: 4) {
                    Text("REPS")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(primaryAccent)
                    Text("\(currentExercise.reps)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                VStack(spacing: 4) {
                    Text("DURATION")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(primaryAccent)
                    Text("\(currentExercise.duration/60)m")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
        }
    }
    
    private var exerciseControlsSection: some View {
        VStack(spacing: 16) {
            // Navigation buttons
            HStack(spacing: 12) {
                // Previous exercise
                if currentExerciseIndex > 0 {
                    Button(action: {
                        previousExercise()
                        withAnimation(.easeInOut(duration: 0.4)) {
                            showControlCard = false
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "chevron.left")
                                .font(.title3)
                            Text("Previous")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(primaryAccent)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                }
                
                // Next exercise or complete - always show
                if currentExerciseIndex < workoutExercises.count - 1 {
                    Button(action: {
                        nextExercise()
                        withAnimation(.easeInOut(duration: 0.4)) {
                            showControlCard = false
                        }
                    }) {
                        HStack(spacing: 8) {
                            Text("Next Exercise")
                                .font(.headline)
                                .fontWeight(.semibold)
                            Image(systemName: "chevron.right")
                                .font(.title3)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [primaryAccent, primaryAccent.opacity(0.8)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                    }
                } else {
                    Button(action: {
                        completeWorkout()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title3)
                            Text("Complete")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.green, Color.green.opacity(0.8)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                    }
                }
            }
        }
    }
    
    private var swipeDownGesture: some Gesture {
        DragGesture()
            .onEnded { value in
                if value.translation.height > 100 {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        showControlCard = false
                    }
                }
            }
    }
    
    // MARK: - Timer Functions
    private func startWorkout() {
        isWorkoutStarted = true
        isWorkoutPaused = false
        isVideoPlaying = true
        player?.play()
        startTimer()
    }
    
    private func pauseWorkout() {
        isWorkoutPaused = true
        isVideoPlaying = false
        player?.pause()
        stopTimer()
    }
    
    private func resumeWorkout() {
        isWorkoutPaused = false
        isVideoPlaying = true
        player?.play()
        startTimer()
    }
    
    private func stopWorkout() {
        stopTimer()
        player?.pause()
        isVideoPlaying = false
        isWorkoutStarted = false
        showingCompletionAlert = true
    }
    
    private func startTimer() {
        // Stop any existing timer first
        stopTimer()
        
        workoutTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            totalWorkoutTime += 100 // Add 100ms
            
            let totalSeconds = totalWorkoutTime / 1000
            timerMinutes = totalSeconds / 60
            timerSeconds = totalSeconds % 60
            timerMilliseconds = (totalWorkoutTime % 1000) / 10
        }
    }
    
    private func stopTimer() {
        workoutTimer?.invalidate()
        workoutTimer = nil
    }
    
    private func cleanupTimer() {
        stopTimer()
    }
    
    // MARK: - Exercise Navigation
    private func nextExercise() {
        if currentExerciseIndex < workoutExercises.count - 1 {
            pauseWorkout()
            currentExerciseIndex += 1
            setupVideoPlayer()
            resetExerciseTimer()
        }
    }
    
    private func previousExercise() {
        if currentExerciseIndex > 0 {
            pauseWorkout()
            currentExerciseIndex -= 1
            setupVideoPlayer()
            resetExerciseTimer()
        }
    }
    
    private func resetExerciseTimer() {
        totalWorkoutTime = 0
        timerMinutes = 0
        timerSeconds = 0
        timerMilliseconds = 0
    }
    
    private func completeWorkout() {
        pauseWorkout()
        isWorkoutCompleted = true
        saveWorkoutData()
        showingCompletionAlert = true
    }
    
    // MARK: - Video Setup
    private func setupVideoPlayer() {
        // For now, we'll use a placeholder URL
        // In production, you'd fetch from Core Data and convert YouTube URL
        if let url = URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4") {
            player = AVPlayer(url: url)
        }
    }
    
    // MARK: - Data Persistence
    private func saveWorkoutData() {
        // TODO: Implement Core Data saving
        let workoutData: [String: Any] = [
            "workoutName": workoutName,
            "exercisesCompleted": currentExerciseIndex + 1,
            "totalTime": totalWorkoutTime,
            "completedAt": Date(),
            "exercises": workoutExercises.prefix(currentExerciseIndex + 1).map { exercise in
                return [
                    "name": exercise.name,
                    "sets": exercise.sets,
                    "reps": exercise.reps,
                    "duration": exercise.duration
                ] as [String: Any]
            }
        ]
        
        print("Workout data to save:", workoutData)
        // TODO: Save to Firebase when backend is ready
    }
}

struct WorkoutExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            WorkoutExerciseView()
                .environmentObject(NavigationCoordinator())
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
