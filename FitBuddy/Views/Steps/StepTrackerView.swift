import SwiftUI
import HealthKit

struct StepTrackerView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedPeriod = "Day"
    @State private var currentSteps: Int = 0
    @State private var goalSteps: Int = 10000
    @State private var calories: Int = 0
    @State private var distance: Double = 0.0 // km
    @State private var activeTime: Int = 0 // minutes
    @State private var selectedDate = Date()
    @State private var refreshTimer: Timer?
    @State private var viewIsReady = false
    @State private var hasAppearedBefore = false
    @State private var isInitializing = false
    
    let periods = ["Day", "Week", "Month"]
    
    private let primaryAccent = Color.waterBlue // Use app's water blue
    private let stepBlue = Color.lightBlue
    private let lightBlue = Color.hydrationTeal 
    private let darkBlue = Color.darkBlue
    private let fitnessGreen = Color(red: 0.2, green: 0.78, blue: 0.35) // Apple Fitness Green
    private let vibrantOrange = Color(red: 1.0, green: 0.65, blue: 0.0) // Orange-yellow mix for kcal
    private let softPurple = Color.softMint // Use app's soft mint
    private let cardBackground = Color.adaptiveCardBackground
    private let surfaceColor = Color.adaptiveBackground
    
    // Haptic feedback generators
    private let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    private let lightFeedback = UIImpactFeedbackGenerator(style: .light)
    
    // Date formatter for days
    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter
    }()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()
    
    // Get 7 days starting from 3 days ago
    private var weekDates: [Date] {
        let calendar = Calendar.current
        let today = Date()
        return (-3...3).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: today)
        }
    }
    
    // Progress calculation
    var progressPercentage: Double {
        return min(Double(currentSteps) / Double(goalSteps), 1.0)
    }
    
    var isGoalAchieved: Bool {
        return currentSteps >= goalSteps
    }
    
    var body: some View {
        VStack(spacing: 0) {
            headerSection
            dateSelector
            
            ScrollView {
                VStack(spacing: 28) { // Increased spacing from 24 to 28
                    progressRingSection
                    activityMetricsSection
                }
                .padding(.top, 20) // Added top padding to create gap after date selector
                .padding(.bottom, 100)
            }
        }
        .navigationBarHidden(true)
        .background(Color.adaptiveBackground)
        .preferredColorScheme(nil) // Support system dark mode
        .onAppear {
            print("StepTrackerView onAppear called")
            if !hasAppearedBefore {
                hasAppearedBefore = true
                // Much longer delay to ensure view is fully loaded and stable
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    if viewIsReady == false { // Only setup if not already done
                        setupInitialState()
                    }
                }
            }
            // Always start data refresh when view appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                startDataRefresh()
            }
        }
        .onDisappear {
            print("StepTrackerView onDisappear called")
            stopAllTimers()
        }
    }
    
    
    private func setupInitialState() {
        print("Setting up initial state...")
        guard !viewIsReady && !isInitializing else {
            print("View already ready or initializing, skipping setup")
            return
        }
        
        isInitializing = true
        viewIsReady = false
        selectedDate = Date()
        
        // Load data first without triggering any navigation changes
        DispatchQueue.main.async {
            self.loadCurrentData()
        }
        
        // Much longer delay for permission request to avoid navigation conflicts
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.requestHealthKitPermissionIfNeeded()
            self.viewIsReady = true
            self.isInitializing = false
            print("View setup completed")
        }
    }
    
    private func loadCurrentData() {
        let stepService = StepService.shared
        currentSteps = stepService.todaySteps
        calories = stepService.calories
        distance = stepService.distance
        activeTime = stepService.activeMinutes
        
        // Reset steps to 0 at the start of each day
        let calendar = Calendar.current
        if calendar.isDateInToday(selectedDate) {
            // For today, use actual step count but ensure it starts from 0 if it's a new day
            let now = Date()
            if calendar.component(.hour, from: now) == 0 && calendar.component(.minute, from: now) < 5 {
                // If it's very early morning (0:00-0:05), reset to 0
                currentSteps = 0
            }
        } else {
            // For other dates, load historical data
            currentSteps = stepService.todaySteps
        }
    }
    
    private func startDataRefresh() {
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            loadCurrentData()
        }
    }
    
    private func stopAllTimers() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
    
    private func requestHealthKitPermissionIfNeeded() {
        let healthKitService = HealthKitService.shared
        let hasStoredAuth = UserDefaults.standard.bool(forKey: "HealthKitAuthorized")
        
        if hasStoredAuth || healthKitService.isAuthorized {
            print("HealthKit already authorized")
            return
        }
        
        print("Requesting HealthKit permission...")
        // Use a more gentle permission request that doesn't interfere with navigation
        DispatchQueue.main.async {
            StepService.shared.requestHealthKitPermission { success in
                DispatchQueue.main.async {
                    print("HealthKit permission result: \(success)")
                    if success {
                        self.loadCurrentData()
                    }
                }
            }
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                customBackButton
                Spacer()
                statusIndicator
            }
            .padding(.top, 8)
            .padding(.horizontal, 24)
            
            titleSection
        }
    }
    
    private var customBackButton: some View {
        Button(action: {
            print("Back button tapped")
            // Add delay to ensure any pending operations complete
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.presentationMode.wrappedValue.dismiss()
            }
        }) {
            HStack(spacing: 5) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .medium))
                Text("Back")
                    .font(.system(size: 17, weight: .regular))
            }
            .foregroundColor(.waterBlue)
        }
    }
    
    private var statusIndicator: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(fitnessGreen)
                .frame(width: 8, height: 8)
            
            Text("Live Tracking")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Capsule().fill(cardBackground))
    }
    
    private var titleSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Step Tracker")
                    .font(.system(.largeTitle, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Track your daily movement")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer(minLength: 20)
            modernFitnessRingIcon
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }
    
    private var modernFitnessRingIcon: some View {
        ZStack {
            Circle()
                .stroke(primaryAccent.opacity(0.2), lineWidth: 5)
                .frame(width: 60, height: 60)
            
            Circle()
                .trim(from: 0, to: progressPercentage)
                .stroke(
                    LinearGradient(
                        colors: [primaryAccent, fitnessGreen, stepBlue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 5, lineCap: .round)
                )
                .frame(width: 60, height: 60)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 1.0), value: progressPercentage)
            
            VStack(spacing: 1) {
                Text("\(Int(progressPercentage * 100))%")
                    .font(.system(.caption2, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Goal")
                    .font(.system(.caption2, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .scaleEffect(0.8)
            }
        }
    }
    
    private var dateSelector: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(weekDates, id: \.self) { date in
                        dateButton(for: date)
                            .id(date)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16) // Increased padding
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(surfaceColor)
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
            )
            .padding(.horizontal, 20)
            .padding(.bottom, 8) // Added bottom padding
            .onAppear {
                // Center today's date when view appears
                withAnimation(.easeInOut(duration: 0.5)) {
                    proxy.scrollTo(selectedDate, anchor: .center)
                }
            }
        }
    }
    
    private func dateButton(for date: Date) -> some View {
        let isToday = Calendar.current.isDate(date, inSameDayAs: Date())
        let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedDate)
        
        return Button(action: {
            lightFeedback.impactOccurred()
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                selectedDate = date
            }
        }) {
            VStack(spacing: 6) {
                Text(dayFormatter.string(from: date))
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? .white : .secondary)
                
                Text(dateFormatter.string(from: date))
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(isSelected ? .white : .primary)
                
                if isToday {
                    Circle()
                        .fill(isSelected ? .white : primaryAccent)
                        .frame(width: 6, height: 6)
                } else {
                    Circle()
                        .fill(.clear)
                        .frame(width: 6, height: 6)
                }
            }
            .frame(width: 60, height: 80)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        isSelected ?
                        LinearGradient(
                            colors: [primaryAccent, fitnessGreen],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            colors: [cardBackground, cardBackground.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(
                        color: isSelected ? primaryAccent.opacity(0.3) : .black.opacity(0.05),
                        radius: isSelected ? 8 : 4,
                        x: 0,
                        y: isSelected ? 4 : 2
                    )
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
    }
    private var progressRingSection: some View {
        VStack(spacing: 24) {
            progressHeader
            mainProgressRing
        }
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(surfaceColor)
                .shadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 6)
        )
        .padding(.horizontal, 20)
    }
    
    private var progressHeader: some View {
        HStack {
            Text("Today's Progress")
                .font(.system(.title2, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Spacer()
            
            HStack(spacing: 6) {
                Image(systemName: isGoalAchieved ? "checkmark.circle.fill" : "target")
                    .font(.system(size: 14))
                    .foregroundColor(isGoalAchieved ? fitnessGreen : vibrantOrange)
                
                Text(isGoalAchieved ? "Goal Reached!" : "Goal: \(goalSteps.formatted())")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isGoalAchieved ? fitnessGreen : vibrantOrange)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule().fill(isGoalAchieved ? fitnessGreen.opacity(0.15) : vibrantOrange.opacity(0.15))
            )
        }
        .padding(.horizontal, 24)
    }
    
    private var mainProgressRing: some View {
        ZStack {
            Circle()
                .stroke(Color(.systemGray5), lineWidth: 20)
                .frame(width: 200, height: 200)
            
            Circle()
                .trim(from: 0, to: progressPercentage)
                .stroke(
                    LinearGradient(
                        colors: [primaryAccent, fitnessGreen, stepBlue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 20, lineCap: .round)
                )
                .frame(width: 200, height: 200)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 1.0), value: progressPercentage)
            
            progressContent
        }
    }
    
    private var progressContent: some View {
        VStack(spacing: 8) {
            if isGoalAchieved {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(fitnessGreen)
            }
            
            VStack(spacing: 4) {
                Text("\(currentSteps)")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.3), value: currentSteps)
                
                Text("steps today")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
            
            Text("\(Int(progressPercentage * 100))% Complete")
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(primaryAccent)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(primaryAccent.opacity(0.1))
                .cornerRadius(8)
        }
    }
    private var activityMetricsSection: some View {
        VStack(spacing: 20) {
            activityMetricsHeader
            activityMetricsGrid
        }
    }
    
    private var activityMetricsHeader: some View {
        HStack {
            Text("Activity Metrics")
                .font(.system(.title3, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(.primary)
            Spacer()
        }
        .padding(.horizontal, 24)
    }
    
    private var activityMetricsGrid: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                EnhancedMetricCard(
                    icon: "flame.fill",
                    value: "\(calories)",
                    unit: "kcal",
                    label: "Calories",
                    color: vibrantOrange,
                    progress: Double(calories) / 100.0 // Assume 100 kcal goal for demo
                )
                
                EnhancedMetricCard(
                    icon: "location.fill",
                    value: String(format: "%.1f", distance),
                    unit: "km",
                    label: "Distance",
                    color: primaryAccent,
                    progress: distance / 5.0 // Assume 5km goal for demo
                )
                
                EnhancedMetricCard(
                    icon: "clock.fill",
                    value: "\(activeTime)",
                    unit: "min",
                    label: "Active",
                    color: fitnessGreen,
                    progress: Double(activeTime) / 30.0 // Assume 30 min goal for demo
                )
            }
            .padding(.horizontal, 20)
            
            // Time display component after km and min circles
            TimeDisplayComponent()
                .padding(.top, 16)
        }
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}

struct EnhancedMetricCard: View {
    let icon: String
    let value: String
    let unit: String
    let label: String
    let color: Color
    let progress: Double
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.2), color.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(color)
            }
            
            // Progress ring
            ZStack {
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 10)
                    .frame(width: 50, height: 50)
                
                Circle()
                    .trim(from: 0, to: min(progress, 1.0))
                    .stroke(
                        LinearGradient(
                            colors: [color, color.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 1.0, dampingFraction: 0.8), value: progress)
            }
            
            // Value and unit
            VStack(spacing: 2) {
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(value)
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(unit)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
                
                Text(label)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(.secondarySystemBackground),
                            Color(.secondarySystemBackground).opacity(0.8)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    color.opacity(0.3),
                                    color.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: color.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
}

struct StepTrackerView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            StepTrackerView()
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
