//
//  StatusStep.swift
//  FitBuddy
//
//  Created by Chanuka Wijesooriya on 2025-09-04.
//

import SwiftUI
import Charts

struct StatusStep: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    @State private var selectedTimeframe: StepTimeframe = .today
    @State private var currentSteps: Int = 8247
    @State private var dailyGoal: Int = 10000
    @State private var stepData: [StepDataPoint] = []
    @State private var distance: Double = 6.2 // km
    @State private var calories: Int = 387
    @State private var activeMinutes: Int = 94
    @State private var floors: Int = 12
    @State private var avgSteps: Int = 8756
    
    private var progressPercentage: Double {
        Double(currentSteps) / Double(dailyGoal)
    }
    
    private var remainingSteps: Int {
        max(0, dailyGoal - currentSteps)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Back Button
            backButtonView
            
            ScrollView {
                VStack(spacing: 24) {
                    headerView
                    
                    // Main Step Progress
                    mainProgressView
                    
                    // Progress Stats
                    progressStatsView
                    
                    // Chart Section
                    chartSectionView
                    
                    // Weekly Overview
                    weeklyOverviewView
                    
                    // Achievement Section
                    achievementSectionView
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
            }
            .background(Color(.systemBackground))
        }
        .navigationTitle("Step-Track Status")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .toolbarColorScheme(.light, for: .navigationBar)
        .onAppear {
            loadStepData(for: selectedTimeframe)
        }
    }
    
    private var backButtonView: some View {
        HStack {
            BackButton()
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 8)
        .background(Color(.systemBackground))
    }
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Today's Steps")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Keep moving forward!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Goal completion indicator
                ZStack {
                    Circle()
                        .stroke(Color(.systemGray4), lineWidth: 6)
                        .frame(width: 70, height: 70)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(min(progressPercentage, 1.0)))
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.blue,
                                    Color.blue.opacity(0.8)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 6, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .frame(width: 70, height: 70)
                        .animation(.easeInOut(duration: 1.0), value: progressPercentage)
                    
                    VStack(spacing: 0) {
                        Text("\(Int(progressPercentage * 100))")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
            }
        }
    }
    
    private var mainProgressView: some View {
        VStack(spacing: 20) {
            // Step count display
            VStack(spacing: 8) {
                HStack(alignment: .bottom, spacing: 4) {
                    Text("\(currentSteps)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("steps")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 8)
                }
                
                Text("Goal: \(dailyGoal) steps")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if remainingSteps > 0 {
                    Text("\(remainingSteps) steps to go!")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(Color.blue)
                        .padding(.top, 4)
                } else {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color.blue)
                        
                        Text("Goal achieved!")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(Color.blue)
                    }
                    .padding(.top, 4)
                }
            }
            
            // Progress bar
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.systemGray5))
                    .frame(height: 8)
                
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.blue,
                                Color.blue.opacity(0.8)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(0, UIScreen.main.bounds.width * 0.85 * progressPercentage), height: 8)
                    .animation(.easeInOut(duration: 1.0), value: progressPercentage)
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemGray6))
        )
    }
    
    private var progressStatsView: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                // Distance Card
                StepStatCard(
                    title: "Distance",
                    value: String(format: "%.1f", distance),
                    unit: "km",
                    icon: "location.fill",
                    color: .blue
                )
                
                // Calories Card
                StepStatCard(
                    title: "Calories",
                    value: "\(calories)",
                    unit: "kcal",
                    icon: "flame.fill",
                    color: .orange
                )
            }
            
            HStack(spacing: 16) {
                // Active Minutes Card
                StepStatCard(
                    title: "Active Time",
                    value: "\(activeMinutes)",
                    unit: "min",
                    icon: "timer",
                    color: Color(red: 0.7, green: 1.0, blue: 0.3)
                )
                
                // Floors Card
                StepStatCard(
                    title: "Floors",
                    value: "\(floors)",
                    unit: "floors",
                    icon: "arrow.up.circle.fill",
                    color: .purple
                )
            }
        }
    }
    
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
                    ForEach(StepTimeframe.allCases, id: \.self) { timeframe in
                        Text(timeframe.rawValue.capitalized)
                            .tag(timeframe)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 200)
                .onChange(of: selectedTimeframe) { newValue in
                    loadStepData(for: newValue)
                }
            }
            
            // Chart
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
                .frame(height: 200)
                .overlay(
                    VStack {
                        if #available(iOS 16.0, *) {
                            Chart(stepData) { point in
                                BarMark(
                                    x: .value("Time", point.time),
                                    y: .value("Steps", point.steps)
                                )
                                .foregroundStyle(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 0.7, green: 1.0, blue: 0.3),
                                            Color(red: 0.5, green: 0.8, blue: 0.2)
                                        ]),
                                        startPoint: .bottom,
                                        endPoint: .top
                                    )
                                )
                                .cornerRadius(4)
                                
                                // Goal line
                                RuleMark(y: .value("Goal", dailyGoal))
                                    .foregroundStyle(.red)
                                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [5]))
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
    
    private var weeklyOverviewView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("This Week")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                HStack(spacing: 8) {
                    ForEach(weekDays, id: \.self) { day in
                        VStack(spacing: 8) {
                            Text(day)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            
                            VStack(spacing: 4) {
                                // Progress bar for each day
                                ZStack {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.green.opacity(0.3))
                                        .frame(width: 6, height: 60)
                                    
                                    VStack {
                                        Spacer()
                                        
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(goalAchieved(for: day) ? 
                                                  Color.blue : 
                                                  Color.green.opacity(0.6))
                                            .frame(
                                                width: 6, 
                                                height: max(10, 60 * stepProgress(for: day))
                                            )
                                    }
                                }
                                
                                Text(stepCount(for: day))
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                
                // Weekly summary
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Weekly Average")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("\(avgSteps) steps")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Goals Met")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("4/7 days")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                }
                .padding(.top, 8)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(16)
        }
    }
    
    private var achievementSectionView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Achievements")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                AchievementRow(
                    icon: "flame.fill",
                    title: "Step Streak",
                    description: "5 days in a row reaching your goal",
                    color: .orange,
                    isCompleted: true
                )
                
                AchievementRow(
                    icon: "crown.fill",
                    title: "Step Master",
                    description: "Walk 50,000 steps this week",
                    color: Color.blue,
                    isCompleted: false,
                    progress: 0.73
                )
                
                AchievementRow(
                    icon: "mountain.2.fill",
                    title: "Floor Climber",
                    description: "Climb 50 floors this week",
                    color: .purple,
                    isCompleted: false,
                    progress: 0.48
                )
            }
        }
    }
    
    private func loadStepData(for timeframe: StepTimeframe = .today) {
        // Sample data - replace with actual data loading based on timeframe
        switch timeframe {
        case .today:
            stepData = [
                StepDataPoint(time: "6AM", steps: 124),
                StepDataPoint(time: "9AM", steps: 856),
                StepDataPoint(time: "12PM", steps: 2340),
                StepDataPoint(time: "3PM", steps: 4567),
                StepDataPoint(time: "6PM", steps: 6789),
                StepDataPoint(time: "9PM", steps: 8247)
            ]
        case .week:
            stepData = [
                StepDataPoint(time: "Mon", steps: 9234),
                StepDataPoint(time: "Tue", steps: 8756),
                StepDataPoint(time: "Wed", steps: 11420),
                StepDataPoint(time: "Thu", steps: 7892),
                StepDataPoint(time: "Fri", steps: 10156),
                StepDataPoint(time: "Sat", steps: 12003),
                StepDataPoint(time: "Sun", steps: 8247)
            ]
        case .month:
            stepData = [
                StepDataPoint(time: "Week 1", steps: 68500),
                StepDataPoint(time: "Week 2", steps: 72400),
                StepDataPoint(time: "Week 3", steps: 69800),
                StepDataPoint(time: "Week 4", steps: 71200)
            ]
        }
    }
    
    private func goalAchieved(for day: String) -> Bool {
        // Sample logic
        let achievedDays = ["Mon", "Wed", "Fri", "Sat"]
        return achievedDays.contains(day)
    }
    
    private func stepProgress(for day: String) -> Double {
        // Sample progress values
        let progressData: [String: Double] = [
            "Mon": 0.92,
            "Tue": 0.88,
            "Wed": 1.14,
            "Thu": 0.79,
            "Fri": 1.02,
            "Sat": 1.20,
            "Sun": 0.82
        ]
        return progressData[day] ?? 0.0
    }
    
    private func stepCount(for day: String) -> String {
        let stepCounts: [String: Int] = [
            "Mon": 9234,
            "Tue": 8756,
            "Wed": 11420,
            "Thu": 7892,
            "Fri": 10156,
            "Sat": 12003,
            "Sun": 8247
        ]
        let count = stepCounts[day] ?? 0
        return count > 9999 ? "\(count/1000)k" : "\(count)"
    }
    
    private var weekDays: [String] {
        ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    }
}

struct StepStatCard: View {
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

struct AchievementRow: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    let isCompleted: Bool
    var progress: Double = 0.0
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(isCompleted ? 1.0 : 0.2))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(isCompleted ? .white : color)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                
                if !isCompleted && progress > 0 {
                    // Progress bar
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color(.systemGray5))
                            .frame(height: 4)
                        
                        RoundedRectangle(cornerRadius: 2)
                            .fill(color)
                            .frame(width: max(0, 150 * progress), height: 4)
                    }
                    .frame(width: 150)
                }
            }
            
            Spacer()
            
            if isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title3)
                    .foregroundColor(color)
            } else if progress > 0 {
                Text("\(Int(progress * 100))%")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct StepDataPoint: Identifiable {
    let id = UUID()
    let time: String
    let steps: Int
}

enum StepTimeframe: String, CaseIterable {
    case today = "today"
    case week = "week"
    case month = "month"
}

#Preview {
    NavigationView {
        StatusStep()
    }
    .environmentObject(NavigationCoordinator())
}
