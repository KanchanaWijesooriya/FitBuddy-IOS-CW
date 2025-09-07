import SwiftUI

struct StepTrackerView: View {
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
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
    
    // Modern fitness app color scheme
    private let primaryAccent = Color(red: 0.0, green: 0.48, blue: 1.0) // Apple Blue
    private let stepBlue = Color(red: 0.2, green: 0.6, blue: 0.9)
    private let lightBlue = Color(red: 0.3, green: 0.7, blue: 1.0)
    private let darkBlue = Color(red: 0.1, green: 0.4, blue: 0.7)
    private let fitnessGreen = Color(red: 0.2, green: 0.78, blue: 0.35) // Apple Fitness Green
    private let vibrantOrange = Color(red: 1.0, green: 0.58, blue: 0.0) // Apple Orange
    private let softPurple = Color(red: 0.69, green: 0.32, blue: 0.87) // Modern Purple
    private let cardBackground = Color(.secondarySystemBackground)
    private let surfaceColor = Color(.systemBackground)
    
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
        VStack(spacing: 0) {
            headerSection
            dateSelector
            
            ScrollView {
                VStack(spacing: 28) { // Increased spacing from 24 to 28
                    progressRingSection
                    activityMetricsSection
                    workoutSection
                }
                .padding(.top, 20) // Added top padding to create gap after date selector
                .padding(.bottom, 100)
            }
        }
        .navigationBarHidden(true)
        .background(Color(.systemGroupedBackground))
        .onAppear {
            selectedDate = Date()
        }
        .onDisappear {
            stopWorkoutTimer()
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                BackButton()
                Spacer()
                statusIndicator
            }
            .padding(.top, 8)
            .padding(.horizontal, 24)
            
