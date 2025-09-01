import SwiftUI

struct StepTrackerView: View {
    @State private var selectedPeriod = "Day"
    @State private var currentSteps: Int = 1447
    @State private var goalSteps: Int = 10000
    @State private var calories: Int = 45
    @State private var distance: Double = 1.0 // km
    @State private var activeTime: Int = 13 // minutes
    
    let periods = ["Day", "Week", "Month"]
    
    // Progress calculation
    var progressPercentage: Double {
        return min(Double(currentSteps) / Double(goalSteps), 1.0)
    }
    
    var body: some View {
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
                    Text("Steps")
                        .font(.system(.largeTitle, design: .default))
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    Spacer()
                    // Settings gear icon like in the reference
                    Button(action: {}) {
                        Image(systemName: "gearshape.fill")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                    // Share icon like in the reference
                    Button(action: {}) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)
            }
            
            // Period Selector (Day, Week, Month)
            HStack(spacing: 0) {
                ForEach(periods, id: \.self) { period in
                    Button(action: { selectedPeriod = period }) {
                        VStack(spacing: 4) {
                            Text(period)
                                .font(.headline)
                                .fontWeight(selectedPeriod == period ? .bold : .regular)
                                .foregroundColor(selectedPeriod == period ? .white : .gray)
                            
                            if selectedPeriod == period {
                                Rectangle()
                                    .fill(Color(red: 0.7, green: 1.0, blue: 0.3))
                                    .frame(height: 3)
                                    .frame(width: 40)
                            } else {
                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(height: 3)
                                    .frame(width: 40)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            
            Spacer()
            
            // Main Circular Progress View
            VStack(spacing: 40) {
                ZStack {
                    // Background circle
                    Circle()
                        .stroke(Color(.systemGray5), lineWidth: 20)
                        .frame(width: 280, height: 280)
                    
                    // Progress circle
                    Circle()
                        .trim(from: 0, to: progressPercentage)
                        .stroke(
                            Color(red: 0.7, green: 1.0, blue: 0.3),
                            style: StrokeStyle(lineWidth: 20, lineCap: .round)
                        )
                        .frame(width: 280, height: 280)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 1.0), value: progressPercentage)
                    
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
                                .stroke(Color(.systemGray5), lineWidth: 8)
                                .frame(width: 60, height: 60)
                            
                            Circle()
                                .trim(from: 0, to: 0.3) // Example progress
                                .stroke(
                                    Color(red: 0.7, green: 1.0, blue: 0.3),
                                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                                )
                                .frame(width: 60, height: 60)
                                .rotationEffect(.degrees(-90))
                            
                            Image(systemName: "drop.fill")
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
                                .stroke(Color(.systemGray5), lineWidth: 8)
                                .frame(width: 60, height: 60)
                            
                            Circle()
                                .trim(from: 0, to: 0.6) // Example progress
                                .stroke(
                                    Color(red: 0.7, green: 1.0, blue: 0.3),
                                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                                )
                                .frame(width: 60, height: 60)
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
                                .stroke(Color(.systemGray5), lineWidth: 8)
                                .frame(width: 60, height: 60)
                            
                            Circle()
                                .trim(from: 0, to: 0.8) // Example progress
                                .stroke(
                                    Color(red: 0.7, green: 1.0, blue: 0.3),
                                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                                )
                                .frame(width: 60, height: 60)
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
            
            Spacer()
            
            // Weekly Chart Section (Simplified)
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Weekly Progress")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    Spacer()
                }
                .padding(.horizontal, 24)
                
                // Simple bar chart representation
                HStack(alignment: .bottom, spacing: 12) {
                    ForEach(["THU", "FRI", "SAT", "SUN", "MON", "TUE", "WED"], id: \.self) { day in
                        VStack(spacing: 8) {
                            // Bar
                            RoundedRectangle(cornerRadius: 4)
                                .fill(day == "WED" ? Color(red: 0.7, green: 1.0, blue: 0.3) : Color(.systemGray4))
                                .frame(width: 20, height: CGFloat.random(in: 30...80))
                            
                            // Day label
                            Text(day)
                                .font(.caption2)
                                .foregroundColor(day == "WED" ? .black : .gray)
                                .fontWeight(day == "WED" ? .bold : .regular)
                        }
                    }
                }
                .padding(.horizontal, 24)
            }
            .padding(.bottom, 40)
            
            Spacer()
            
            // Bottom Navigation
            BottomNavigationBar(selectedTab: "Status")
        }
        .background(Color(.systemBackground))
        .navigationBarHidden(true)
    }
}

struct StepTrackerView_Previews: PreviewProvider {
    static var previews: some View {
        StepTrackerView()
    }
}
