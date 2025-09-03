//
//  StatusWater.swift
//  FitBuddy
//
//  Created by Chanuka Wijesooriya on 2025-09-04.
//

import SwiftUI
import Charts

struct StatusWater: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTimeframe: WaterTimeframe = .today
    @State private var currentIntake: Double = 1800 // ml
    @State private var dailyGoal: Double = 2500 // ml
    @State private var waterData: [WaterDataPoint] = []
    @State private var lastDrink: String = "30 min ago"
    @State private var averageDaily: Double = 2200
    @State private var streak: Int = 5
    
    private var progressPercentage: Double {
        currentIntake / dailyGoal
    }
    
    private var cupsConsumed: Int {
        Int(currentIntake / 250) // 250ml per cup
    }
    
    private var cupsTotal: Int {
        Int(dailyGoal / 250)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                headerView
                
                // Main Water Progress
                mainProgressView
                
                // Chart Section
                chartSectionView
                
                // Hydration Stats
                hydrationStatsView
                
                // Daily Overview
                dailyOverviewView
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
        }
        .background(Color(.systemBackground))
        .navigationTitle("Hydration Status")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(true)
        .toolbarColorScheme(.light, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(Color(red: 0.7, green: 1.0, blue: 0.3))
                }
            }
        }
        .onAppear {
            loadWaterData()
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Stay Hydrated...")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Keep your body healthy! 💧")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Streak badge
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.blue,
                                    Color.cyan
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 50)
                    
                    VStack(spacing: 2) {
                        Text("\(streak)")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("day streak")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
                .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
            }
        }
    }
    
    // MARK: - Main Progress View
    private var mainProgressView: some View {
        VStack(spacing: 20) {
            // Water bottle visualization
            ZStack {
                // Background bottle shape
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color(.systemGray6))
                    .frame(width: 120, height: 200)
                
                // Water fill
                VStack {
                    Spacer()
                    
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.blue.opacity(0.8),
                                    Color.cyan.opacity(0.6)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(
                            width: 100,
                            height: max(20, 160 * progressPercentage)
                        )
                        .animation(.easeInOut(duration: 0.5), value: progressPercentage)
                }
                .clipped()
                
                // Water level indicator
                VStack {
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        VStack(spacing: 4) {
                            Text("\(Int(progressPercentage * 100))%")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Rectangle()
                                .fill(Color.white.opacity(0.8))
                                .frame(width: 30, height: 1)
                        }
                        .padding(.trailing, 8)
                    }
                }
                .offset(y: -10)
            }
            
            // Progress text
            VStack(spacing: 8) {
                HStack(alignment: .bottom, spacing: 4) {
                    Text("\(Int(currentIntake))")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("ml")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 4)
                }
                
                Text("of \(Int(dailyGoal)) ml goal")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // Cups representation
                HStack(spacing: 8) {
                    ForEach(0..<cupsTotal, id: \.self) { index in
                        Image(systemName: index < cupsConsumed ? "drop.fill" : "drop")
                            .font(.title3)
                            .foregroundColor(index < cupsConsumed ? .blue : .gray.opacity(0.3))
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemGray6))
        )
    }
    
    // MARK: - Chart Section View
    private var chartSectionView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Intake Chart")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Timeframe Picker
                Picker("Timeframe", selection: $selectedTimeframe) {
                    ForEach(WaterTimeframe.allCases, id: \.self) { timeframe in
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
                            Chart(waterData) { point in
                                BarMark(
                                    x: .value("Time", point.time),
                                    y: .value("Amount", point.amount)
                                )
                                .foregroundStyle(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.blue,
                                            Color.cyan
                                        ]),
                                        startPoint: .bottom,
                                        endPoint: .top
                                    )
                                )
                                .cornerRadius(6)
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
    
    // MARK: - Hydration Stats View
    private var hydrationStatsView: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                // Average Daily Card
                HydrationStatCard(
                    title: "Avg Daily",
                    value: "\(Int(averageDaily))",
                    unit: "ml",
                    icon: "chart.line.uptrend.xyaxis",
                    color: .blue
                )
                
                // Last Drink Card
                HydrationStatCard(
                    title: "Last Drink",
                    value: lastDrink,
                    unit: "",
                    icon: "clock.fill",
                    color: .cyan
                )
            }
            
            HStack(spacing: 16) {
                // Goal Achievement Card
                HydrationStatCard(
                    title: "Goal Rate",
                    value: "\(Int(progressPercentage * 100))",
                    unit: "%",
                    icon: "target",
                    color: Color(red: 0.7, green: 1.0, blue: 0.3)
                )
                
                // Streak Card
                HydrationStatCard(
                    title: "Best Streak",
                    value: "\(streak + 3)",
                    unit: "days",
                    icon: "flame.fill",
                    color: .orange
                )
            }
        }
    }
    
    // MARK: - Daily Overview View
    private var dailyOverviewView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Daily Overview")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                // Hourly intake chart
                VStack(alignment: .leading, spacing: 12) {
                    Text("Today's Intake Pattern")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 8) {
                        ForEach(hourlyIntake, id: \.hour) { intake in
                            VStack(spacing: 4) {
                                // Bar representing intake for that hour
                                ZStack {
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(Color(.systemGray5))
                                        .frame(width: 12, height: 40)
                                    
                                    VStack {
                                        Spacer()
                                        
                                        RoundedRectangle(cornerRadius: 2)
                                            .fill(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        Color.blue,
                                                        Color.cyan
                                                    ]),
                                                    startPoint: .bottom,
                                                    endPoint: .top
                                                )
                                            )
                                            .frame(
                                                width: 12,
                                                height: max(2, 40 * (Double(intake.amount) / 500.0))
                                            )
                                    }
                                }
                                
                                Text(intake.hour)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                
                // Hydration insights
                VStack(spacing: 8) {
                    HydrationInsightRow(
                        icon: "sunrise.fill",
                        title: "Morning Hydration",
                        value: "Good start with 500ml",
                        color: .orange
                    )
                    
                    HydrationInsightRow(
                        icon: "sun.max.fill",
                        title: "Afternoon Peak",
                        value: "Most active at 2 PM",
                        color: .yellow
                    )
                    
                    HydrationInsightRow(
                        icon: "moon.fill",
                        title: "Evening Wind Down",
                        value: "Reduced intake after 6 PM",
                        color: .purple
                    )
                }
            }
        }
    }
    
    private var hourlyIntake: [HourlyIntake] {
        [
            HourlyIntake(hour: "6", amount: 250),
            HourlyIntake(hour: "8", amount: 500),
            HourlyIntake(hour: "10", amount: 200),
            HourlyIntake(hour: "12", amount: 300),
            HourlyIntake(hour: "14", amount: 400),
            HourlyIntake(hour: "16", amount: 250),
            HourlyIntake(hour: "18", amount: 200),
            HourlyIntake(hour: "20", amount: 100)
        ]
    }
    
    // MARK: - Helper Functions
    private func loadWaterData() {
        // Sample data - replace with actual data loading
        waterData = [
            WaterDataPoint(time: "6AM", amount: 250),
            WaterDataPoint(time: "8AM", amount: 500),
            WaterDataPoint(time: "10AM", amount: 250),
            WaterDataPoint(time: "12PM", amount: 300),
            WaterDataPoint(time: "2PM", amount: 250),
            WaterDataPoint(time: "4PM", amount: 200),
            WaterDataPoint(time: "6PM", amount: 250)
        ]
    }
}

// MARK: - Supporting Views
struct HydrationStatCard: View {
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

struct HydrationInsightRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 32, height: 32)
                
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(color)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(value)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// MARK: - Supporting Models
struct HourlyIntake {
    let hour: String
    let amount: Int
}

struct WaterDataPoint: Identifiable {
    let id = UUID()
    let time: String
    let amount: Int
}

enum WaterTimeframe: String, CaseIterable {
    case today = "today"
    case week = "week"
    case month = "month"
}

#Preview {
    NavigationView {
        StatusWater()
    }
}
