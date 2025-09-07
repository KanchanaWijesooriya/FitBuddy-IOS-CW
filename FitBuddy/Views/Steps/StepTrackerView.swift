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
            // Modern header with glass morphism effect
            VStack(alignment: .leading, spacing: 0) {
                // Back button with enhanced styling
                HStack {
                    BackButton()
                    Spacer()
                    
                    // Modern status indicator
                    HStack(spacing: 6) {
                        Circle()
                            .fill(fitnessGreen)
                            .frame(width: 8, height: 8)
                            .scaleEffect(1.0)
                            .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: Date())
                        
                        Text("Live Tracking")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .overlay(
                                Capsule()
                                    .stroke(fitnessGreen.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
                .padding(.top, 8)
                .padding(.horizontal, 24)
                
                // Enhanced title section with subtitle
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Step Tracker")
                                .font(.system(.largeTitle, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text("Track your daily movement")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .fontWeight(.medium)
                        }
                        
                        Spacer()
                        
                        // Modern fitness ring icon
                        ZStack {
                            // Outer ring
                            Circle()
                                .stroke(primaryAccent.opacity(0.2), lineWidth: 3)
                                .frame(width: 56, height: 56)
                            
                            // Progress ring
                            Circle()
                                .trim(from: 0, to: progressPercentage)
                                .stroke(
                                    LinearGradient(
                                        colors: [primaryAccent, fitnessGreen],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    style: StrokeStyle(lineWidth: 3, lineCap: .round)
                                )
                                .frame(width: 56, height: 56)
                                .rotationEffect(.degrees(-90))
                                .animation(.spring(response: 1.0, dampingFraction: 0.8), value: progressPercentage)
                            
                            Image(systemName: "figure.walk")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(primaryAccent)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 12)
                }
            }

                // Modern date selector with glass morphism
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(weekDates, id: \.self) { date in
                            let isToday = Calendar.current.isDate(date, inSameDayAs: Date())
                            let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedDate)
                            
                            Button(action: {
                                lightFeedback.impactOccurred()
                                selectedDate = date
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
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(isSelected ? 
                                            LinearGradient(colors: [primaryAccent, fitnessGreen], startPoint: .topLeading, endPoint: .bottomTrailing) :
                                            .ultraThinMaterial
                                        )
                                        .shadow(color: isSelected ? primaryAccent.opacity(0.4) : Color.black.opacity(0.05), 
                                               radius: isSelected ? 8 : 4, x: 0, y: isSelected ? 4 : 2)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(isSelected ? .clear : Color(.separator), lineWidth: 0.5)
                                )
                                .scaleEffect(isSelected ? 1.05 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                }

                // Main content in ScrollView
                ScrollView {
                    VStack(spacing: 24) {
                        // Modern fitness progress ring
                        VStack(spacing: 24) {
                            HStack {
                                Text("Today's Progress")
                                    .font(.system(.title2, design: .rounded))
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                // Goal status badge
                                HStack(spacing: 6) {
                                    Image(systemName: isGoalAchieved ? "checkmark.circle.fill" : "target")
                                        .font(.caption)
                                        .foregroundColor(isGoalAchieved ? fitnessGreen : vibrantOrange)
                                    
                                    Text(isGoalAchieved ? "Goal Reached!" : "Goal: \(goalSteps.formatted())")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(isGoalAchieved ? fitnessGreen : vibrantOrange)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(isGoalAchieved ? fitnessGreen.opacity(0.15) : vibrantOrange.opacity(0.15))
                                )
                            }
                            .padding(.horizontal, 24)
                            
                            ZStack {
                                // Outer glow effect
                                Circle()
                                    .fill(
                                        RadialGradient(
                                            colors: [primaryAccent.opacity(0.1), .clear],
                                            center: .center,
                                            startRadius: 120,
                                            endRadius: 160
                                        )
                                    )
                                    .frame(width: 320, height: 320)
                                
                                // Background track with subtle gradient
                                Circle()
                                    .stroke(
                                        LinearGradient(
                                            colors: [Color(.quaternarySystemFill), Color(.tertiarySystemFill)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 20
                                    )
                                    .frame(width: 240, height: 240)
                                
                                // Main progress ring with multiple color stops
                                Circle()
                                    .trim(from: 0, to: progressPercentage)
                                    .stroke(
                                        AngularGradient(
                                            gradient: Gradient(stops: [
                                                .init(color: primaryAccent, location: 0),
                                                .init(color: stepBlue, location: 0.3),
                                                .init(color: fitnessGreen, location: 0.6),
                                                .init(color: vibrantOrange, location: 0.8),
                                                .init(color: softPurple, location: 1.0)
                                            ]),
                                            center: .center,
                                            startAngle: .degrees(-90),
                                            endAngle: .degrees(270)
                                        ),
                                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                                    )
                                    .frame(width: 240, height: 240)
                                    .rotationEffect(.degrees(-90))
                                    .animation(.spring(response: 1.5, dampingFraction: 0.8), value: progressPercentage)
                                
                                // Enhanced center content with modern metrics
                                VStack(spacing: 12) {
                                    // Achievement icon
                                    if isGoalAchieved {
                                        Image(systemName: "crown.fill")
                                            .font(.title2)
                                            .foregroundColor(vibrantOrange)
                                            .scaleEffect(1.2)
                                            .animation(.spring(response: 0.6, dampingFraction: 0.7), value: isGoalAchieved)
                                    }
                                    
                                    // Step count with animated counter
                                    VStack(spacing: 4) {
                                        Text("\(currentSteps)")
                                            .font(.system(size: 48, weight: .bold, design: .rounded))
                                            .foregroundColor(.primary)
                                            .contentTransition(.numericText())
                                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: currentSteps)
                                        
                                        Text("steps today")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    // Progress percentage with modern styling
                                    HStack(spacing: 8) {
                                        Image(systemName: "arrow.up.right")
                                            .font(.caption)
                                            .foregroundColor(fitnessGreen)
                                        
                                        Text("\(Int(progressPercentage * 100))% complete")
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        Capsule()
                                            .fill(.ultraThinMaterial)
                                            .overlay(
                                                Capsule()
                                                    .stroke(Color(.separator), lineWidth: 0.5)
                                            )
                                    )
                                }
                            }
                        }
                        
                        // Modern activity metrics grid
                        VStack(spacing: 20) {
                            HStack {
                                Text("Activity Metrics")
                                    .font(.system(.title3, design: .rounded))
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                            .padding(.horizontal, 24)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible(), spacing: 12),
                                GridItem(.flexible(), spacing: 12),
                                GridItem(.flexible(), spacing: 12)
                            ], spacing: 12) {
                                // Calories Burned Card
                                ModernMetricCard(
                                    icon: "flame.fill",
                                    value: "\(calories)",
                                    unit: "kcal",
                                    label: "Calories",
                                    color: vibrantOrange,
                                    progress: Double(calories) / 100.0,
                                    trend: "+12%"
                                )
                                
                                // Distance Card  
                                ModernMetricCard(
                                    icon: "location.fill",
                                    value: String(format: "%.1f", distance),
                                    unit: "km",
                                    label: "Distance",
                                    color: primaryAccent,
                                    progress: distance / 5.0,
                                    trend: "+8%"
                                )
                                
                                // Active Time Card
                                ModernMetricCard(
                                    icon: "clock.fill",
                                    value: "\(activeTime)",
                                    unit: "min",
                                    label: "Active",
                                    color: fitnessGreen,
                                    progress: Double(activeTime) / 60.0,
                                    trend: "+5%"
                                )
                            }
                            .padding(.horizontal, 24)
                        }
                        
                        // Modern workout section
                        VStack(spacing: 20) {
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
                            
                            // Enhanced workout card with glass morphism
                            VStack(spacing: 24) {
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
                                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                                .foregroundColor(.primary)
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
                                                                colors: [primaryAccent, fitnessGreen, stepBlue],
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
                                                                colors: [vibrantOrange, Color.red],
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
                                        
                                        // Modern control buttons
                                        HStack(spacing: 16) {
                                            // Pause/Resume Button
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
                                            
                                            // Stop Button
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
                                        .padding(.top, 8)
                                    }
                                } else {
                                    // Modern start workout display
                                    VStack(spacing: 20) {
                                        // Motivational content
                                        VStack(spacing: 12) {
                                            Image(systemName: "figure.walk.motion")
                                                .font(.system(size: 48))
                                                .foregroundColor(primaryAccent)
                                                .symbolEffect(.bounce, value: Date())
                                            
                                            Text("Ready to Move?")
                                                .font(.system(.title2, design: .rounded))
                                                .fontWeight(.bold)
                                                .foregroundColor(.primary)
                                            
                                            Text("Start tracking your steps and reach your daily goal")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                                .multilineTextAlignment(.center)
                                                .lineLimit(2)
                                        }
                                    }
                                }
                                
                                // Modern action button
                                if !isWorkoutActive {
                                    Button(action: {
                                        impactFeedback.impactOccurred()
                                        startWorkout()
                                    }) {
                                        HStack(spacing: 12) {
                                            Image(systemName: "play.circle.fill")
                                                .font(.title2)
                                            
                                            Text("START TRACKING")
                                                .font(.headline)
                                                .fontWeight(.bold)
                                        }
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 18)
                                        .background(
                                            LinearGradient(
                                                colors: [primaryAccent, fitnessGreen, vibrantOrange],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                        .shadow(color: primaryAccent.opacity(0.5), radius: 12, x: 0, y: 6)
                                        .scaleEffect(1.0)
                                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isWorkoutActive)
                                    }
                                }
                            }
                            .padding(28)
                            .background(
                                RoundedRectangle(cornerRadius: 28)
                                    .fill(.ultraThickMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 28)
                                            .stroke(
                                                LinearGradient(
                                                    colors: [primaryAccent.opacity(0.3), fitnessGreen.opacity(0.3)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 1
                                            )
                                    )
                                    .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
                            )
                            .padding(.horizontal, 24)
                        }
                    }
                    .padding(.top, 12)
                    .padding(.bottom, 100) // Add bottom padding for navigation bar
                }
            }
        .navigationBarHidden(true)
        .background(
            LinearGradient(
                colors: [
                    Color(.systemBackground),
                    primaryAccent.opacity(0.03),
                    fitnessGreen.opacity(0.02)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
        .onAppear {
            selectedDate = Date()
        }
        .onDisappear {
            stopWorkoutTimer()
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

// Modern Metric Card Component
struct ModernMetricCard: View {
    let icon: String
    let value: String
    let unit: String
    let label: String
    let color: Color
    let progress: Double
    let trend: String
    
    var body: some View {
        VStack(spacing: 12) {
            // Header with icon and trend
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                    .frame(width: 24, height: 24)
                
                Spacer()
                
                Text(trend)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(color)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(color.opacity(0.15))
                    )
            }
            
            // Progress ring
            ZStack {
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 6)
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
                        .font(.system(.title3, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(unit)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
                
                Text(label)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(.separator), lineWidth: 0.5)
                )
        )
        .shadow(color: color.opacity(0.1), radius: 8, x: 0, y: 4)
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
                // Background circle with modern styling
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 4)
                    .frame(width: 50, height: 50)
                
                // Progress circle with enhanced gradient
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        LinearGradient(
                            colors: [color, color.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.8, dampingFraction: 0.8), value: progress)
                
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(color)
            }
            
            VStack(spacing: 2) {
                Text(value)
                    .font(.system(.headline, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(unit)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
        .shadow(color: color.opacity(0.15), radius: 6, x: 0, y: 3)
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
