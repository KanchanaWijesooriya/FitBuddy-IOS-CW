import SwiftUI

struct StepTrackerView: View {
    @State private var selectedPeriod = "Day"
    @State private var currentSteps: Int = 1447
    @State private var goalSteps: Int = 10000
    @State private var calories: Int = 45
    @State private var distance: Double = 1.0 // km
    @State private var activeTime: Int = 13 // minutes
    @State private var isWorkoutActive = false
    @State private var isWorkoutPaused = false
    @State private var workoutStartTime: Date?
    @State private var workoutElapsedTime: Int = 0
    @State private var pausedElapsedTime: Int = 0 // Track time when paused
    @State private var timer: Timer?
    @State private var selectedDate = Date()
    
    let periods = ["Day", "Week", "Month"]
    
    // App's consistent theme colors
    private let primaryAccent = Color(red: 0.7, green: 1.0, blue: 0.3)
    private let stepBlue = Color(red: 0.2, green: 0.6, blue: 0.9)
    private let lightBlue = Color(red: 0.3, green: 0.7, blue: 1.0)
    private let darkBlue = Color(red: 0.1, green: 0.4, blue: 0.7)
    
    // Haptic feedback generators
    private let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    private let lightFeedback = UIImpactFeedbackGenerator(style: .light)
    
