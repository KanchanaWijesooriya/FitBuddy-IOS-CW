import SwiftUI
#if canImport(Charts)
import Charts
#endif

struct StatusStepTrackingView: View {
    @State private var selectedPeriod = 0 // 0: Day, 1: Week, 2: Month
    @State private var currentSteps: Double = 8540 // steps
    @State private var dailyGoal: Double = 10000 // steps
    @State private var weeklyData: [StepData] = []
    @State private var monthlyData: [StepData] = []
    @State private var showingDetails = false
    @State private var selectedDataPoint: StepData?
    
    private let periods = ["Day", "Week", "Month"]
    
    // App's consistent theme colors - Enhanced
    private let primaryAccent = Color.blue
    private let stepBlue = Color(red: 0.2, green: 0.6, blue: 0.9)
    private let lightBlue = Color(red: 0.3, green: 0.7, blue: 1.0)
    private let darkBlue = Color(red: 0.1, green: 0.4, blue: 0.7)
    private let cardBackground = Color.adaptiveCardBackground
    private let shadowColor = Color.primary.opacity(0.08)
    
    // Enhanced Haptic feedback generators
    private let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    private let lightFeedback = UIImpactFeedbackGenerator(style: .light)
    private let successFeedback = UINotificationFeedbackGenerator()
    
    var body: some View {
        VStack(spacing: 0) {
            // Fixed Header Section
            headerSection
            
            // Scrollable Content
            ScrollView {
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
            .scrollIndicators(.hidden)
        }
        .background(Color.adaptiveBackground)
        .navigationBarHidden(true)
        .onAppear {
            generateMockData()
            if getCurrentProgress() >= 1.0 {
                successFeedback.notificationOccurred(.success)
            }
        }
    }
    
    // MARK: - Fixed Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Back button and achievement badge row
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
            
            // Title and icon row
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
                
                // Enhanced Step icon with better animation
                ZStack {
                    Circle()
                        .fill(primaryAccent.opacity(0.2))
                        .frame(width: 60, height: 60)
                        .scaleEffect(getCurrentProgress() >= 1.0 ? 1.1 : 1.0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: getCurrentProgress())
                    
                    Image(systemName: "figure.walk.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(primaryAccent)
                        .shadow(color: primaryAccent.opacity(0.4), radius: 8, x: 0, y: 4)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.top, UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0)
        .background(Color(.systemBackground))
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
        .onChange(of: selectedPeriod) { _ in
            lightFeedback.impactOccurred()
        }
        .accessibilityLabel("Select time period for step tracking data")
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
                    
                    // Steps count with enhanced animation
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(getFormattedAmount())")
                            .font(.system(.title, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .contentTransition(.numericText())
                            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: getFormattedAmount())
                        
                        Text("of \(getFormattedGoal()) steps")
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
                                .foregroundColor(primaryAccent)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(primaryAccent.opacity(0.15))
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
                                        gradient: Gradient(colors: [primaryAccent, stepBlue]),
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
                
                // Right side - Compact Circular Progress
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
                    
                    // Enhanced gradient progress circle with better colors
                    Circle()
                        .trim(from: 0, to: getCurrentProgress())
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(stops: [
                                    .init(color: primaryAccent, location: 0),
                                    .init(color: stepBlue, location: 0.3),
                                    .init(color: lightBlue, location: 0.7),
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
                    
                    // Enhanced center content
                    VStack(spacing: 2) {
                        if getCurrentProgress() >= 1.0 {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.orange)
                                .scaleEffect(1.1)
                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: getCurrentProgress())
                        }
                        
                        Image(systemName: "figure.walk")
                            .font(.system(size: 18))
                            .foregroundColor(primaryAccent)
                            .fontWeight(.medium)
                        
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
                    .init(color: Color.adaptiveCardBackground.opacity(0.9), location: 0),
                    .init(color: Color.adaptiveCardBackground.opacity(0.95), location: 1)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .shadow(color: shadowColor, radius: 8, x: 0, y: 4)
        .padding(.horizontal, 20)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Step progress: \(getFormattedAmount()) of \(getFormattedGoal()) steps, \(Int(getCurrentProgress() * 100))% complete")
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
                // Average Steps Card
                quickStatCard(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Average",
                    value: getAverageSteps(),
                    unit: "steps",
                    color: stepBlue
                )
                
                // Best Day Card
                quickStatCard(
                    icon: "trophy.fill",
                    title: "Best Day",
                    value: getBestDay(),
                    unit: "steps",
                    color: .orange
                )
                
                // Streak Card
                quickStatCard(
                    icon: "flame.fill",
                    title: "Streak",
                    value: "7",
                    unit: "days",
                    color: Color.red
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
                Text("Step Tracking Analytics")
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Average: \(getAverageSteps()) steps")
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Enhanced Chart type indicator
            HStack(spacing: 8) {
                Image(systemName: "chart.bar.fill")
                    .font(.title3)
                    .foregroundColor(primaryAccent)
                
                Text(periods[selectedPeriod])
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(primaryAccent)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(primaryAccent.opacity(0.15))
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
        Group {
            if #available(iOS 16.0, *) {
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
                .accessibilityLabel("Step tracking chart showing \(periods[selectedPeriod].lowercased()) data")
            } else {
                // Fallback for iOS 15
                VStack {
                    Text("Charts available in iOS 16+")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                        .frame(height: 180)
                        .overlay(
                            Image(systemName: "chart.bar.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.secondary)
                        )
                }
            }
        }
    }
    
    @available(iOS 16.0, *)
    private func barMarkView(for data: StepData) -> some ChartContent {
        BarMark(
            x: .value("Period", data.label),
            y: .value("Steps", data.amount)
        )
        .foregroundStyle(barGradientStyle)
        .cornerRadius(8)
        .opacity(selectedDataPoint?.id == data.id ? 1.0 : 0.85)
    }
    
    private var barGradientStyle: LinearGradient {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: primaryAccent, location: 0),
                .init(color: primaryAccent.opacity(0.8), location: 0.5),
                .init(color: stepBlue.opacity(0.6), location: 1)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    @available(iOS 16.0, *)
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
    @State private var showStepTracker = false
    
    private var actionButtonSection: some View {
        Button(action: {
            impactFeedback.impactOccurred()
            print("📱 Navigating to StepTrackerView")
            showStepTracker = true
        }) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [primaryAccent, stepBlue]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)
                        .shadow(color: primaryAccent.opacity(0.4), radius: 8, x: 0, y: 4)
                    
                    Image(systemName: "figure.walk")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Jump to Live Tracking")
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Start your workout session")
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "arrow.right.circle.fill")
                    .font(.title2)
                    .foregroundColor(primaryAccent)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(cardBackground)
                    .shadow(color: primaryAccent.opacity(0.2), radius: 12, x: 0, y: 6)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                primaryAccent.opacity(0.4),
                                stepBlue.opacity(0.4)
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
        .accessibilityLabel("Jump to step tracking workout")
        .accessibilityHint("Opens the live step tracking workout screen")
        .background(
            NavigationLink("", destination: StepTrackerView(), isActive: $showStepTracker)
                .opacity(0)
        )
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
    
    private func getAverageSteps() -> String {
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

struct StepData: Identifiable {
    let id = UUID()
    let label: String
    let amount: Double
}

struct StatusStepTrackingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            StatusStepTrackingView()
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
