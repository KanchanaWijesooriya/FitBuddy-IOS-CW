//
//  StatusOverview.swift
//  FitBuddy
//
//  Created by Chanuka Wijesooriya on 2025-09-04.
//

import SwiftUI

struct StatusOverview: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    
    // Water & Purple theme colors - consistent with ExploreView
    private let primaryWater = Color(red: 0.024, green: 0.714, blue: 0.831) // Cyan/Water
    private let primaryPurple = Color(red: 0.588, green: 0.239, blue: 0.729) // Purple
    private let redGradient = Color(red: 0.906, green: 0.298, blue: 0.235) // Red for workout
    
    // Sample data - replace with actual data from your data source
    @State private var workoutData = WorkoutSummary(
        todayWorkouts: 2,
        totalMinutes: 85,
        caloriesBurned: 420,
        weeklyGoalProgress: 0.7
    )
    
    @State private var waterData = WaterSummary(
        currentIntake: 1800,
        dailyGoal: 2500,
        cupsConsumed: 7,
        streak: 5
    )
    
    @State private var stepData = StepSummary(
        currentSteps: 8247,
        dailyGoal: 10000,
        distance: 6.2,
        activeMinutes: 94
    )
    
    var body: some View {
        VStack(spacing: 0) {
            // Status Title without back button for main page
            mainStatusTitleView
            
            ScrollView {
                VStack(spacing: 16) {
                    // Header
                    headerView
                    
                    // 2x2 Metrics Grid
                    metricsGridView
                    
                    // Status Cards
                    statusCardsView
                    
                    // Weekly Summary
                    weeklySummaryView
                    
                    // Health Insights
                    healthInsightsView
                }
                .padding(.horizontal, 20)
                .padding(.top, 4)
                .padding(.bottom, 16) // Minimal bottom padding; nav bar handled by safeAreaInset
            }
            .background(Color(.systemBackground))
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .toolbarColorScheme(.light, for: .navigationBar)
    }
    
    // MARK: - Main Status Title View (without back button)
    private var mainStatusTitleView: some View {
        VStack(alignment: .leading, spacing: 2) {
            // Status Title - iOS Standard H1
            HStack {
                Text("Status")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.top, UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0)
            .padding(.bottom, 8)
        }
        .background(Color(.systemBackground))
    }
    
    // MARK: - Status Title View (with back button for sub-pages)
    private var statusTitleView: some View {
        VStack(alignment: .leading, spacing: 2) {
            // Back Button - iOS Standard Position
            HStack {
                BackButton()
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            
            // Status Title - iOS Standard H1
            HStack {
                Text("Status")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
        .background(Color(.systemBackground))
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Text("Today's Summary")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        // Animated star icon
                        Image(systemName: "star.fill")
                            .font(.title3)
                            .foregroundColor(primaryWater)
                            .scaleEffect(1.2)
                            .animation(
                                Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                                value: overallHealthScore
                            )
                    }
                    
                    Text("Keep up the great work! 🌟")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Enhanced health score with multiple rings
                ZStack {
                    // Outer decorative ring
                    Circle()
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    primaryWater.opacity(0.1),
                                    primaryWater.opacity(0.05)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                        .frame(width: 100, height: 100)
                    
                    // Background ring
                    Circle()
                        .stroke(Color(.systemGray5), lineWidth: 8)
                        .frame(width: 80, height: 80)
                    
                    // Progress ring with enhanced gradient
                    Circle()
                        .trim(from: 0, to: CGFloat(overallHealthScore))
                        .stroke(progressRingGradient, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .frame(width: 80, height: 80)
                        .animation(Animation.easeInOut(duration: 1.5), value: overallHealthScore)
                    
                    // Center content
                    VStack(spacing: 2) {
                        Text("\(Int(overallHealthScore * 100))")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("Health")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .fontWeight(.medium)
                        
                        // Health status indicator
                        Circle()
                            .fill(healthStatusColor)
                            .frame(width: 6, height: 6)
                            .animation(Animation.easeInOut(duration: 0.5), value: overallHealthScore)
                    }
                }
                .shadow(
                    color: primaryWater.opacity(0.3),
                    radius: 15,
                    x: 0,
                    y: 8
                )
            }
        }
    }
    
    private var healthStatusColor: Color {
        let score = overallHealthScore
        if score >= 0.8 {
            return .green
        } else if score >= 0.6 {
            return .yellow
        } else if score >= 0.4 {
            return .orange
        } else {
            return .red
        }
    }
    
    private var totalCaloriesBurned: Int {
        workoutData.caloriesBurned + Int(stepData.distance * 65)
    }
    
    private var totalActiveMinutes: Int {
        workoutData.totalMinutes + stepData.activeMinutes
    }
    
    private var overallGoalProgress: Int {
        let workoutScore = workoutData.weeklyGoalProgress
        let waterScore = waterData.currentIntake / waterData.dailyGoal
        let stepScore = Double(stepData.currentSteps) / Double(stepData.dailyGoal)
        let avgScore = (workoutScore + waterScore + stepScore) / 3.0
        return Int(avgScore * 100)
    }
    
    private var progressRingGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: primaryWater, location: 0.0),
                .init(color: primaryWater.opacity(0.8), location: 0.5),
                .init(color: primaryWater.opacity(0.6), location: 1.0)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var workoutCardGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                redGradient.opacity(0.1),
                redGradient.opacity(0.05)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var waterCardGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                primaryWater.opacity(0.1),
                primaryWater.opacity(0.05)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var stepCardGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                primaryPurple.opacity(0.1),
                primaryPurple.opacity(0.05)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // MARK: - 2x2 Metrics Grid View
    private var metricsGridView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Today's Highlights")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            VStack(spacing: 20) {
                HStack(spacing: 16) {
                    // Calories Card (Top Left - 1) - Red theme
                    MetricRectangleCard(
                        title: "Calories",
                        value: totalCaloriesBurned,
                        goal: 500,
                        unit: "kcal",
                        icon: "flame.fill",
                        color: redGradient,
                        progress: Double(totalCaloriesBurned) / 500.0
                    )
                    
                    // Goal Progress Card (Top Right - 2) - Water theme
                    MetricRectangleCard(
                        title: "Goal",
                        value: overallGoalProgress,
                        goal: 100,
                        unit: "%",
                        icon: "target",
                        color: primaryWater,
                        progress: Double(overallGoalProgress) / 100.0
                    )
                }
                
                HStack(spacing: 16) {
                    // Active Minutes Card (Bottom Left - 3) - Purple theme
                    MetricRectangleCard(
                        title: "Active",
                        value: totalActiveMinutes,
                        goal: 150,
                        unit: "min",
                        icon: "bolt.fill",
                        color: primaryPurple,
                        progress: Double(totalActiveMinutes) / 150.0
                    )
                    
                    // Hydration Card (Bottom Right - 4) - Water theme
                    MetricRectangleCard(
                        title: "Water",
                        value: Int(waterData.currentIntake),
                        goal: Int(waterData.dailyGoal),
                        unit: "ml",
                        icon: "drop.fill",
                        color: primaryWater,
                        progress: waterData.currentIntake / waterData.dailyGoal
                    )
                }
            }
        }
    }
    
    // MARK: - Status Cards View
    private var statusCardsView: some View {
        VStack(spacing: 16) {
            Text("Quick Status")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 16) {
                // Workout Status Card
                NavigationLink(destination: StatusWorkout()) {
                    StatusSummaryCard(
                        title: "Workout",
                        icon: "figure.strengthtraining.traditional",
                        primaryValue: "\(workoutData.todayWorkouts)",
                        primaryUnit: "workouts",
                        secondaryValue: "\(workoutData.totalMinutes)",
                        secondaryUnit: "min",
                        progress: workoutData.weeklyGoalProgress,
                        color: redGradient,
                        backgroundGradient: workoutCardGradient
                    )
                }
                .buttonStyle(CardButtonStyle())
                
                // Water Status Card
                NavigationLink(destination: StatusWater()) {
                    StatusSummaryCard(
                        title: "Water",
                        icon: "drop.fill",
                        primaryValue: "\(Int(waterData.currentIntake))",
                        primaryUnit: "ml",
                        secondaryValue: "\(waterData.cupsConsumed)",
                        secondaryUnit: "cups",
                        progress: waterData.currentIntake / waterData.dailyGoal,
                        color: primaryWater,
                        backgroundGradient: waterCardGradient
                    )
                }
                .buttonStyle(CardButtonStyle())
                
                // Steps Status Card
                NavigationLink(destination: StatusStep()) {
                    StatusSummaryCard(
                        title: "Steps",
                        icon: "figure.walk",
                        primaryValue: "\(stepData.currentSteps)",
                        primaryUnit: "steps",
                        secondaryValue: String(format: "%.1f", stepData.distance),
                        secondaryUnit: "km",
                        progress: Double(stepData.currentSteps) / Double(stepData.dailyGoal),
                        color: primaryPurple,
                        backgroundGradient: stepCardGradient
                    )
                }
                .buttonStyle(CardButtonStyle())
            }
        }
    }
    
    // MARK: - Quick Stats View
    private var quickStatsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Today's Highlights")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            HStack(spacing: 16) {
                QuickStatCard(
                    title: "Calories Burned",
                    value: "\(totalCaloriesBurned)",
                    unit: "kcal",
                    icon: "flame.fill",
                    color: .red
                )
                
                QuickStatCard(
                    title: "Active Time",
                    value: "\(totalActiveMinutes)",
                    unit: "min",
                    icon: "timer",
                    color: .purple
                )
            }
        }
    }
    
    // MARK: - Weekly Summary View
    private var weeklySummaryView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("This Week")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Week progress indicator
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.caption)
                        .foregroundColor(primaryWater)
                    
                    Text("Week 36")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fontWeight(.medium)
                }
            }
            
            ZStack {
                // Background with subtle gradient
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(.systemGray6),
                                Color(.systemGray6).opacity(0.5)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                VStack(spacing: 16) {
                    WeeklySummaryRow(
                        title: "Workout Goals",
                        achieved: 4,
                        total: 7,
                        color: redGradient
                    )
                    
                    Divider()
                        .background(Color(.systemGray4))
                    
                    WeeklySummaryRow(
                        title: "Hydration Goals",
                        achieved: 5,
                        total: 7,
                        color: primaryWater
                    )
                    
                    Divider()
                        .background(Color(.systemGray4))
                    
                    WeeklySummaryRow(
                        title: "Step Goals",
                        achieved: 4,
                        total: 7,
                        color: primaryPurple
                    )
                }
                .padding(20)
            }
        }
    }
    
    // MARK: - Health Insights View
    private var healthInsightsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Health Insights")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                HealthInsightCard(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Great Progress!",
                    description: "You're 20% more active than last week",
                    color: primaryWater
                )
                
                HealthInsightCard(
                    icon: "drop.fill",
                    title: "Stay Hydrated",
                    description: "You've maintained a 5-day hydration streak",
                    color: primaryWater
                )
                
                HealthInsightCard(
                    icon: "moon.fill",
                    title: "Recovery Time",
                    description: "Consider adding rest day after 3 workout days",
                    color: primaryPurple
                )
            }
        }
    }
    
    // MARK: - Computed Properties
    private var overallHealthScore: Double {
        let workoutScore = workoutData.weeklyGoalProgress
        let waterScore = waterData.currentIntake / waterData.dailyGoal
        let stepScore = Double(stepData.currentSteps) / Double(stepData.dailyGoal)
        
        return (workoutScore + min(waterScore, 1.0) + min(stepScore, 1.0)) / 3.0
    }
}