    // Date formatter for days
    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter
    }()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()
    
    // Get 7 days starting from 3 days ago
    private var weekDates: [Date] {
        let calendar = Calendar.current
        let today = Date()
        return (-3...3).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: today)
        }
    }
    
    // Progress calculation
    var progressPercentage: Double {
        return min(Double(currentSteps) / Double(goalSteps), 1.0)
    }
    
    var isGoalAchieved: Bool {
        return currentSteps >= goalSteps
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header (matching WaterGlassView style)
                VStack(alignment: .leading, spacing: 0) {
                    Button(action: {
                        impactFeedback.impactOccurred()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                                .foregroundColor(primaryAccent)
                            Text("Back")
                                .font(.headline)
                                .foregroundColor(primaryAccent)
                        }
                    }
                    .padding(.top, 24)
                    .padding(.leading, 24)
                    
                    HStack {
                        Text("Step Tracker")
                            .font(.system(.largeTitle, design: .default))
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                        Spacer()
                        Image(systemName: "figure.walk.circle")
                            .resizable()
                            .frame(width: 36, height: 36)
                            .foregroundColor(primaryAccent)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                }

                // Date Selector (matching WaterGlassView)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(weekDates, id: \.self) { date in
                            let isToday = Calendar.current.isDate(date, inSameDayAs: Date())
                            let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedDate)
                            
                            Button(action: {
                                lightFeedback.impactOccurred()
                                selectedDate = date
                            }) {
                                VStack(spacing: 2) {
                                    Text(dayFormatter.string(from: date))
                                        .font(.system(.caption2, design: .default))
                                        .fontWeight(isSelected ? .bold : .regular)
                                        .foregroundColor(isSelected ? .white : .black)
                                    Text(dateFormatter.string(from: date))
                                        .font(.system(.subheadline, design: .default))
                                        .fontWeight(isSelected ? .bold : .regular)
                                        .foregroundColor(isSelected ? .white : .black)
                                    if isToday {
                                        Circle()
                                            .fill(isSelected ? .white : primaryAccent)
                                            .frame(width: 4, height: 4)
                                    }
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(isSelected ? primaryAccent : Color(.systemGray5))
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 8)
                }

                // Main content in ScrollView
                ScrollView {
                    VStack(spacing: 24) {
                        // Enhanced Circular Progress View
                        VStack(spacing: 20) {
                            Text("Today's Progress")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                                .padding(.horizontal, 24)
                            
                            ZStack {
                                // Background circle with subtle gradient
                                Circle()
                                    .stroke(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(.systemGray5),
                                                Color(.systemGray6)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 24
                                    )
                                    .frame(width: 260, height: 260)
                                
                                // Enhanced gradient progress circle
                                Circle()
                                    .trim(from: 0, to: progressPercentage)
                                    .stroke(
                                        LinearGradient(
                                            gradient: Gradient(colors: [primaryAccent, stepBlue, Color(red: 0.2, green: 0.5, blue: 0.9), darkBlue]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        style: StrokeStyle(lineWidth: 24, lineCap: .round)
                                    )
                                    .frame(width: 260, height: 260)
                                    .rotationEffect(.degrees(-90))
                                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progressPercentage)
                                
                                // Enhanced center content
                                VStack(spacing: 8) {
                                    if isGoalAchieved {
                                        Image(systemName: "checkmark.seal.fill")
                                            .font(.system(size: 24))
                                            .foregroundColor(primaryAccent)
                                    }
                                    
                                    Image(systemName: "figure.walk")
                                        .font(.system(size: 36))
                                        .foregroundColor(primaryAccent)
                                    
                                    Text("\(currentSteps)")
                                        .font(.system(size: 36, weight: .bold, design: .rounded))
                                        .foregroundColor(.primary)
                                        .contentTransition(.numericText())
                                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: currentSteps)
                                    
                                    Text("steps today")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Text("\(Int(progressPercentage * 100))% of \(goalSteps.formatted())")
                                        .font(.caption2)
                                        .fontWeight(.medium)
                                        .foregroundColor(stepBlue)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background(stepBlue.opacity(0.1))
                                        .cornerRadius(6)
                                }
                            }
                        }
                        
                        // Enhanced Stats Cards
                        VStack(spacing: 16) {
                            HStack {
                                Text("Activity Stats")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.black)
                                Spacer()
                            }
                            .padding(.horizontal, 24)
                            
                            HStack(spacing: 16) {
                                // Calories Card
                                StatCard(
                                    icon: "flame.fill",
                                    value: "\(calories)",
                                    unit: "kcal",
                                    color: Color.orange,
                                    progress: 0.3
                                )
                                
                                // Distance Card
                                StatCard(
                                    icon: "location.fill",
                                    value: String(format: "%.1f", distance),
                                    unit: "km",
                                    color: stepBlue,
                                    progress: 0.6
                                )
                                
                                // Active Time Card
                                StatCard(
                                    icon: "clock.fill",
                                    value: "\(activeTime)",
                                    unit: "min",
                                    color: primaryAccent,
                                    progress: 0.4
                                )
                            }
                            .padding(.horizontal, 24)
                        }
                        
                        // Workout Section
                        VStack(spacing: 16) {
                            HStack {
                                Text(isWorkoutActive ? "Workout in Progress" : "Start Workout")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.black)
                                Spacer()
                            }
                            .padding(.horizontal, 24)
                            
                            // Workout Card
                            VStack(spacing: 20) {
                                if isWorkoutActive {
                                    // Active workout display
                                    VStack(spacing: 12) {
                                        // Status icon and timer
                                        VStack(spacing: 8) {
                                            Image(systemName: isWorkoutPaused ? "pause.circle.fill" : "stopwatch.fill")
                                                .font(.system(size: 40))
                                                .foregroundColor(isWorkoutPaused ? Color.orange : primaryAccent)
                                                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isWorkoutPaused)
                                            
                                            Text(formatTime(workoutElapsedTime))
                                                .font(.system(size: 32, weight: .bold, design: .monospaced))
                                                .foregroundColor(.black)
                                                .opacity(isWorkoutPaused ? 0.6 : 1.0)
                                                .animation(.easeInOut(duration: 0.3), value: isWorkoutPaused)
                                            
                                            Text(isWorkoutPaused ? "Workout Paused" : "Workout Time")
                                                .font(.subheadline)
                                                .foregroundColor(isWorkoutPaused ? Color.orange : .secondary)
                                                .animation(.easeInOut(duration: 0.3), value: isWorkoutPaused)
                                        }
                                        
                                        // Live step counter during workout with gradient circles
                                        HStack(spacing: 30) {
                                            // Steps with gradient circle
                                            VStack(spacing: 8) {
                                                ZStack {
                                                    // Background circle
                                                    Circle()
                                                        .stroke(
                                                            LinearGradient(
                                                                gradient: Gradient(colors: [
                                                                    Color(.systemGray6),
                                                                    Color(.systemGray5)
                                                                ]),
                                                                startPoint: .topLeading,
                                                                endPoint: .bottomTrailing
                                                            ),
                                                            lineWidth: 8
                                                        )
                                                        .frame(width: 80, height: 80)
                                                    
                                                    // Progress circle
                                                    Circle()
                                                        .trim(from: 0, to: min(Double(currentSteps) / Double(goalSteps), 1.0))
                                                        .stroke(
                                                            LinearGradient(
                                                                gradient: Gradient(colors: [
                                                                    primaryAccent,
                                                                    Color(red: 0.4, green: 0.9, blue: 0.2),
                                                                    stepBlue
                                                                ]),
                                                                startPoint: .topLeading,
                                                                endPoint: .bottomTrailing
                                                            ),
                                                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                                                        )
                                                        .frame(width: 80, height: 80)
                                                        .rotationEffect(.degrees(-90))
                                                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: currentSteps)
                                                        .opacity(isWorkoutPaused ? 0.6 : 1.0)
                                                        .animation(.easeInOut(duration: 0.3), value: isWorkoutPaused)
                                                    
                                                    // Center content
                                                    VStack(spacing: 2) {
                                                        Text("\(currentSteps)")
                                                            .font(.title3)
                                                            .fontWeight(.bold)
                                                            .foregroundColor(primaryAccent)
                                                            .opacity(isWorkoutPaused ? 0.6 : 1.0)
                                                        Text("Steps")
                                                            .font(.caption2)
                                                            .foregroundColor(.secondary)
                                                            .opacity(isWorkoutPaused ? 0.6 : 1.0)
                                                    }
                                                    .animation(.easeInOut(duration: 0.3), value: isWorkoutPaused)
                                                }
                                            }
                                            
                                            // Calories with gradient circle
                                            VStack(spacing: 8) {
                                                ZStack {
                                                    // Background circle
                                                    Circle()
                                                        .stroke(
                                                            LinearGradient(
                                                                gradient: Gradient(colors: [
                                                                    Color(.systemGray6),
                                                                    Color(.systemGray5)
                                                                ]),
                                                                startPoint: .topLeading,
                                                                endPoint: .bottomTrailing
                                                            ),
                                                            lineWidth: 8
                                                        )
                                                        .frame(width: 80, height: 80)
                                                    
                                                    // Progress circle (assuming goal of 100 calories for demo)
                                                    Circle()
                                                        .trim(from: 0, to: min(Double(calories) / 100.0, 1.0))
                                                        .stroke(
                                                            LinearGradient(
                                                                gradient: Gradient(colors: [
                                                                    Color.orange,
                                                                    Color.red
                                                                ]),
                                                                startPoint: .topLeading,
                                                                endPoint: .bottomTrailing
                                                            ),
                                                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                                                        )
                                                        .frame(width: 80, height: 80)
                                                        .rotationEffect(.degrees(-90))
                                                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: calories)
                                                        .opacity(isWorkoutPaused ? 0.6 : 1.0)
                                                        .animation(.easeInOut(duration: 0.3), value: isWorkoutPaused)
                                                    
                                                    // Center content
                                                    VStack(spacing: 2) {
                                                        Text("\(calories)")
                                                            .font(.title3)
                                                            .fontWeight(.bold)
                                                            .foregroundColor(.orange)
                                                            .opacity(isWorkoutPaused ? 0.6 : 1.0)
                                                        Text("kcal")
                                                            .font(.caption2)
                                                            .foregroundColor(.secondary)
                                                            .opacity(isWorkoutPaused ? 0.6 : 1.0)
                                                    }
                                                    .animation(.easeInOut(duration: 0.3), value: isWorkoutPaused)
                                                }
                                            }
                                        }
                                        
                                        // Control Buttons Row
                                        HStack(spacing: 16) {
                                            // Pause/Resume Button
                                            Button(action: {
                                                impactFeedback.impactOccurred()
                                                togglePause()
                                            }) {
                                                HStack(spacing: 8) {
                                                    Image(systemName: isWorkoutPaused ? "play.fill" : "pause.fill")
                                                        .font(.system(size: 16, weight: .semibold))
                                                    Text(isWorkoutPaused ? "Resume" : "Pause")
                                                        .font(.subheadline)
                                                        .fontWeight(.semibold)
                                                }
                                                .foregroundColor(.white)
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 12)
                                                .background(
                                                    LinearGradient(
                                                        gradient: Gradient(colors: isWorkoutPaused ? [primaryAccent, stepBlue] : [Color.orange, Color.yellow]),
                                                        startPoint: .leading,
                                                        endPoint: .trailing
                                                    )
                                                )
                                                .cornerRadius(12)
                                            }
                                            .accessibilityLabel(isWorkoutPaused ? "Resume workout" : "Pause workout")
                                            
                                            // Stop Button
                                            Button(action: {
                                                impactFeedback.impactOccurred()
                                                stopWorkout()
                                            }) {
                                                HStack(spacing: 8) {
                                                    Image(systemName: "stop.fill")
                                                        .font(.system(size: 16, weight: .semibold))
                                                    Text("Stop")
                                                        .font(.subheadline)
                                                        .fontWeight(.semibold)
                                                }
                                                .foregroundColor(.white)
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 12)
                                                .background(
                                                    LinearGradient(
                                                        gradient: Gradient(colors: [Color.red, Color.orange]),
                                                        startPoint: .leading,
                                                        endPoint: .trailing
                                                    )
                                                )
                                                .cornerRadius(12)
                                            }
                                            .accessibilityLabel("Stop workout")
                                        }
                                        .padding(.top, 8)
                                    }
                                } else {
                                    // Start workout display (removed large play button)
                                    VStack(spacing: 16) {
                                        Text("Ready to Start?")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.black)
                                        
                                        Text("Track your steps and calories in real-time")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                            .multilineTextAlignment(.center)
                                            .padding(.horizontal, 16)
                                    }
                                }
                                
                                // Action Button - Only show Start button when workout is not active
                                if !isWorkoutActive {
                                    Button(action: {
                                        impactFeedback.impactOccurred()
                                        startWorkout()
                                    }) {
                                        HStack(spacing: 12) {
                                            Image(systemName: "play.fill")
                                                .font(.system(size: 18, weight: .semibold))
                                            
                                            Text("Start Workout")
                                                .font(.headline)
                                                .fontWeight(.semibold)
                                        }
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 16)
                                        .background(
                                            LinearGradient(
                                                gradient: Gradient(colors: [primaryAccent, stepBlue]),
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .cornerRadius(16)
                                    }
                                    .accessibilityLabel("Start workout tracking")
                                }
                            }
                            .padding(24)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.98, green: 1.0, blue: 0.96),
                                        Color(red: 0.94, green: 0.98, blue: 1.0)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(20)
                            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                            .padding(.horizontal, 24)
                        }
                        
                        Spacer(minLength: 100) // Space for bottom navigation
                    }
                    .padding(.top, 12)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            selectedDate = Date()
        }
        .onDisappear {
            stopWorkoutTimer()
        }
        .overlay(
            // Fixed Bottom Navigation
            VStack {
                Spacer()
                BottomNavigationBar(selectedTab: "Status")
            }
        )
    }
    
    // MARK: - Workout Functions
    
    private func toggleWorkout() {
        if isWorkoutActive {
            stopWorkout()
        } else {
            startWorkout()
        }
    }
    
    private func togglePause() {
        isWorkoutPaused.toggle()
        
        if isWorkoutPaused {
            // Pause the workout - store the current elapsed time
            pausedElapsedTime = workoutElapsedTime
            stopWorkoutTimer()
        } else {
            // Resume the workout - start timer from where we left off
            startWorkoutTimer()
        }
    }
    
    private func startWorkout() {
        isWorkoutActive = true
        isWorkoutPaused = false
        workoutStartTime = Date()
        workoutElapsedTime = 0
        pausedElapsedTime = 0
        startWorkoutTimer()
    }
    
    private func startWorkoutTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if !isWorkoutPaused {
                workoutElapsedTime += 1
                
                // Simulate step counting during workout (in real app, you'd use HealthKit)
                if workoutElapsedTime % 3 == 0 { // Add step every 3 seconds for demo
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        currentSteps += Int.random(in: 1...3)
                        calories += Int.random(in: 0...1)
                    }
                }
            }
        }
    }
    
    private func stopWorkout() {
        isWorkoutActive = false
        isWorkoutPaused = false
        stopWorkoutTimer()
        
        // In real app, you'd save workout data to HealthKit/Core Data
        let totalMinutes = workoutElapsedTime / 60
        activeTime += totalMinutes
        
        // Reset timer
        workoutStartTime = nil
        workoutElapsedTime = 0
        pausedElapsedTime = 0
    }
    
    private func stopWorkoutTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}

// Enhanced Stat Card Component
struct StatCard: View {
    let icon: String
    let value: String
    let unit: String
    let color: Color
    let progress: Double
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                // Background circle with much darker, more visible gradient
                Circle()
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(.systemGray2),
                                Color(.systemGray)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 6
                    )
                    .frame(width: 60, height: 60)
                
                // Progress circle with tighter gradient
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                color,
                                color.opacity(0.5)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progress)
                
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
            }
            
            VStack(spacing: 2) {
                Text(value)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                
                Text(unit)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.white,
                    color.opacity(0.05)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
    }
}

struct StepTrackerView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            StepTrackerView()
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
