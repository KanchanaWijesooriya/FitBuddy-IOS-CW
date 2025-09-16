import SwiftUI

// MARK: - Water Glass Model
struct WaterGlass: Identifiable {
    let id = UUID()
    let size: String // ml size
    let mlAmount: Int // ml amount
    let color: Color
    let icon: String // SF Symbol icon name
    let level: String // Water level description
}

struct WaterGlassSelectionView: View {
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    @EnvironmentObject var waterService: WaterService
    @State private var dailyGoal: Double = 3000 // ml
    @State private var selectedDate = Date()
    @State private var customAmount: String = ""
    @State private var showCustomInput = false
    
    // Modern hydration-focused color scheme
    private let primaryAccent = Color(red: 0.0, green: 0.48, blue: 1.0) // Apple Blue
    private let hydrationTeal = Color(red: 0.0, green: 0.78, blue: 0.75) // Hydration Teal
    private let waterBlue = Color(red: 0.2, green: 0.6, blue: 0.9) // Water Blue
    private let vibrantCyan = Color(red: 0.0, green: 0.8, blue: 1.0) // Vibrant Cyan
    private let softMint = Color(red: 0.0, green: 0.9, blue: 0.6) // Soft Mint
    private let lightBlue = Color(red: 0.3, green: 0.7, blue: 1.0)
    private let darkBlue = Color(red: 0.1, green: 0.4, blue: 0.7)
    private let cardBackground = Color(.secondarySystemBackground)
    private let surfaceColor = Color(.systemBackground)
    
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
    
    // Modern water glass sizes with hydration-focused colors
    private var waterGlasses: [WaterGlass] {
        [
            WaterGlass(size: "100ml", mlAmount: 100, color: hydrationTeal, icon: "drop", level: "Sip"),
            WaterGlass(size: "250ml", mlAmount: 250, color: waterBlue, icon: "drop.fill", level: "Glass"),
            WaterGlass(size: "350ml", mlAmount: 350, color: vibrantCyan, icon: "waterbottle", level: "Bottle"),
            WaterGlass(size: "500ml", mlAmount: 500, color: softMint, icon: "waterbottle.fill", level: "Large")
        ]
    }
    
    var progressPercentage: Double {
        return min((waterService.todayWater * 1000) / dailyGoal, 1.0)
    }
    
    var isGoalAchieved: Bool {
        return (waterService.todayWater * 1000) >= dailyGoal
    }
    
    // Current hydration in ml from waterService
    private var currentHydrationML: Double {
        return waterService.todayWater * 1000
    }
    
