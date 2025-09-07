import SwiftUI
import Charts

struct StatusHydrationView: View {
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    @State private var selectedPeriod = 0 // 0: Day, 1: Week, 2: Month
    @State private var currentHydration: Double = 1240 // ml
    @State private var dailyGoal: Double = 3000 // ml
    @State private var weeklyData: [HydrationData] = []
    @State private var monthlyData: [HydrationData] = []
    @State private var showingDetails = false
    @State private var selectedDataPoint: HydrationData?
    
    private let periods = ["Day", "Week", "Month"]
    
    // App's consistent theme colors - Enhanced
    private let primaryAccent = Color.blue
    private let waterBlue = Color(red: 0.2, green: 0.6, blue: 0.9)
    private let lightBlue = Color(red: 0.3, green: 0.7, blue: 1.0)
    private let darkBlue = Color(red: 0.1, green: 0.4, blue: 0.7)
    private let cardBackground = Color(.systemBackground)
    private let shadowColor = Color.black.opacity(0.08)
    
    // Enhanced Haptic feedback generators
    private let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    private let lightFeedback = UIImpactFeedbackGenerator(style: .light)
    private let successFeedback = UINotificationFeedbackGenerator()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Main scrollable content within safe area
                ScrollView {
                    VStack(spacing: 0) {
                        // Enhanced Header with better spacing
                        headerSection
                        
                        VStack(spacing: 24) {
                            // Enhanced Period Selector with better styling
                            periodSelectorSection
                            
                            // Enhanced Status Card with modern design
                            statusCardSection
                            
                            // Enhanced Quick Stats Cards
                            quickStatsSection
                            
                            // Enhanced Charts Section with iOS native styling
                            chartsSection
                            
                            // Enhanced Action Button with better accessibility
                            actionButtonSection
                        }
                        .padding(.top, 12)
                        .padding(.bottom, 30) // Reduced space for better layout
                    }
                }
                .scrollIndicators(.hidden)
            }
        }
        .background(Color(.systemBackground))
        .navigationBarHidden(true)
        .onAppear {
            generateMockData()
            if getCurrentProgress() >= 1.0 {
                successFeedback.notificationOccurred(.success)
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                BackButton()
                
                Spacer()
                
                // Enhanced Achievement badge with animation
                if getCurrentProgress() >= 1.0 {
                    VStack(spacing: 2) {
                        Image(systemName: "trophy.fill")
                            .font(.title2)
                            .foregroundColor(.orange)
                            .scaleEffect(getCurrentProgress() >= 1.0 ? 1.2 : 1.0)
                            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: getCurrentProgress())
                        
                        Text("Goal!")
                            .font(.system(.caption2, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 8) // Reduced top padding since we're now within safe area
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Let's see how")
                        .font(.system(.largeTitle, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("things are going")
                        .font(.system(.largeTitle, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                // Enhanced Water icon with better animation
                ZStack {
                    Circle()
                        .fill(waterBlue.opacity(0.2))
                        .frame(width: 60, height: 60)
                        .scaleEffect(getCurrentProgress() >= 1.0 ? 1.1 : 1.0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: getCurrentProgress())
                    
                    Image(systemName: "drop.fill")
                        .font(.system(size: 32))
                        .foregroundColor(waterBlue)
                        .shadow(color: waterBlue.opacity(0.4), radius: 8, x: 0, y: 4)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)
        }
        .padding(.bottom, 16)
        .padding(.top, 8) // Additional top padding for safe area
    }
    
    // MARK: - Period Selector Section
    private var periodSelectorSection: some View {
        Picker("Period", selection: $selectedPeriod) {
            ForEach(0..<periods.count, id: \.self) { index in
                Text(periods[index])
                    .tag(index)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.horizontal, 24)
        .onChange(of: selectedPeriod) { _, _ in
            lightFeedback.impactOccurred()
        }
        .accessibilityLabel("Select time period for hydration tracking data")
    }
    
    // MARK: - Status Card Section
    private var statusCardSection: some View {
        VStack(spacing: 16) {
            HStack(alignment: .top, spacing: 16) {
                // Left side - Enhanced Information
                VStack(alignment: .leading, spacing: 12) {
                    // Date badge with enhanced styling
                    HStack(spacing: 6) {
                        Image(systemName: "calendar.circle.fill")
                            .font(.system(.caption, weight: .medium))
                            .foregroundColor(.orange)
                        Text(getCurrentDateRange())
                            .font(.system(.caption, design: .rounded))
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.orange.opacity(0.15))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                            )
                    )
                    
                    // Hydration amount with enhanced animation
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(getFormattedAmount())")
                            .font(.system(.title, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .contentTransition(.numericText())
                            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: getFormattedAmount())
                        
                        Text("of \(getFormattedGoal()) ml")
                            .font(.system(.caption, design: .rounded))
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    }
                    
                    // Enhanced Progress bar with better styling
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("Progress")
                                .font(.system(.caption2, design: .rounded))
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(Int(getCurrentProgress() * 100))%")
                                .font(.system(.caption2, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(waterBlue)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(waterBlue.opacity(0.15))
                                .cornerRadius(4)
                        }
                        
                        ZStack(alignment: .leading) {
                            // Background track
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(.systemGray6))
                                .frame(height: 6)
                            
                            // Progress fill with gradient
                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [lightBlue, waterBlue]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: max(0, getCurrentProgress() * 140), height: 6)
                                .animation(.spring(response: 0.8, dampingFraction: 0.8), value: getCurrentProgress())
                        }
                        .frame(width: 140)
                    }
                }
                
                // Right side - Enhanced Circular Progress with Glass
                ZStack {
                    // Enhanced background circle
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
                        .frame(width: 90, height: 90)
                    
                    // Enhanced gradient progress circle with water colors
                    Circle()
                        .trim(from: 0, to: getCurrentProgress())
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(stops: [
                                    .init(color: lightBlue, location: 0),
                                    .init(color: waterBlue, location: 0.5),
                                    .init(color: darkBlue, location: 1.0)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 90, height: 90)
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(response: 0.8, dampingFraction: 0.8), value: getCurrentProgress())
                    
                    // Enhanced center content with glass
                    VStack(spacing: 2) {
                        if getCurrentProgress() >= 1.0 {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.orange)
                                .scaleEffect(1.1)
                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: getCurrentProgress())
                        }
                        
                        // Enhanced glass icon
                        ZStack {
                            // Glass shape
                            RoundedRectangle(cornerRadius: 2)
                                .stroke(waterBlue, lineWidth: 2)
                                .frame(width: 12, height: 16)
                            
                            // Water in glass
                            RoundedRectangle(cornerRadius: 1.5)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [lightBlue, waterBlue]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: 8, height: 13 * getCurrentProgress())
                                .offset(y: 1.5 * (1 - getCurrentProgress()))
                        }
                        
                        Text("\(Int(getCurrentProgress() * 100))%")
                            .font(.system(.caption, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .contentTransition(.numericText())
                            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: getCurrentProgress())
                        
                        Text("Complete")
                            .font(.system(.caption2, design: .rounded))
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(16)
        .background(
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color(red: 0.96, green: 0.98, blue: 1.0), location: 0),
                    .init(color: Color(red: 0.92, green: 0.96, blue: 0.99), location: 1)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .shadow(color: shadowColor, radius: 8, x: 0, y: 4)
        .padding(.horizontal, 20)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Hydration progress: \(getFormattedAmount()) of \(getFormattedGoal()) ml, \(Int(getCurrentProgress() * 100))% complete")
    }
    
    // MARK: - Quick Stats Section
    private var quickStatsSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Quick Stats")
                    .font(.system(.headline, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(.horizontal, 20)
            
            HStack(spacing: 8) {
                // Average Hydration Card
                quickStatCard(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Average",
                    value: getAverageHydration(),
                    unit: "ml",
                    color: waterBlue
                )
                
                // Best Day Card
                quickStatCard(
                    icon: "trophy.fill",
                    title: "Best Day",
                    value: getBestDay(),
                    unit: "ml",
                    color: .orange
                )
                
                // Glasses Count Card
                quickStatCard(
                    icon: "drop.fill",
                    title: "Glasses",
                    value: "\(Int(currentHydration / 250))",
                    unit: "today",
                    color: lightBlue
                )
            }
            .padding(.horizontal, 20)
        }
    }
    
    private func quickStatCard(icon: String, title: String, value: String, unit: String, color: Color) -> some View {
        VStack(spacing: 8) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                
                VStack(spacing: 2) {
                    Text(value)
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(unit)
                        .font(.system(.caption2, design: .rounded))
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
            }
            
            Text(title)
                .font(.system(.caption, design: .rounded))
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 6)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(cardBackground)
                .shadow(color: shadowColor, radius: 4, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
    }
    
    // MARK: - Charts Section
    private var chartsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            chartHeaderSection
            chartContentSection
        }
    }
    
    private var chartHeaderSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Hydration Analytics")
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Average: \(getAverageHydration()) ml")
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Enhanced Chart type indicator
            HStack(spacing: 8) {
                Image(systemName: "chart.bar.fill")
                    .font(.title3)
                    .foregroundColor(waterBlue)
                
                Text(periods[selectedPeriod])
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(waterBlue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(waterBlue.opacity(0.15))
                    .cornerRadius(8)
            }
        }
        .padding(.horizontal, 24)
    }
    
    private var chartContentSection: some View {
        VStack(spacing: 12) {
            enhancedChart
        }
        .padding(16)
        .background(chartBackgroundStyle)
        .padding(.horizontal, 20)
    }
    
    private var enhancedChart: some View {
        Chart(getCurrentData()) { data in
            barMarkView(for: data)
            
            if selectedPeriod == 0 {
                goalLineView
            }
        }
        .frame(height: 180)
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisGridLine()
                    .foregroundStyle(Color(.systemGray5))
                AxisValueLabel()
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
        .chartXAxis {
            AxisMarks(position: .bottom) { value in
                AxisValueLabel()
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.primary)
            }
        }
        .chartPlotStyle { plotArea in
            plotArea
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground).opacity(0.95))
                )
        }
        .animation(.spring(response: 0.8, dampingFraction: 0.8), value: selectedPeriod)
        .accessibilityLabel("Hydration tracking chart showing \(periods[selectedPeriod].lowercased()) data")
    }
    
    private func barMarkView(for data: HydrationData) -> some ChartContent {
        BarMark(
            x: .value("Period", data.label),
            y: .value("Hydration", data.amount)
        )
        .foregroundStyle(barGradientStyle)
        .cornerRadius(8)
        .opacity(selectedDataPoint?.id == data.id ? 1.0 : 0.85)
    }
    
    private var barGradientStyle: LinearGradient {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: lightBlue, location: 0),
                .init(color: waterBlue, location: 0.5),
                .init(color: darkBlue.opacity(0.8), location: 1)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    private var goalLineView: some ChartContent {
        RuleMark(y: .value("Daily Goal", dailyGoal))
            .foregroundStyle(.orange)
            .lineStyle(StrokeStyle(lineWidth: 3, dash: [8, 4]))
            .annotation(position: .topTrailing, alignment: .trailing) {
                goalAnnotationView
            }
    }
    
    private var goalAnnotationView: some View {
        HStack(spacing: 4) {
            Image(systemName: "target")
                .font(.caption2)
                .foregroundColor(.orange)
            Text("Daily Goal")
                .font(.system(.caption2, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(.orange)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(goalAnnotationBackground)
    }
    
    private var goalAnnotationBackground: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(.orange.opacity(0.15))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.orange.opacity(0.4), lineWidth: 1)
            )
    }
    
    private var chartBackgroundStyle: some View {
        RoundedRectangle(cornerRadius: 24)
            .fill(cardBackground)
            .shadow(color: shadowColor, radius: 12, x: 0, y: 6)
    }
    
    // MARK: - Action Button Section
    private var actionButtonSection: some View {
        NavigationLink(destination: WaterGlassSelectionView()) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [lightBlue, waterBlue]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)
                        .shadow(color: waterBlue.opacity(0.4), radius: 8, x: 0, y: 4)
                    
                    Image(systemName: "drop.fill")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Jump to Hydration Tracking")
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Track your water intake")
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "arrow.right.circle.fill")
                    .font(.title2)
                    .foregroundColor(waterBlue)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(cardBackground)
                    .shadow(color: waterBlue.opacity(0.2), radius: 12, x: 0, y: 6)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                lightBlue.opacity(0.4),
                                waterBlue.opacity(0.4)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, 24)
        .accessibilityLabel("Jump to hydration tracking")
        .accessibilityHint("Opens the hydration tracking screen")
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
    
    private func getAverageHydration() -> String {
        let data = getCurrentData()
        let average = data.reduce(0) { $0 + $1.amount } / Double(data.count)
        return String(format: "%.0f", average)
    }
    
    private func getBestDay() -> String {
        let data = getCurrentData()
        let maxAmount = data.max { $0.amount < $1.amount }?.amount ?? 0
        return String(format: "%.0f", maxAmount)
    }
}

struct HydrationData: Identifiable {
    let id = UUID()
    let label: String
    let amount: Double
}

struct StatusHydrationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            StatusHydrationView()
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
