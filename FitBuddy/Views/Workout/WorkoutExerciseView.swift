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
            backgroundImage: "screen-one"
        ),
        WorkoutExercise(
            name: "Barbell training",
            description: "Keep your core tight and maintain proper form throughout the movement. Focus on controlled movements.",
            videoURL: "https://www.youtube.com/watch?v=example2",
            duration: 300, // 5 minutes
            sets: 4,
            reps: 12,
            backgroundImage: "screen-two"
        ),
        WorkoutExercise(
            name: "Kettlebell training",
            description: "Use full body movement and engage your core. Keep the kettlebell close to your body.",
            videoURL: "https://www.youtube.com/watch?v=example3",
            duration: 240, // 4 minutes
            sets: 3,
            reps: 10,
            backgroundImage: "bgimage-workout"
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
            VStack(spacing: 0) {
                // Header with progress
                VStack(spacing: 12) {
                    // Top navigation
                    HStack {
                        Button(action: {
                            if currentExerciseIndex > 0 {
                                // Go to previous exercise
                                previousExercise()
                            } else {
                                // If first exercise, go back using NavigationCoordinator
                                pauseWorkout()
                                navigationCoordinator.goBack()
                            }
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.white)
                                .font(.title2)
                        }
                        
                        Spacer()
                        
                        // Exercise progress
                        Text("\(currentExerciseIndex + 1)/\(workoutExercises.count)")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.6), radius: 1, x: 0, y: 1)
                        
                        Spacer()
                        
                        Button(action: {
                            pauseWorkout()
                            navigationCoordinator.goBack()
                        }) {
                            Image(systemName: "xmark")
                                .foregroundColor(.white)
                                .font(.title2)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    // Progress bar
                    ProgressView(value: Double(currentExerciseIndex), total: Double(workoutExercises.count))
                        .progressViewStyle(LinearProgressViewStyle(tint: Color(red: 0.7, green: 1.0, blue: 0.3)))
                        .scaleEffect(x: 1, y: 2, anchor: .center)
                        .padding(.horizontal, 20)
                }
                
                // Video player section
                VStack(spacing: 12) {
                    if let player = player {
                        VideoPlayer(player: player)
                            .frame(height: 220)
                            .cornerRadius(16)
                            .padding(.horizontal, 20)
                    } else {
                        // Placeholder while loading
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.black.opacity(0.3))
                            .frame(height: 220)
                            .overlay(
                                VStack {
                                    Image(systemName: "play.circle.fill")
                                        .font(.system(size: 50))
                                        .foregroundColor(Color(red: 0.7, green: 1.0, blue: 0.3))
                                    Text("Loading video...")
                                        .foregroundColor(.white)
                                        .font(.subheadline)
                                }
                            )
                            .padding(.horizontal, 20)
                    }
                    
                    // Exercise name
                    Text(currentExercise.name)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.7), radius: 2, x: 0, y: 1)
                        .padding(.horizontal, 20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Spacer()
                
                // Bottom controls section
                VStack(spacing: 20) {
                    // Exercise description
                    Text(currentExercise.description)
                        .font(.body)
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.6), radius: 1, x: 0, y: 1)
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal, 20)
                    
                    // Sets and Reps info
                    HStack(spacing: 30) {
                        VStack {
                            Text("SETS")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(Color(red: 0.7, green: 1.0, blue: 0.3))
                            Text("\(currentExercise.sets)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.6), radius: 1, x: 0, y: 1)
                        }
                        
                        VStack {
                            Text("REPS")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(Color(red: 0.7, green: 1.0, blue: 0.3))
                            Text("\(currentExercise.reps)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.6), radius: 1, x: 0, y: 1)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    
                    // Timer display
                    HStack(spacing: 4) {
                        Image(systemName: "timer")
                            .foregroundColor(Color(red: 0.7, green: 1.0, blue: 0.3))
                            .font(.title2)
                        
                        Text(String(format: "%02d:%02d:%02d", timerMinutes, timerSeconds, timerMilliseconds/10))
                            .font(.system(size: 32, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.8), radius: 2, x: 0, y: 1)
                    }
                    .padding(.horizontal, 20)
                    
                    // Control buttons
                    HStack(spacing: 16) {
                        // Start/Resume button
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
                                Text(!isWorkoutStarted ? "START" : (isWorkoutPaused ? "RESUME" : "PAUSE"))
                                    .font(.headline)
                                    .fontWeight(.bold)
                            }
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color(red: 0.7, green: 1.0, blue: 0.3))
                            .cornerRadius(12)
                        }
                        
                        // Stop button
                        Button(action: {
                            stopWorkout()
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "stop.fill")
                                    .font(.title3)
                                Text("STOP")
                                    .font(.headline)
                                    .fontWeight(.bold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.red.opacity(0.7))
                            .cornerRadius(12)
                        }
                        .disabled(!isWorkoutStarted)
                    }
                    .padding(.horizontal, 20)
                    
                    // Next exercise button (if not last exercise)
                    if currentExerciseIndex < workoutExercises.count - 1 {
                        Button(action: {
                            nextExercise()
                        }) {
                            HStack(spacing: 8) {
                                Text("NEXT EXERCISE")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                Image(systemName: "arrow.right")
                                    .font(.title3)
                            }
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal, 20)
                    } else {
                        // Complete workout button
                        Button(action: {
                            completeWorkout()
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title3)
                                Text("COMPLETE WORKOUT")
                                    .font(.headline)
                                    .fontWeight(.bold)
                            }
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color(red: 0.7, green: 1.0, blue: 0.3))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.bottom, 30) // Reduced space for better layout
            }
        }
        .background(
            ZStack {
                // Dynamic background image based on current exercise
                Image(currentExercise.backgroundImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
                    .ignoresSafeArea()
                
                // Gradient overlay - dark at top, lighter at bottom
                LinearGradient(
                    colors: [
                        Color.black.opacity(0.8), // Darker at top for video visibility
                        Color.black.opacity(0.5), // Medium in middle
                        Color.black.opacity(0.2)  // Light at bottom
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
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