            titleSection
        }
    }
    
    private var statusIndicator: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(fitnessGreen)
                .frame(width: 8, height: 8)
            
            Text("Live Tracking")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Capsule().fill(cardBackground))
    }
    
    private var titleSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Step Tracker")
                    .font(.system(.largeTitle, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Track your daily movement")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer(minLength: 20)
            modernFitnessRingIcon
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }
    
    private var modernFitnessRingIcon: some View {
        ZStack {
            Circle()
                .stroke(primaryAccent.opacity(0.2), lineWidth: 5)
                .frame(width: 60, height: 60)
            
            Circle()
                .trim(from: 0, to: progressPercentage)
                .stroke(
                    LinearGradient(
                        colors: [primaryAccent, fitnessGreen, stepBlue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 5, lineCap: .round)
                )
                .frame(width: 60, height: 60)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 1.0), value: progressPercentage)
            
            VStack(spacing: 1) {
                Text("\(Int(progressPercentage * 100))%")
                    .font(.system(.caption2, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Goal")
                    .font(.system(.caption2, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .scaleEffect(0.8)
            }
        }
    }
    
    // MARK: - Date Selector
    private var dateSelector: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(weekDates, id: \.self) { date in
                        dateButton(for: date)
                            .id(date)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16) // Increased padding
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(surfaceColor)
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
            )
            .padding(.horizontal, 20)
            .padding(.bottom, 8) // Added bottom padding
            .onAppear {
                // Center today's date when view appears
                withAnimation(.easeInOut(duration: 0.5)) {
                    proxy.scrollTo(selectedDate, anchor: .center)
                }
            }
        }
    }
    
    private func dateButton(for date: Date) -> some View {
        let isToday = Calendar.current.isDate(date, inSameDayAs: Date())
        let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedDate)
        
        return Button(action: {
            lightFeedback.impactOccurred()
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                selectedDate = date
            }
        }) {
            VStack(spacing: 6) {
                Text(dayFormatter.string(from: date))
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? .white : .secondary)
                
                Text(dateFormatter.string(from: date))
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(isSelected ? .white : .primary)
                
                if isToday {
                    Circle()
                        .fill(isSelected ? .white : primaryAccent)
                        .frame(width: 6, height: 6)
                } else {
                    Circle()
                        .fill(.clear)
                        .frame(width: 6, height: 6)
                }
            }
            .frame(width: 60, height: 80)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        isSelected ?
                        LinearGradient(
                            colors: [primaryAccent, fitnessGreen],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            colors: [cardBackground, cardBackground.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(
                        color: isSelected ? primaryAccent.opacity(0.3) : .black.opacity(0.05),
                        radius: isSelected ? 8 : 4,
                        x: 0,
                        y: isSelected ? 4 : 2
                    )
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
    }
    // MARK: - Progress Ring Section
    private var progressRingSection: some View {
        VStack(spacing: 24) {
            progressHeader
            mainProgressRing
        }
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(surfaceColor)
                .shadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 6)
        )
        .padding(.horizontal, 20)
    }
    
    private var progressHeader: some View {
        HStack {
            Text("Today's Progress")
                .font(.system(.title2, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Spacer()
            
            HStack(spacing: 6) {
                Image(systemName: isGoalAchieved ? "checkmark.circle.fill" : "target")
                    .font(.system(size: 14))
                    .foregroundColor(isGoalAchieved ? fitnessGreen : vibrantOrange)
                
                Text(isGoalAchieved ? "Goal Reached!" : "Goal: \(goalSteps.formatted())")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isGoalAchieved ? fitnessGreen : vibrantOrange)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule().fill(isGoalAchieved ? fitnessGreen.opacity(0.15) : vibrantOrange.opacity(0.15))
            )
        }
        .padding(.horizontal, 24)
    }
    
    private var mainProgressRing: some View {
        ZStack {
            Circle()
                .stroke(Color(.systemGray5), lineWidth: 20)
                .frame(width: 200, height: 200)
            
            Circle()
                .trim(from: 0, to: progressPercentage)
                .stroke(
                    LinearGradient(
                        colors: [primaryAccent, fitnessGreen, stepBlue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 20, lineCap: .round)
                )
                .frame(width: 200, height: 200)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 1.0), value: progressPercentage)
            
            progressContent
        }
    }
    
    private var progressContent: some View {
        VStack(spacing: 8) {
            if isGoalAchieved {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(fitnessGreen)
            }
            
            VStack(spacing: 4) {
                Text("\(currentSteps)")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.3), value: currentSteps)
                
                Text("steps today")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
            
            Text("\(Int(progressPercentage * 100))% Complete")
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(primaryAccent)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(primaryAccent.opacity(0.1))
                .cornerRadius(8)
        }
    }
    // MARK: - Activity Metrics Section
    private var activityMetricsSection: some View {
        VStack(spacing: 20) {
            activityMetricsHeader
            activityMetricsGrid
        }
    }
    
    private var activityMetricsHeader: some View {
        HStack {
            Text("Activity Metrics")
                .font(.system(.title3, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(.primary)
            Spacer()
        }
        .padding(.horizontal, 24)
    }
    
    private var activityMetricsGrid: some View {
        HStack(spacing: 12) {
            EnhancedMetricCard(
                icon: "flame.fill",
                value: "\(calories)",
                unit: "kcal",
                label: "Calories",
                color: vibrantOrange,
                progress: Double(calories) / 100.0 // Assume 100 kcal goal for demo
            )
            
            EnhancedMetricCard(
                icon: "location.fill",
                value: String(format: "%.1f", distance),
                unit: "km",
                label: "Distance",
                color: primaryAccent,
                progress: distance / 5.0 // Assume 5km goal for demo
            )
            
            EnhancedMetricCard(
                icon: "clock.fill",
                value: "\(activeTime)",
                unit: "min",
                label: "Active",
                color: fitnessGreen,
                progress: Double(activeTime) / 30.0 // Assume 30 min goal for demo
            )
        }
        .padding(.horizontal, 20)
    }
    // MARK: - Workout Section
    private var workoutSection: some View {
        VStack(spacing: 20) {
            workoutHeader
            workoutCard
        }
    }
    
    private var workoutHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(isWorkoutActive ? "Workout in Progress" : "Quick Workout")
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                if !isWorkoutActive {
                    Text("Start tracking your movement")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
        }
        .padding(.horizontal, 24)
    }
    
    private var workoutCard: some View {
        VStack(spacing: 24) {
            if isWorkoutActive {
                activeWorkoutDisplay
            } else {
                inactiveWorkoutDisplay
            }
            
            if !isWorkoutActive {
                startWorkoutButton
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [
                            surfaceColor,
                            surfaceColor.opacity(0.8)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    primaryAccent.opacity(0.2),
                                    fitnessGreen.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
                .shadow(color: primaryAccent.opacity(0.1), radius: 12, x: 0, y: 6)
        )
        .padding(.horizontal, 20)
    }
    
    private var inactiveWorkoutDisplay: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [primaryAccent.opacity(0.1), fitnessGreen.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                
                Image(systemName: "figure.walk")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundColor(primaryAccent)
            }
            
            Text("Ready to Move?")
                .font(.system(.title2, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text("Start tracking your steps and activity")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private var startWorkoutButton: some View {
        Button(action: {
            impactFeedback.impactOccurred()
            startWorkout()
        }) {
            HStack(spacing: 12) {
                Image(systemName: "play.fill")
                    .font(.system(size: 18, weight: .bold))
                
                Text("START TRACKING")
                    .font(.system(.headline, design: .rounded))
                    .fontWeight(.bold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                LinearGradient(
                    colors: [primaryAccent, fitnessGreen],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: primaryAccent.opacity(0.4), radius: 8, x: 0, y: 4)
        }
    }
    private var activeWorkoutDisplay: some View {
        VStack(spacing: 16) {
            // Status icon and timer
            VStack(spacing: 8) {
                Image(systemName: isWorkoutPaused ? "pause.circle.fill" : "stopwatch.fill")
                    .font(.system(size: 40))
                    .foregroundColor(isWorkoutPaused ? vibrantOrange : primaryAccent)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isWorkoutPaused)
                
                Text(formatTime(workoutElapsedTime))
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .opacity(isWorkoutPaused ? 0.6 : 1.0)
                    .animation(.easeInOut(duration: 0.3), value: isWorkoutPaused)
                
                Text(isWorkoutPaused ? "Workout Paused" : "Workout Time")
                    .font(.subheadline)
                    .foregroundColor(isWorkoutPaused ? vibrantOrange : .secondary)
                    .animation(.easeInOut(duration: 0.3), value: isWorkoutPaused)
            }
            
            // Live metrics during workout
            HStack(spacing: 24) {
                workoutMetricCircle(
                    value: "\(currentSteps)",
                    label: "Steps",
                    color: primaryAccent,
                    progress: Double(currentSteps) / Double(goalSteps)
                )
                
                workoutMetricCircle(
                    value: "\(calories)",
                    label: "kcal",
                    color: vibrantOrange,
                    progress: Double(calories) / 100.0
                )
            }
            
            // Control buttons
            HStack(spacing: 16) {
                Button(action: {
                    impactFeedback.impactOccurred()
                    togglePause()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: isWorkoutPaused ? "play.fill" : "pause.fill")
                            .font(.title3)
                        Text(isWorkoutPaused ? "RESUME" : "PAUSE")
                            .font(.subheadline)
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [primaryAccent, fitnessGreen],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: primaryAccent.opacity(0.4), radius: 8, x: 0, y: 4)
                }
                
                Button(action: {
                    impactFeedback.impactOccurred()
                    stopWorkout()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "stop.fill")
                            .font(.title3)
                        Text("STOP")
                            .font(.subheadline)
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [Color.red, Color.red.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: Color.red.opacity(0.4), radius: 8, x: 0, y: 4)
                }
            }
        }
    }
    
    private func workoutMetricCircle(value: String, label: String, color: Color, progress: Double) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 8)
                    .frame(width: 80, height: 80)
                
                Circle()
                    .trim(from: 0, to: min(progress, 1.0))
                    .stroke(
                        LinearGradient(
                            colors: [color, color.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progress)
                    .opacity(isWorkoutPaused ? 0.6 : 1.0)
                
                VStack(spacing: 2) {
                    Text(value)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(color)
                        .opacity(isWorkoutPaused ? 0.6 : 1.0)
                    Text(label)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .opacity(isWorkoutPaused ? 0.6 : 1.0)
                }
                .animation(.easeInOut(duration: 0.3), value: isWorkoutPaused)
            }
        }
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
            pausedElapsedTime = workoutElapsedTime
            stopWorkoutTimer()
        } else {
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
                
                if workoutElapsedTime % 3 == 0 {
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
        
        let totalMinutes = workoutElapsedTime / 60
        activeTime += totalMinutes
        
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

// MARK: - Enhanced Metric Card Component
struct EnhancedMetricCard: View {
    let icon: String
    let value: String
    let unit: String
    let label: String
    let color: Color
    let progress: Double
    
    var body: some View {
        VStack(spacing: 12) {
            // Icon with gradient background
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.2), color.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(color)
            }
            
            // Progress ring
            ZStack {
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 10)
                    .frame(width: 50, height: 50)
                
                Circle()
                    .trim(from: 0, to: min(progress, 1.0))
                    .stroke(
                        LinearGradient(
                            colors: [color, color.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 1.0, dampingFraction: 0.8), value: progress)
            }
            
            // Value and unit
            VStack(spacing: 2) {
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(value)
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(unit)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
                
                Text(label)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(.secondarySystemBackground),
                            Color(.secondarySystemBackground).opacity(0.8)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    color.opacity(0.3),
                                    color.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: color.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
}

// Simple Metric Card Component (Kept for compatibility)
struct SimpleMetricCard: View {
    let icon: String
    let value: String
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            VStack(spacing: 2) {
                Text(value)
                    .font(.system(.headline, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(unit)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
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
