import SwiftUI

struct StepTrackerView: View {
    @State private var currentSteps: Int = 1447
    @State private var goalSteps: Int = 10000
    @State private var calories: Int = 45
    @State private var distance: Double = 1.0 // km
    @State private var activeTime: Int = 13 // minutes
    
    // Timer states
    @State private var isWorkoutActive = false
    @State private var isWorkoutPaused = false
    @State private var workoutTime: Int = 0
    @State private var pausedWorkoutTime: Int = 0
    @State private var timer: Timer?
    @State private var selectedDate = Date()
    
    // Date formatter for days
    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E" // Mon, Tue, Wed, etc.
        return formatter
    }()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d" // 1, 2, 3, etc.
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
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Main scrollable content
            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    VStack(alignment: .leading, spacing: 0) {
                        Button(action: {
                            // Back action
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                    .font(.title2)
                                    .foregroundColor(Color(red: 0.7, green: 1.0, blue: 0.3))
                                Text("Back")
                                    .font(.headline)
                                    .foregroundColor(Color(red: 0.7, green: 1.0, blue: 0.3))
                            }
                        }
                        .padding(.top, 24)
                        .padding(.leading, 24)
                        
                        HStack {
                            Text("Step Counting")
                                .font(.system(.largeTitle, design: .default))
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                            Spacer()
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 8)
                    }
                    .background(Color(.systemBackground))
                    
                    // Weekly Date Selector
                    HStack(spacing: 0) {
                        ForEach(weekDates, id: \.self) { date in
                            let isToday = Calendar.current.isDate(date, inSameDayAs: Date())
                            let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedDate)
                            
                            Button(action: { selectedDate = date }) {
                                VStack(spacing: 8) {
                                    Text(dayFormatter.string(from: date).uppercased())
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(isSelected ? .white : .gray)
                                    
                                    Text(dateFormatter.string(from: date))
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(isSelected ? .white : .black)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 70)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(isToday && isSelected ? Color(red: 0.7, green: 1.0, blue: 0.3) : 
                                             isSelected ? Color.gray : Color.clear)
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                    .padding(.bottom, 30)
                    
                    // Main Circular Progress View
                    VStack(spacing: 40) {
                        ZStack {
                            // Background circle
                            Circle()
                                .stroke(Color(.systemGray5), lineWidth: 30)
                                .frame(width: 280, height: 280)
                            
                            // Progress circle with gradient
                            Circle()
                                .trim(from: 0, to: progressPercentage)
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 0.4, green: 0.8, blue: 0.2),  // Darker green start
                                            Color(red: 0.7, green: 1.0, blue: 0.3),  // Main green
                                            Color(red: 0.5, green: 0.9, blue: 0.1),  // Vibrant green
                                            Color(red: 0.8, green: 1.0, blue: 0.4)   // Light green end
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    style: StrokeStyle(lineWidth: 30, lineCap: .round)
                                )
                                .frame(width: 280, height: 280)
                                .rotationEffect(.degrees(-90))
                                .animation(.easeInOut(duration: 1.0), value: progressPercentage)
                                .shadow(color: Color(red: 0.7, green: 1.0, blue: 0.3).opacity(0.3), radius: 8, x: 0, y: 4)
                            
                            // Center content
                            VStack(spacing: 8) {
                                Image(systemName: "figure.walk")
                                    .font(.system(size: 40))
                                    .foregroundColor(Color(red: 0.7, green: 1.0, blue: 0.3))
                                
                                Text("\(currentSteps)")
                                    .font(.system(size: 48, weight: .bold, design: .default))
                                    .foregroundColor(.black)
                                
                                Text("Today")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                
                                Text("GOAL \(goalSteps.formatted())")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        // Stats Row
                        HStack(spacing: 0) {
                            // Calories
                            VStack(spacing: 8) {
                                ZStack {
                                    Circle()
                                        .stroke(Color(.systemGray5), lineWidth: 12)
                                        .frame(width: 70, height: 70)
                                    
                                    Circle()
                                        .trim(from: 0, to: 0.3) // Example progress
                                        .stroke(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color(red: 0.6, green: 0.9, blue: 0.2),
                                                    Color(red: 0.8, green: 1.0, blue: 0.4)
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                                        )
                                        .frame(width: 70, height: 70)
                                        .rotationEffect(.degrees(-90))
                                    
                                    Image(systemName: "flame.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(Color(red: 0.7, green: 1.0, blue: 0.3))
                                }
                                
                                Text("\(calories) kcal")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.black)
                            }
                            .frame(maxWidth: .infinity)
                            
                            // Distance
                            VStack(spacing: 8) {
                                ZStack {
                                    Circle()
                                        .stroke(Color(.systemGray5), lineWidth: 12)
                                        .frame(width: 70, height: 70)
                                    
                                    Circle()
                                        .trim(from: 0, to: 0.6) // Example progress
                                        .stroke(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color(red: 0.5, green: 0.8, blue: 0.2),
                                                    Color(red: 0.7, green: 1.0, blue: 0.3),
                                                    Color(red: 0.6, green: 0.9, blue: 0.1)
                                                ]),
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            ),
                                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                                        )
                                        .frame(width: 70, height: 70)
                                        .rotationEffect(.degrees(-90))
                                    
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 20))
                                        .foregroundColor(Color(red: 0.7, green: 1.0, blue: 0.3))
                                }
                                
                                Text("\(distance, specifier: "%.1f") km")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.black)
                            }
                            .frame(maxWidth: .infinity)
                            
                            // Active Time
                            VStack(spacing: 8) {
                                ZStack {
                                    Circle()
                                        .stroke(Color(.systemGray5), lineWidth: 12)
                                        .frame(width: 70, height: 70)
                                    
                                    Circle()
                                        .trim(from: 0, to: 0.8) // Example progress
                                        .stroke(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color(red: 0.4, green: 0.8, blue: 0.1),
                                                    Color(red: 0.7, green: 1.0, blue: 0.3),
                                                    Color(red: 0.8, green: 1.0, blue: 0.4)
                                                ]),
                                                startPoint: .topTrailing,
                                                endPoint: .bottomLeading
                                            ),
                                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                                        )
                                        .frame(width: 70, height: 70)
                                        .rotationEffect(.degrees(-90))
                                    
                                    Image(systemName: "clock.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(Color(red: 0.7, green: 1.0, blue: 0.3))
                                }
                                
                                Text("\(activeTime) min")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.black)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.horizontal, 40)
                    }
                    .padding(.vertical, 20)
                    
                    // Workout Controls Section
                    VStack(spacing: 20) {
                        // Timer Display
                        VStack(spacing: 8) {
                            Text("Workout Timer")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                            
                            Text(timeString(workoutTime))
                                .font(.system(size: 36, weight: .bold, design: .monospaced))
                                .foregroundColor(Color(red: 0.7, green: 1.0, blue: 0.3))
                        }
                        
                        // Start/Stop/Resume Buttons
                        VStack(spacing: 16) {
                            // Start Workout Button (only show when no workout is active or paused)
                            if !isWorkoutActive && !isWorkoutPaused {
                                Button(action: startWorkout) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "play.fill")
                                        Text("Start Workout")
                                    }
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(Color(red: 0.7, green: 1.0, blue: 0.3))
                                    .cornerRadius(25)
                                }
                            }
                            
                            // Two buttons row when workout is active or paused
                            if isWorkoutActive || isWorkoutPaused {
                                HStack(spacing: 16) {
                                    // Stop/Pause Button
                                    Button(action: isWorkoutActive ? pauseWorkout : stopWorkout) {
                                        HStack(spacing: 8) {
                                            Image(systemName: isWorkoutActive ? "pause.fill" : "stop.fill")
                                            Text(isWorkoutActive ? "Pause" : "Stop")
                                        }
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(Color(red: 0.7, green: 1.0, blue: 0.3))
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 50)
                                        .background(Color.white)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 25)
                                                .stroke(Color(red: 0.7, green: 1.0, blue: 0.3), lineWidth: 2)
                                        )
                                        .cornerRadius(25)
                                    }
                                    
                                    // Resume Button (only show when paused)
                                    if isWorkoutPaused {
                                        Button(action: resumeWorkout) {
                                            HStack(spacing: 8) {
                                                Image(systemName: "play.fill")
                                                Text("Resume")
                                            }
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.black)
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 50)
                                            .background(Color(red: 0.7, green: 1.0, blue: 0.3))
                                            .cornerRadius(25)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                    .padding(.bottom, 100) // Space for bottom navigation
                }
            }
            
            // Bottom Navigation - Fixed at bottom
            BottomNavigationBar(selectedTab: "Status")
        }
        .background(Color(.systemBackground))
        .navigationBarHidden(true)
        .onAppear {
            selectedDate = Date() // Set today as default
        }
    }
    
    // Timer functions
    func startWorkout() {
        // Start a completely new workout
        isWorkoutActive = true
        isWorkoutPaused = false
        workoutTime = 0
        pausedWorkoutTime = 0
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            workoutTime += 1
        }
        
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    func pauseWorkout() {
        // Pause the current workout
        isWorkoutActive = false
        isWorkoutPaused = true
        pausedWorkoutTime = workoutTime
        timer?.invalidate()
        timer = nil
        
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    func resumeWorkout() {
        // Resume from where it was paused
        isWorkoutActive = true
        isWorkoutPaused = false
        workoutTime = pausedWorkoutTime
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            workoutTime += 1
        }
        
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    func stopWorkout() {
        // Completely stop the workout and reset
        isWorkoutActive = false
        isWorkoutPaused = false
        workoutTime = 0
        pausedWorkoutTime = 0
        timer?.invalidate()
        timer = nil
        
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
    }
    
    func timeString(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}

struct StepTrackerView_Previews: PreviewProvider {
    static var previews: some View {
        StepTrackerView()
    }
}