// MARK: - Supporting Views
struct StatusSummaryCard: View {
    let title: String
    let icon: String
    let primaryValue: String
    let primaryUnit: String
    let secondaryValue: String
    let secondaryUnit: String
    let progress: Double
    let color: Color
    let backgroundGradient: LinearGradient
    
    private var backgroundImageName: String {
        switch title {
        case "Workout":
            return "squats"
        case "Water":
            return "onboarding-screen"
        case "Steps":
            return "bgimage-step"
        default:
            return "onboarding-screen"
        }
    }
    
    var body: some View {
        ZStack {
            // Background Image
            Image(backgroundImageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 170)
                .clipped()
            
            // Gradient Overlay
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.black.opacity(0.7),
                            Color.black.opacity(0.4),
                            color.opacity(0.3)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 170)
            
            // Content Overlay
            HStack(spacing: 16) {
                // Icon section with enhanced design
                VStack(spacing: 8) {
                    ZStack {
                        // Outer glow circle
                        Circle()
                            .fill(
                                RadialGradient(
                                    gradient: Gradient(colors: [
                                        color.opacity(0.3),
                                        Color.clear
                                    ]),
                                    center: .center,
                                    startRadius: 25,
                                    endRadius: 45
                                )
                            )
                            .frame(width: 70, height: 70)
                        
                        // Main icon background
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        color.opacity(0.9),
                                        color.opacity(0.7)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 50, height: 50)
                        
                        // Icon
                        Image(systemName: icon)
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .shadow(color: color.opacity(0.5), radius: 10, x: 0, y: 5)
                }
                
                // Content section
                VStack(alignment: .leading, spacing: 12) {
                    // Title and subtitle
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(title) Status")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text(getStatusSubtitle())
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    // Primary metrics
                    HStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(alignment: .bottom, spacing: 4) {
                                Text(primaryValue)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Text(primaryUnit)
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            
                            Text(getProgressText())
                                .font(.caption2)
                                .foregroundColor(color.opacity(0.9))
                                .fontWeight(.medium)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(alignment: .bottom, spacing: 4) {
                                Text(secondaryValue)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                
                                Text(secondaryUnit)
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                    }
                    
                    // Enhanced Progress bar
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("\(Int(min(progress, 1.0) * 100))% of goal")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.9))
                                .fontWeight(.medium)
                            
                            Spacer()
                        }
                        
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.white.opacity(0.2))
                                .frame(height: 8)
                            
