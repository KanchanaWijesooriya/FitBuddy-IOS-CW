//
//  StatusWorkout.swift
//  FitBuddy
//
//  Created by Chanuka Wijesooriya on 2025-09-04.
//

import SwiftUI
import Charts

struct StatusWorkout: View {
    @State private var selectedTimeframe: WorkoutTimeframe = .week
    @State private var workoutData: [WorkoutDataPoint] = []
    @State private var todayWorkouts: Int = 2
    @State private var weeklyGoal: Int = 5
    @State private var totalMinutes: Int = 85
    @State private var caloriesBurned: Int = 420
    @State private var avgHeartRate: Int = 142
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                headerView
                
                // Progress Overview Cards
                progressCardsView
                
                // Chart Section
                chartSectionView
                
                // Weekly Stats
                weeklyStatsView
                
                // Recent Workouts
                recentWorkoutsView
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
        }
        .background(Color(.systemBackground))
        .navigationTitle("Workout Status")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            loadWorkoutData()
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Today's Progress")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Keep pushing forward! 💪")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Goal completion badge
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.7, green: 1.0, blue: 0.3),
                                    Color(red: 0.5, green: 0.8, blue: 0.2)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                    
                    VStack(spacing: 2) {
                        Text("\(todayWorkouts)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("workouts")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
                .shadow(color: Color(red: 0.7, green: 1.0, blue: 0.3).opacity(0.3), radius: 8, x: 0, y: 4)
            }
        }
    }
    
    // MARK: - Progress Cards View
    private var progressCardsView: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                // Minutes Card
                StatusCard(
                    title: "Minutes",
                    value: "\(totalMinutes)",
                    unit: "min",
                    icon: "clock.fill",
                    color: .blue,
                    progress: Double(totalMinutes) / 120.0
                )
                
                // Calories Card
                StatusCard(
                    title: "Calories",
                    value: "\(caloriesBurned)",
                    unit: "kcal",
                    icon: "flame.fill",
                    color: .orange,
                    progress: Double(caloriesBurned) / 500.0
                )
            }
            
            HStack(spacing: 16) {
                // Heart Rate Card
                StatusCard(
                    title: "Avg Heart Rate",
                    value: "\(avgHeartRate)",
                    unit: "bpm",
                    icon: "heart.fill",
                    color: .red,
                    progress: Double(avgHeartRate) / 180.0
                )
                
                // Weekly Goal Card
                StatusCard(
                    title: "Weekly Goal",
                    value: "\(todayWorkouts)/\(weeklyGoal)",
                    unit: "",
                    icon: "target",
                    color: Color(red: 0.7, green: 1.0, blue: 0.3),
                    progress: Double(todayWorkouts) / Double(weeklyGoal)
                )
            }
        }
    }
    
    // MARK: - Chart Section View
    private var chartSectionView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Activity Chart")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Timeframe Picker
                Picker("Timeframe", selection: $selectedTimeframe) {
                    ForEach(WorkoutTimeframe.allCases, id: \.self) { timeframe in
                        Text(timeframe.rawValue.capitalized)
                            .tag(timeframe)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 200)
            }
            
            // Chart
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
                .frame(height: 200)
                .overlay(
                    VStack {
                        if #available(iOS 16.0, *) {
                            Chart(workoutData) { point in
                                LineMark(
                                    x: .value("Day", point.day),
                                    y: .value("Minutes", point.minutes)
                                )
                                .foregroundStyle(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 0.7, green: 1.0, blue: 0.3),
                                            Color(red: 0.5, green: 0.8, blue: 0.2)
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .lineStyle(StrokeStyle(lineWidth: 3))
                                
                                AreaMark(
                                    x: .value("Day", point.day),
                                    y: .value("Minutes", point.minutes)
                                )
                                .foregroundStyle(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 0.7, green: 1.0, blue: 0.3).opacity(0.3),
                                            Color(red: 0.5, green: 0.8, blue: 0.2).opacity(0.1)
                                        ]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                            }
                            .frame(height: 160)
                            .padding()
                        } else {
                            // Fallback for older iOS versions
                            Text("Chart requires iOS 16+")
                                .foregroundColor(.secondary)
                        }
                    }
                )
        }
    }
    
    // MARK: - Weekly Stats View
    private var weeklyStatsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("This Week")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            HStack(spacing: 12) {
                ForEach(weekDays, id: \.self) { day in
                    VStack(spacing: 8) {
                        Text(day)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        Circle()
                            .fill(workoutCompleted(for: day) ? 
                                  Color(red: 0.7, green: 1.0, blue: 0.3) : 
                                  Color(.systemGray4))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Image(systemName: workoutCompleted(for: day) ? "checkmark" : "")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                            )
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(16)
        }
    }
    
    // MARK: - Recent Workouts View
    private var recentWorkoutsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Workouts")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                WorkoutRowView(
                    type: "Full Body Workout",
                    duration: "45 min",
                    calories: "320 kcal",
                    time: "2 hours ago",
                    icon: "figure.strengthtraining.traditional"
                )
                
                WorkoutRowView(
                    type: "Cardio Session",
                    duration: "30 min",
                    calories: "250 kcal",
                    time: "Yesterday",
                    icon: "figure.run"
                )
                
                WorkoutRowView(
                    type: "Yoga Flow",
                    duration: "25 min",
                    calories: "120 kcal",
                    time: "2 days ago",
                    icon: "figure.mind.and.body"
                )
            }
        }
    }
    
    // MARK: - Helper Functions
    private func loadWorkoutData() {
        // Sample data - replace with actual data loading
        workoutData = [
            WorkoutDataPoint(day: "Mon", minutes: 45),
            WorkoutDataPoint(day: "Tue", minutes: 30),
            WorkoutDataPoint(day: "Wed", minutes: 60),
            WorkoutDataPoint(day: "Thu", minutes: 25),
            WorkoutDataPoint(day: "Fri", minutes: 50),
            WorkoutDataPoint(day: "Sat", minutes: 40),
            WorkoutDataPoint(day: "Sun", minutes: 35)
        ]
    }
    
    private func workoutCompleted(for day: String) -> Bool {
        // Sample logic - replace with actual data
        let completedDays = ["Mon", "Tue", "Wed", "Fri"]
        return completedDays.contains(day)
    }
    
    private var weekDays: [String] {
        ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    }
}

// MARK: - Supporting Views
struct StatusCard: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    let color: Color
    let progress: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                
                Spacer()
                
                CircularProgressView(progress: progress, color: color)
                    .frame(width: 30, height: 30)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .bottom, spacing: 4) {
                    Text(value)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    if !unit.isEmpty {
                        Text(unit)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
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

struct WorkoutRowView: View {
    let type: String
    let duration: String
    let calories: String
    let time: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color(red: 0.7, green: 1.0, blue: 0.3).opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(Color(red: 0.7, green: 1.0, blue: 0.3))
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(type)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(duration)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(calories)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            Text(time)
                .font(.caption)
                .foregroundColor(Color.secondary)
        }
        .padding(16)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct CircularProgressView: View {
    let progress: Double
    let color: Color
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.2), lineWidth: 3)
            
            Circle()
                .trim(from: 0, to: CGFloat(min(progress, 1.0)))
                .stroke(color, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
    }
}

// MARK: - Supporting Models
struct WorkoutDataPoint: Identifiable {
    let id = UUID()
    let day: String
    let minutes: Int
}

enum WorkoutTimeframe: String, CaseIterable {
    case week = "week"
    case month = "month"
    case year = "year"
}

#Preview {
    NavigationView {
        StatusWorkout()
    }
}
