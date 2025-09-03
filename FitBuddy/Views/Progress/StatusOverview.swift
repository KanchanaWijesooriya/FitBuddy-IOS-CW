//
//  StatusOverview.swift
//  FitBuddy
//
//  Created by Chanuka Wijesooriya on 2025-09-04.
//

import SwiftUI

struct StatusOverview: View {
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
        ScrollView {
            VStack(spacing: 24) {
                // Header
                headerView
                
                // Status Cards
                statusCardsView
                
                // Quick Stats Overview
                quickStatsView
                
                // Weekly Summary
                weeklySummaryView
                
                // Health Insights
                healthInsightsView
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
        }
        .background(Color(.systemBackground))
        .navigationTitle("Health Overview")
        .navigationBarTitleDisplayMode(.large)
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Today's Summary")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Keep up the great work! 🌟")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Overall health score
                ZStack {
                    Circle()
                        .stroke(Color(.systemGray4), lineWidth: 8)
                        .frame(width: 80, height: 80)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(overallHealthScore))
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.7, green: 1.0, blue: 0.3),
                                    Color(red: 0.5, green: 0.8, blue: 0.2)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .frame(width: 80, height: 80)
                        .animation(.easeInOut(duration: 1.0), value: overallHealthScore)
                    
                    VStack(spacing: 0) {
                        Text("\(Int(overallHealthScore * 100))")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("Health")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .shadow(color: Color(red: 0.7, green: 1.0, blue: 0.3).opacity(0.3), radius: 10, x: 0, y: 5)
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
                        color: Color.orange,
                        backgroundGradient: LinearGradient(
                            gradient: Gradient(colors: [
                                Color.orange.opacity(0.1),
                                Color.red.opacity(0.05)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
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
                        color: Color.blue,
                        backgroundGradient: LinearGradient(
                            gradient: Gradient(colors: [
                                Color.blue.opacity(0.1),
                                Color.cyan.opacity(0.05)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
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
                        color: Color(red: 0.7, green: 1.0, blue: 0.3),
                        backgroundGradient: LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.7, green: 1.0, blue: 0.3).opacity(0.1),
                                Color(red: 0.5, green: 0.8, blue: 0.2).opacity(0.05)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                }
                .buttonStyle(PlainButtonStyle())
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
                    value: "\(workoutData.caloriesBurned + Int(stepData.distance * 65))", // Estimate calories from steps
                    unit: "kcal",
                    icon: "flame.fill",
                    color: .red
                )
                
                QuickStatCard(
                    title: "Active Time",
                    value: "\(workoutData.totalMinutes + stepData.activeMinutes)",
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
            Text("This Week")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                WeeklySummaryRow(
                    title: "Workout Goals",
                    achieved: 4,
                    total: 7,
                    color: .orange
                )
                
                WeeklySummaryRow(
                    title: "Hydration Goals",
                    achieved: 5,
                    total: 7,
                    color: .blue
                )
                
                WeeklySummaryRow(
                    title: "Step Goals",
                    achieved: 4,
                    total: 7,
                    color: Color(red: 0.7, green: 1.0, blue: 0.3)
                )
            }
            .padding(16)
            .background(Color(.systemGray6))
            .cornerRadius(16)
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
                    color: Color(red: 0.7, green: 1.0, blue: 0.3)
                )
                
                HealthInsightCard(
                    icon: "drop.fill",
                    title: "Stay Hydrated",
                    description: "You've maintained a 5-day hydration streak",
                    color: .blue
                )
                
                HealthInsightCard(
                    icon: "moon.fill",
                    title: "Recovery Time",
                    description: "Consider adding rest day after 3 workout days",
                    color: .purple
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
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon section
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
            }
            
            // Content section
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(alignment: .bottom, spacing: 4) {
                            Text(primaryValue)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text(primaryUnit)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(alignment: .bottom, spacing: 4) {
                            Text(secondaryValue)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            
                            Text(secondaryUnit)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Progress bar
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                        .frame(height: 6)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: max(0, 200 * min(progress, 1.0)), height: 6)
                        .animation(.easeInOut(duration: 0.5), value: progress)
                }
                .frame(width: 200)
            }
            
            Spacer()
            
            // Progress percentage
            VStack {
                Text("\(Int(min(progress, 1.0) * 100))%")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(color)
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(Color.secondary)
            }
        }
        .padding(20)
        .background(backgroundGradient)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: color.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

struct QuickStatCard: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .bottom, spacing: 4) {
                    Text(value)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(unit)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

struct WeeklySummaryRow: View {
    let title: String
    let achieved: Int
    let total: Int
    let color: Color
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text("\(achieved) of \(total) days")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Progress dots
            HStack(spacing: 6) {
                ForEach(0..<total, id: \.self) { index in
                    Circle()
                        .fill(index < achieved ? color : Color(.systemGray4))
                        .frame(width: 8, height: 8)
                }
            }
        }
    }
}

struct HealthInsightCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color(.systemGray6))
        .cornerRadius(12)
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

#Preview {
    NavigationView {
        StatusOverview()
    }
}