                            RoundedRectangle(cornerRadius: 6)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            color.opacity(0.9),
                                            color
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: max(8, 160 * min(progress, 1.0)), height: 8)
                                .animation(Animation.easeInOut(duration: 0.8), value: progress)
                                .shadow(color: color.opacity(0.4), radius: 4, x: 0, y: 2)
                        }
                        .frame(width: 160)
                    }
                }
                
                Spacer()
                
                // Enhanced chevron
                VStack {
                    Spacer()
                    
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.15))
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                    
                    Spacer()
                }
            }
            .padding(20)
        }
        .frame(height: 170)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: color.opacity(0.2), radius: 15, x: 0, y: 8)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            color.opacity(0.3),
                            Color.clear
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
    
    private func getStatusSubtitle() -> String {
        switch title {
        case "Workout":
            return "Track your fitness journey"
        case "Water":
            return "Stay hydrated throughout the day"
        case "Steps":
            return "Keep moving towards your goal"
        default:
            return "Monitor your progress"
        }
    }
    
    private func getProgressText() -> String {
        let percentage = Int(min(progress, 1.0) * 100)
        if percentage >= 100 {
            return "Goal achieved!"
        } else if percentage >= 75 {
            return "Almost there!"
        } else if percentage >= 50 {
            return "Good progress"
        } else {
            return "Keep going!"
        }
    }
}

