import SwiftUI
import Charts

struct StatusStepTrackingView: View {
    @State private var selectedPeriod = 0 // 0: Day, 1: Week, 2: Month
    @State private var currentSteps: Double = 8540 // steps
    @State private var dailyGoal: Double = 10000 // steps
    @State private var weeklyData: [StepData] = []
    @State private var monthlyData: [StepData] = []
    
    private let periods = ["Day", "Week", "Month"]
    
    var body: some View {
        NavigationView {
                VStack(spacing: 0) {
                    // Header
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
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
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        
                        HStack {
                            Text("Let's see how things\nare going")
                                .font(.system(.title, design: .default))
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                                .lineLimit(2)
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                    }
                    
                    // Native Segmented Control
                    VStack(spacing: 20) {
                        Picker("Period", selection: $selectedPeriod) {
                            ForEach(0..<periods.count, id: \.self) { index in
                                Text(periods[index]).tag(index)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        // Current Status Card
                        VStack(spacing: 16) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "calendar")
                                            .font(.caption)
                                            .foregroundColor(.orange)
                                        Text(getCurrentDateRange())
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Text("\(getFormattedAmount())/\(getFormattedGoal())")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.black)
                                    
                                    Text("steps")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                // Circular Progress with Steps Icon
                                ZStack {
                                    // Background circle
                                    Circle()
                                        .stroke(Color(.systemGray5), lineWidth: 8)
                                        .frame(width: 120, height: 120)
                                    
                                    // Progress circle
                                    Circle()
                                        .trim(from: 0, to: getCurrentProgress())
                                        .stroke(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color(red: 0.7, green: 1.0, blue: 0.3),
                                                    Color(red: 0.6, green: 0.9, blue: 0.2),
                                                    Color(red: 0.5, green: 0.8, blue: 0.1)
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                                        )
                                        .frame(width: 120, height: 120)
                                        .rotationEffect(.degrees(-90))
                                        .animation(.easeInOut(duration: 1.0), value: getCurrentProgress())
                                    
                                    // Steps icon in center
                                    VStack(spacing: 4) {
                                        Image(systemName: "figure.walk")
                                            .font(.title)
                                            .foregroundColor(Color(red: 0.7, green: 1.0, blue: 0.3))
                                        
                                        Text("\(Int(getCurrentProgress() * 100))%")
                                            .font(.caption2)
                                            .fontWeight(.bold)
                                            .foregroundColor(Color(red: 0.7, green: 1.0, blue: 0.3))
                                    }
                                }
                            }
                        }
                        .padding(20)
                        .background(
                            LinearGradient(
                                gradient: Gradient(stops: [
                                    .init(color: Color(red: 0.95, green: 1.0, blue: 0.9), location: 0),
                                    .init(color: Color(red: 0.9, green: 0.98, blue: 0.85), location: 1)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(16)
                        .padding(.horizontal, 20)
                    }
                    
                    // Stats Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Step Tracking Stats")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                            .padding(.horizontal, 20)
                        
                        // Chart
                        Chart(getCurrentData()) { data in
                            BarMark(
                                x: .value("Period", data.label),
                                y: .value("Amount", data.amount)
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.7, green: 1.0, blue: 0.3),
                                        Color(red: 0.5, green: 0.8, blue: 0.1)
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .cornerRadius(4)
                        }
                        .frame(height: 200)
                        .padding(.horizontal, 20)
                        .chartYAxis {
                            AxisMarks(position: .leading) { _ in
                                AxisValueLabel()
                                    .foregroundStyle(.gray)
                            }
                        }
                        .chartXAxis {
                            AxisMarks(position: .bottom) { _ in
                                AxisValueLabel()
                                    .foregroundStyle(.gray)
                            }
                        }
                    }
                    .padding(.top, 30)
                    
                    // Jump to Step Tracking Workout Button
                    NavigationLink(destination: StepTrackerView()) {
                        HStack(spacing: 12) {
                            Image(systemName: "figure.walk")
                                .font(.title3)
                                .foregroundColor(Color(red: 0.7, green: 1.0, blue: 0.3))
                            
                            Text("Jump to Workout")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            Image(systemName: "arrow.right")
                                .font(.title3)
                                .foregroundColor(Color(red: 0.7, green: 1.0, blue: 0.3))
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    Spacer()
                    
                    // Bottom Navigation
                    BottomNavigationBar(selectedTab: "Status")
                }
                .background(
                    Image("bgimage-step")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipped()
                        .ignoresSafeArea()
                        .opacity(0.2)
                )
            .navigationBarHidden(true)
            .onAppear {
                generateMockData()
            }
        }
    }
    
    private func getCurrentDateRange() -> String {
        let formatter = DateFormatter()
        let today = Date()
        
        switch selectedPeriod {
        case 0: // Day
            formatter.dateFormat = "d/MM"
            return formatter.string(from: today)
        case 1: // Week
            let calendar = Calendar.current
            let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today
            let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek) ?? today
            formatter.dateFormat = "d/MM"
            return "\(formatter.string(from: startOfWeek)) - \(formatter.string(from: endOfWeek))"
        case 2: // Month
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: today)
        default:
            return ""
        }
    }
    
    private func getFormattedAmount() -> String {
        switch selectedPeriod {
        case 0: return String(Int(currentSteps))
        case 1: return String(Int(currentSteps * 7))
        case 2: return String(Int(currentSteps * 30))
        default: return String(Int(currentSteps))
        }
    }
    
    private func getFormattedGoal() -> String {
        switch selectedPeriod {
        case 0: return String(Int(dailyGoal))
        case 1: return String(Int(dailyGoal * 7))
        case 2: return String(Int(dailyGoal * 30))
        default: return String(Int(dailyGoal))
        }
    }
    
    private func getCurrentProgress() -> Double {
        switch selectedPeriod {
        case 0: return min(currentSteps / dailyGoal, 1.0)
        case 1: return min((currentSteps * 7) / (dailyGoal * 7), 1.0)
        case 2: return min((currentSteps * 30) / (dailyGoal * 30), 1.0)
        default: return min(currentSteps / dailyGoal, 1.0)
        }
    }
    
    private func getCurrentData() -> [StepData] {
        switch selectedPeriod {
        case 0: return generateDayData()
        case 1: return weeklyData
        case 2: return monthlyData
        default: return weeklyData
        }
    }
    
    private func generateMockData() {
        // Weekly data
        weeklyData = [
            StepData(label: "Mon", amount: 9500),
            StepData(label: "Tue", amount: 11200),
            StepData(label: "Wed", amount: 8600),
            StepData(label: "Thu", amount: 12400),
            StepData(label: "Fri", amount: 10100),
            StepData(label: "Sat", amount: 7900),
            StepData(label: "Sun", amount: 13000)
        ]
        
        // Monthly data
        monthlyData = [
            StepData(label: "Week 1", amount: 68000),
            StepData(label: "Week 2", amount: 72500),
            StepData(label: "Week 3", amount: 65800),
            StepData(label: "Week 4", amount: 78200)
        ]
    }
    
    private func generateDayData() -> [StepData] {
        return [
            StepData(label: "6AM", amount: 450),
            StepData(label: "9AM", amount: 1200),
            StepData(label: "12PM", amount: 2800),
            StepData(label: "3PM", amount: 1900),
            StepData(label: "6PM", amount: 1500),
            StepData(label: "9PM", amount: 690)
        ]
    }
}

struct StepData: Identifiable {
    let id = UUID()
    let label: String
    let amount: Double
}

struct StatusStepTrackingView_Previews: PreviewProvider {
    static var previews: some View {
        StatusStepTrackingView()
    }
}
