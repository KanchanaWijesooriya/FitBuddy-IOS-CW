import SwiftUI
import Charts

struct StatusHydrationView: View {
    @State private var selectedPeriod = 0 // 0: Day, 1: Week, 2: Month
    @State private var currentHydration: Double = 1240 // ml
    @State private var dailyGoal: Double = 3000 // ml
    @State private var weeklyData: [HydrationData] = []
    @State private var monthlyData: [HydrationData] = []
    
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
                                    .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.9))
                                Text("Back")
                                    .font(.headline)
                                    .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.9))
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
                                
                                Text("ml")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            // Circular Progress with Glass
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
                                                Color(red: 0.3, green: 0.7, blue: 1.0),
                                                Color(red: 0.1, green: 0.5, blue: 0.8)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                                    )
                                    .frame(width: 120, height: 120)
                                    .rotationEffect(.degrees(-90))
                                    .animation(.easeInOut(duration: 1.0), value: getCurrentProgress())
                                
                                // Glass icon in center
                                VStack(spacing: 4) {
                                    ZStack {
                                        // Glass shape
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(Color(red: 0.2, green: 0.6, blue: 0.9), lineWidth: 2)
                                            .frame(width: 24, height: 32)
                                        
                                        // Water in glass
                                        RoundedRectangle(cornerRadius: 3)
                                            .fill(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        Color(red: 0.3, green: 0.7, blue: 1.0),
                                                        Color(red: 0.1, green: 0.5, blue: 0.8)
                                                    ]),
                                                    startPoint: .top,
                                                    endPoint: .bottom
                                                )
                                            )
                                            .frame(width: 20, height: 26 * getCurrentProgress())
                                            .offset(y: 3 * (1 - getCurrentProgress()))
                                    }
                                    
                                    Text("\(Int(getCurrentProgress() * 100))%")
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                        .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.9))
                                }
                            }
                        }
                    }
                    .padding(20)
                    .background(
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: Color(red: 0.9, green: 0.95, blue: 1.0), location: 0),
                                .init(color: Color(red: 0.85, green: 0.92, blue: 0.98), location: 1)
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
                    Text("Hydration Stats")
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
                                    Color(red: 0.3, green: 0.7, blue: 1.0),
                                    Color(red: 0.1, green: 0.5, blue: 0.8)
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
                
                // Jump to Hydration Workout Button
                NavigationLink(destination: WaterGlassSelectionView()) {
                    HStack(spacing: 12) {
                        Image(systemName: "drop.fill")
                            .font(.title3)
                            .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.9))
                        
                        Text("Jump to Hydration Workout")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        Image(systemName: "arrow.right")
                            .font(.title3)
                            .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.9))
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
                Image("bgimage-water")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
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
        case 0: return String(Int(currentHydration))
        case 1: return String(Int(currentHydration * 7))
        case 2: return String(Int(currentHydration * 30))
        default: return String(Int(currentHydration))
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
        case 0: return min(currentHydration / dailyGoal, 1.0)
        case 1: return min((currentHydration * 7) / (dailyGoal * 7), 1.0)
        case 2: return min((currentHydration * 30) / (dailyGoal * 30), 1.0)
        default: return min(currentHydration / dailyGoal, 1.0)
        }
    }
    
    private func getCurrentData() -> [HydrationData] {
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
            HydrationData(label: "Mon", amount: 2800),
            HydrationData(label: "Tue", amount: 3200),
            HydrationData(label: "Wed", amount: 2600),
            HydrationData(label: "Thu", amount: 3400),
            HydrationData(label: "Fri", amount: 3100),
            HydrationData(label: "Sat", amount: 2900),
            HydrationData(label: "Sun", amount: 3000)
        ]
        
        // Monthly data
        monthlyData = [
            HydrationData(label: "Week 1", amount: 21000),
            HydrationData(label: "Week 2", amount: 22500),
            HydrationData(label: "Week 3", amount: 20800),
            HydrationData(label: "Week 4", amount: 23200)
        ]
    }
    
    private func generateDayData() -> [HydrationData] {
        return [
            HydrationData(label: "6AM", amount: 250),
            HydrationData(label: "9AM", amount: 300),
            HydrationData(label: "12PM", amount: 400),
            HydrationData(label: "3PM", amount: 350),
            HydrationData(label: "6PM", amount: 300),
            HydrationData(label: "9PM", amount: 200)
        ]
    }
}

struct HydrationData: Identifiable {
    let id = UUID()
    let label: String
    let amount: Double
}

struct StatusHydrationView_Previews: PreviewProvider {
    static var previews: some View {
        StatusHydrationView()
    }
}