struct QuickMetricItem: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                color.opacity(0.2),
                                color.opacity(0.05)
                            ]),
                            center: .center,
                            startRadius: 5,
                            endRadius: 20
                        )
                    )
                    .frame(width: 36, height: 36)
                
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(color)
            }
            
            Text(value)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

struct QuickStatCard: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    let color: Color
    
    var body: some View {
        ZStack {
            // Background with gradient
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            color.opacity(0.1),
                            color.opacity(0.05),
                            Color.clear
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            // Border gradient
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            color.opacity(0.3),
                            color.opacity(0.1)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
            
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    ZStack {
                        // Outer glow
                        Circle()
                            .fill(
                                RadialGradient(
                                    gradient: Gradient(colors: [
                                        color.opacity(0.3),
                                        Color.clear
                                    ]),
                                    center: .center,
                                    startRadius: 15,
                                    endRadius: 25
                                )
                            )
                            .frame(width: 40, height: 40)
                        
                        // Inner circle
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        color.opacity(0.9),
                                        color.opacity(0.7)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 30, height: 30)
                        
                        Image(systemName: icon)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    // Decorative element
                    Circle()
                        .fill(color.opacity(0.1))
                        .frame(width: 8, height: 8)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .bottom, spacing: 4) {
                        Text(value)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text(unit)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .fontWeight(.medium)
                    }
                    
                    Text(title)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fontWeight(.medium)
                }
            }
            .padding(18)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .shadow(color: color.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

struct WeeklySummaryRow: View {
    let title: String
    let achieved: Int
    let total: Int
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon with gradient background
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                color.opacity(0.2),
                                color.opacity(0.1)
                            ]),
                            center: .center,
                            startRadius: 8,
                            endRadius: 16
                        )
                    )
                    .frame(width: 32, height: 32)
                
                Image(systemName: getIconForTitle())
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("\(achieved) of \(total) days completed")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fontWeight(.medium)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 6) {
                // Progress percentage
                Text("\(Int(Double(achieved) / Double(total) * 100))%")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(color)
                
                // Enhanced progress dots
                HStack(spacing: 4) {
                    ForEach(0..<total, id: \.self) { index in
                        Circle()
                            .fill(index < achieved ? 
                                  LinearGradient(
                                    gradient: Gradient(colors: [color, color.opacity(0.8)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                  ) :
                                  LinearGradient(
                                    gradient: Gradient(colors: [Color(.systemGray4), Color(.systemGray5)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                  )
                            )
                            .frame(width: 8, height: 8)
                            .scaleEffect(index < achieved ? 1.0 : 0.8)
                            .animation(.easeInOut(duration: 0.3).delay(Double(index) * 0.1), value: achieved)
                    }
                }
            }
        }
    }
    
    private func getIconForTitle() -> String {
        switch title {
        case "Workout Goals":
            return "figure.strengthtraining.traditional"
        case "Hydration Goals":
            return "drop.fill"
        case "Step Goals":
            return "figure.walk"
        default:
            return "checkmark.circle.fill"
        }
    }
}

struct HealthInsightCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        ZStack {
            // Background with gradient
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            color.opacity(0.08),
                            color.opacity(0.03),
                            Color.clear
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            // Border with gradient
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            color.opacity(0.2),
                            color.opacity(0.05)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
            
            HStack(spacing: 16) {
                // Enhanced icon
                ZStack {
                    // Outer glow
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    color.opacity(0.3),
                                    Color.clear
                                ]),
                                center: .center,
                                startRadius: 20,
                                endRadius: 30
                            )
                        )
                        .frame(width: 50, height: 50)
                    
                    // Inner circle with gradient
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    color.opacity(0.9),
                                    color.opacity(0.7)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                }
                .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                }
                
                Spacer()
                
                // Action indicator
                VStack {
                    ZStack {
                        Circle()
                            .fill(color.opacity(0.1))
                            .frame(width: 20, height: 20)
                        
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(color)
                    }
                }
            }
            .padding(18)
        }
        .shadow(color: color.opacity(0.08), radius: 12, x: 0, y: 6)
    }
}