    var body: some View {
        VStack(spacing: 0) {
            headerSection
            dateSelector
            
            ScrollView {
                VStack(spacing: 24) { // Increased spacing from 16 to 24
                    progressRingSection
                    waterSelectionSection
                }
                .padding(.top, 20) // Added top padding to create gap after date selector
                .padding(.bottom, 100)
            }
        }
        .navigationBarHidden(true)
        .background(Color(.systemGroupedBackground))
        .onAppear {
            selectedDate = Date()
            waterService.checkForDayChange()
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                BackButton()
                Spacer()
                statusIndicator
            }
            .padding(.top, 8)
            .padding(.horizontal, 24)
            
            titleSection
        }
    }
    
    private var statusIndicator: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(isGoalAchieved ? softMint : hydrationTeal)
                .frame(width: 8, height: 8)
            
            Text(isGoalAchieved ? "Goal Achieved" : "In Progress")
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
                Text("Hydration")
                    .font(.system(.largeTitle, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Track your daily water intake")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer(minLength: 20)
            smallProgressRing
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }
    
    // Enhanced progress ring with water-themed gradient
    private var smallProgressRing: some View {
        ZStack {
            Circle()
                .stroke(Color(.systemGray5), lineWidth: 5)
                .frame(width: 60, height: 60)
            
            Circle()
                .trim(from: 0, to: progressPercentage)
                .stroke(
                    LinearGradient(
                        colors: [hydrationTeal, waterBlue, vibrantCyan],
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
                
                Text("Daily")
                    .font(.system(.caption2, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .scaleEffect(0.8)
            }
        }
    }
    
    // MARK: - Date Selector
    private var dateSelector: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(weekDates, id: \.self) { date in
                        dateButton(for: date)
                            .id(date)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16) // Increased from 12 to 16
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
            .onChange(of: selectedDate) { newDate in
                // Keep selected date centered
                withAnimation(.easeInOut(duration: 0.3)) {
                    proxy.scrollTo(newDate, anchor: .center)
                }
            }
        }
    }
    
    private func dateButton(for date: Date) -> some View {
        let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedDate)
        
        return Button(action: {
            lightFeedback.impactOccurred()
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                selectedDate = date
            }
        }) {
            VStack(spacing: 4) {
                Text(dayFormatter.string(from: date))
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .secondary)
                
                Text(dateFormatter.string(from: date))
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        isSelected ?
                        LinearGradient(
                            colors: [hydrationTeal, waterBlue],
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
                        color: isSelected ? hydrationTeal.opacity(0.3) : .black.opacity(0.05),
                        radius: isSelected ? 8 : 4,
                        x: 0,
                        y: isSelected ? 4 : 2
                    )
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
    }
    
    // MARK: - Progress Ring Section
    private var progressRingSection: some View {
        VStack(spacing: 24) {
            progressHeader
            mainProgressRing
        }
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(surfaceColor)
                .shadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 6)
        )
        .padding(.horizontal, 20)
    }
    
    private var progressHeader: some View {
        HStack {
            Text("Today's Hydration")
                .font(.system(.title2, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(.primary)
            Spacer()
            
            HStack(spacing: 8) {
                Image(systemName: "drop.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(hydrationTeal)
                
                Text("\(Int(dailyGoal))ml Goal")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Capsule().fill(cardBackground))
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
                        colors: [hydrationTeal, waterBlue, vibrantCyan],
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
        VStack(spacing: 6) {
            if isGoalAchieved {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(softMint)
            }
            
            Text("\(Int(currentHydrationML))")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .contentTransition(.numericText())
                .animation(.easeInOut(duration: 0.3), value: currentHydrationML)
            
            Text("ml consumed")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("\(Int(progressPercentage * 100))% Complete")
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(hydrationTeal)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(hydrationTeal.opacity(0.1))
                .cornerRadius(8)
        }
    }
    
    // MARK: - Water Selection Section
    private var waterSelectionSection: some View {
        VStack(spacing: 24) {
            quickAddHeader
            waterCardsRow
            customAmountSection
        }
        .padding(.top, 12)
    }
    
    private var quickAddHeader: some View {
        HStack {
            Text("Quick Add Water")
                .font(.system(.title3, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(.primary)
            Spacer()
        }
        .padding(.horizontal, 24)
    }
    
    private var waterCardsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(waterGlasses, id: \.id) { glass in
                    SimpleWaterCard(glass: glass) {
                        impactFeedback.impactOccurred()
                        // Convert ml to liters and add to waterService
                        let amountInLiters = Double(glass.mlAmount) / 1000.0
                        waterService.addWater(amount: amountInLiters)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.trailing, 20) // Extra padding to ensure last card is fully visible
        }
    }
    
    // MARK: - Custom Amount Section
    private var customAmountSection: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Custom Amount")
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(.horizontal, 24)
            
            if !showCustomInput {
                customAmountTrigger
            } else {
                customInputInterface
            }
        }
    }
    
    private var customAmountTrigger: some View {
        Button(action: {
            lightFeedback.impactOccurred()
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                showCustomInput = true
            }
        }) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [primaryAccent, vibrantCyan],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                        .shadow(color: primaryAccent.opacity(0.3), radius: 8, x: 0, y: 4)
                    
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Add Custom Amount")
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Enter any amount you want")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(.subheadline, weight: .semibold))
                    .foregroundColor(primaryAccent)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                cardBackground,
                                cardBackground.opacity(0.8)
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
                                        primaryAccent.opacity(0.2),
                                        vibrantCyan.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .shadow(color: primaryAccent.opacity(0.1), radius: 12, x: 0, y: 6)
            )
        }
        .padding(.horizontal, 24)
    };    private var customInputInterface: some View {
        VStack(spacing: 20) {
            VStack(spacing: 16) {
                Text("Enter Amount")
                    .font(.system(.headline, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                customInputField
                customInputButtons
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(cardBackground)
                    .shadow(color: .black.opacity(0.1), radius: 12, x: 0, y: 6)
            )
        }
        .padding(.horizontal, 24)
        .transition(.asymmetric(
            insertion: .scale.combined(with: .opacity),
            removal: .scale.combined(with: .opacity)
        ))
    }
    
    private var customInputField: some View {
        VStack(spacing: 8) {
            TextField("0", text: $customAmount)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(surfaceColor)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(hydrationTeal.opacity(0.3), lineWidth: 2)
                        )
                )
            
            Text("milliliters")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
        }
        .frame(width: 140)
    }
    
    private var customInputButtons: some View {
        HStack(spacing: 12) {
            Button("Cancel") {
                lightFeedback.impactOccurred()
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    showCustomInput = false
                    customAmount = ""
                }
            }
            .font(.system(.subheadline, design: .rounded))
            .fontWeight(.semibold)
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            )
            
            Button("Add Water") {
                if let amount = Double(customAmount), amount > 0 {
                    impactFeedback.impactOccurred()
                    // Convert ml to liters and add to waterService
                    let amountInLiters = amount / 1000.0
                    waterService.addWater(amount: amountInLiters)
                    customAmount = ""
                    showCustomInput = false
                }
            }
            .disabled(customAmount.isEmpty)
            .font(.system(.subheadline, design: .rounded))
            .fontWeight(.bold)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                LinearGradient(
                    colors: customAmount.isEmpty ?
                        [Color(.systemGray4), Color(.systemGray3)] :
                        [hydrationTeal, waterBlue],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

// MARK: - Modern Simple Water Card Component
struct SimpleWaterCard: View {
    let glass: WaterGlass
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                // Icon container
                ZStack {
                    Circle()
                        .fill(glass.color)
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: glass.icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                }
                
                // Glass info
                VStack(spacing: 2) {
                    Text("\(glass.mlAmount)")
                        .font(.system(.caption, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("ml")
                        .font(.system(.caption2, design: .rounded))
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .scaleEffect(0.9)
                }
                
                // Glass name
                Text(glass.level)
                    .font(.system(.caption2, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(glass.color.opacity(0.1))
                    .cornerRadius(6)
                    .scaleEffect(0.9)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
            .frame(width: 85)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.secondarySystemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

struct WaterGlassSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        WaterGlassSelectionView()
    }
}