// MARK: - Supporting Models
struct WorkoutSummary {
    let todayWorkouts: Int
    let totalMinutes: Int
    let caloriesBurned: Int
    let weeklyGoalProgress: Double
}

struct WaterSummary {
    let currentIntake: Double
    let dailyGoal: Double
    let cupsConsumed: Int
    let streak: Int
}

struct StepSummary {
    let currentSteps: Int
    let dailyGoal: Int
    let distance: Double
    let activeMinutes: Int
}

// MARK: - Metric Rectangle Card
struct MetricRectangleCard: View {
    let title: String
    let value: Int
    let goal: Int
    let unit: String
    let icon: String
    let color: Color
    let progress: Double
    
    // Create gradient variations based on the primary color
    private var gradientColors: [Color] {
        // Create gradients based on the color characteristics
        if color.description.contains("0.024") { // primaryWater
            return [
                color,
                Color.cyan.opacity(0.8),
                color.opacity(0.9)
            ]
        } else if color.description.contains("0.588") { // primaryPurple
            return [
                color,
                Color.pink.opacity(0.8),
                color.opacity(0.9)
            ]
        } else if color.description.contains("0.906") { // redGradient
            return [
                color,
                color.opacity(0.8),
                color.opacity(0.9)
            ]
        } else {
            return [
                color,
                color.opacity(0.8),
                color.opacity(0.9)
            ]
        }
    }
    
    var body: some View {
        ZStack {
            // Enhanced gradient background instead of solid color
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: gradientColors),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
            
            VStack(alignment: .leading, spacing: 12) {
                // Top section with icon
                HStack {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.35))
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: icon)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
                    }
                    
                    Spacer()
                }
                
                // Main value
                HStack(alignment: .bottom, spacing: 4) {
                    Text("\(value)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 1)
                    
                    Text(unit)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 1)
                        .offset(y: -2)
                }
                
                // Title
                Text(title)
                    .font(.caption)
                    .foregroundColor(.white)
                    .fontWeight(.bold)
                    .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 1)
            }
            .padding(16)
        }
        .frame(height: 120)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Card Button Style
struct CardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
            .contentShape(Rectangle()) // Ensures the entire card area is tappable
    }
}

#Preview {
    NavigationView {
        StatusOverview()
    }
}
