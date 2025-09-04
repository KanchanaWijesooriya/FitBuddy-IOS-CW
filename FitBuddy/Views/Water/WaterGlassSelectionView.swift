import SwiftUI

struct WaterGlassSelectionView: View {
    @State private var currentHydration: Double = 2000 // ml
    @State private var dailyGoal: Double = 3000 // ml
    @State private var selectedDate = Date()
    @State private var customAmount: String = ""
    @State private var showCustomInput = false
    
    // App's consistent theme colors
    private let primaryAccent = Color(red: 0.7, green: 1.0, blue: 0.3)
    private let waterBlue = Color(red: 0.2, green: 0.6, blue: 0.9)
    private let lightBlue = Color(red: 0.3, green: 0.7, blue: 1.0)
    private let darkBlue = Color(red: 0.1, green: 0.4, blue: 0.7)
    
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
    
    // Different water glass sizes with appropriate icons for water levels
    private var waterGlasses: [WaterGlass] {
        [
            WaterGlass(size: "100ml", mlAmount: 100, color: waterBlue, icon: "drop", level: "Low"),
            WaterGlass(size: "250ml", mlAmount: 250, color: Color(red: 0.1, green: 0.5, blue: 0.8), icon: "drop.fill", level: "Medium"),
            WaterGlass(size: "350ml", mlAmount: 350, color: lightBlue, icon: "waterbottle", level: "High"),
            WaterGlass(size: "500ml", mlAmount: 500, color: darkBlue, icon: "waterbottle.fill", level: "Full")
        ]
    }
    
    var progressPercentage: Double {
        return min(currentHydration / dailyGoal, 1.0)
    }
    
    var isGoalAchieved: Bool {
        return currentHydration >= dailyGoal
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with common theme
            VStack(alignment: .leading, spacing: 0) {
                // Back button with common component
                HStack {
                    BackButton(action: {
                        impactFeedback.impactOccurred()
                        // Back action
                    })
                    Spacer()
                }
                .padding(.top, 8)
                .padding(.horizontal, 24)
                
                // Title section
                HStack {
                    Text("Water Intake")
                        .font(.system(.largeTitle, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    Spacer()
                    ZStack {
                        Circle()
                            .fill(waterBlue.opacity(0.2))
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: "drop.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(waterBlue)
                            .shadow(color: waterBlue.opacity(0.4), radius: 6, x: 0, y: 3)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)
            }

                // Filter Bar (Date Selector)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(weekDates, id: \.self) { date in
                            let isToday = Calendar.current.isDate(date, inSameDayAs: Date())
                            let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedDate)
                            
                            Button(action: {
                                lightFeedback.impactOccurred()
                                selectedDate = date
                            }) {
                                VStack(spacing: 2) {
                                    Text(dayFormatter.string(from: date))
                                        .font(.system(.caption2, design: .rounded))
                                        .fontWeight(isSelected ? .bold : .medium)
                                        .foregroundColor(isSelected ? .white : .primary)
                                    Text(dateFormatter.string(from: date))
                                        .font(.system(.subheadline, design: .rounded))
                                        .fontWeight(isSelected ? .bold : .semibold)
                                        .foregroundColor(isSelected ? .white : .primary)
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(isSelected ? primaryAccent : Color(.systemGray6))
                                        .shadow(color: isSelected ? primaryAccent.opacity(0.3) : Color.black.opacity(0.05), radius: isSelected ? 4 : 2, x: 0, y: isSelected ? 2 : 1)
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 8)
                }

                // Main content in ScrollView
                ScrollView {
                    VStack(spacing: 16) {
                        // Circular Progress View
                        VStack(spacing: 20) {
                            Text("Today's Progress")
                                .font(.system(.title2, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                                .padding(.horizontal, 24)
                            
                            ZStack {
                                // Background circle with enhanced gradient
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
                                        lineWidth: 24
                                    )
                                    .frame(width: 240, height: 240)
                                
                                // Progress circle
                                Circle()
                                    .trim(from: 0, to: progressPercentage)
                                    .stroke(
                                        LinearGradient(
                                            gradient: Gradient(colors: [primaryAccent, waterBlue]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        style: StrokeStyle(lineWidth: 24, lineCap: .round)
                                    )
                                    .frame(width: 240, height: 240)
                                    .rotationEffect(.degrees(-90))
                                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progressPercentage)
                                
                                // Center content
                                VStack(spacing: 6) {
                                    if isGoalAchieved {
                                        Image(systemName: "checkmark.seal.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(primaryAccent)
                                    }
                                    
                                    Text("\(Int(currentHydration))")
                                        .font(.system(size: 28, weight: .bold, design: .rounded))
                                        .foregroundColor(.primary)
                                        .contentTransition(.numericText())
                                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: currentHydration)
                                    
                                    Text("ml today")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Text("\(Int(progressPercentage * 100))% of \(Int(dailyGoal))ml")
                                        .font(.caption2)
                                        .fontWeight(.medium)
                                        .foregroundColor(waterBlue)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background(waterBlue.opacity(0.1))
                                        .cornerRadius(6)
                                }
                            }
                        }
                        
                        // Water Glass Cards (2x2 grid)
                        VStack(spacing: 12) {
                            HStack {
                                Text("Quick Add")
                                    .font(.system(.headline, design: .rounded))
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                            .padding(.horizontal, 24)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                                ForEach(waterGlasses, id: \.id) { glass in
                                    WaterGlassCard2x2(glass: glass) {
                                        impactFeedback.impactOccurred()
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                            currentHydration += Double(glass.mlAmount)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                            
                            // Simplified Custom Amount Button for better performance
                            if !showCustomInput {
                                Button(action: {
                                    lightFeedback.impactOccurred()
                                    showCustomInput = true
                                }) {
                                    VStack(spacing: 12) {
                                        // Simplified icon container
                                        ZStack {
                                            Circle()
                                                .fill(primaryAccent)
                                                .frame(width: 60, height: 60)
                                            
                                            Image(systemName: "plus.circle")
                                                .font(.system(size: 24, weight: .medium))
                                                .foregroundColor(.white)
                                        }
                                        
                                        // Button info
                                        VStack(spacing: 4) {
                            Text("Custom")
                                .font(.system(.subheadline, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                                            
                                            Text("Add Amount")
                                                .font(.caption2)
                                                .fontWeight(.medium)
                                                .foregroundColor(.secondary)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 2)
                                                .background(Color(.systemGray6))
                                                .cornerRadius(6)
                                        }
                                        
                                        // Simplified decorative element
                                        Circle()
                                            .fill(primaryAccent.opacity(0.2))
                                            .frame(width: 8, height: 8)
                                    }
                                    .padding(16)
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        Color(.systemBackground),
                                                        Color(.systemBackground).opacity(0.95)
                                                    ]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
                                    )
                                }
                                .accessibilityLabel("Add custom water amount")
                                .padding(.horizontal, 24)
                            } else {
                                // Simplified Custom Input UI
                                VStack(spacing: 16) {
                                    VStack(spacing: 12) {
                                        Text("Enter Custom Amount")
                                            .font(.system(.headline, design: .rounded))
                                            .fontWeight(.bold)
                                            .foregroundColor(.primary)
                                        
                                        HStack(spacing: 16) {
                                            // Simplified text field
                                            VStack(spacing: 4) {
                                                TextField("0", text: $customAmount)
                                                    .font(.title2)
                                                    .fontWeight(.bold)
                                                    .keyboardType(.numberPad)
                                                    .textFieldStyle(.plain)
                                                    .multilineTextAlignment(.center)
                                                    .padding(.horizontal, 16)
                                                    .padding(.vertical, 12)
                                                    .background(Color.white)
                                                    .cornerRadius(12)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 12)
                                                            .stroke(primaryAccent.opacity(0.3), lineWidth: 2)
                                                    )
                                                
                                                Text("ml")
                                                    .font(.caption)
                                                    .fontWeight(.medium)
                                                    .foregroundColor(.secondary)
                                            }
                                            .frame(width: 100)
                                            
                                            // Simplified action buttons
                                            HStack(spacing: 12) {
                                                Button("Add") {
                                                    if let amount = Double(customAmount), amount > 0 {
                                                        impactFeedback.impactOccurred()
                                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                                            currentHydration += amount
                                                        }
                                                        customAmount = ""
                                                        showCustomInput = false
                                                    }
                                                }
                                                .disabled(customAmount.isEmpty)
                                                .font(.system(.subheadline, design: .rounded))
                                                .fontWeight(.bold)
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 20)
                                                .padding(.vertical, 12)
                                                .background(
                                                    LinearGradient(
                                                        gradient: Gradient(colors: [
                                                            customAmount.isEmpty ? Color(.systemGray4) : primaryAccent,
                                                            customAmount.isEmpty ? Color(.systemGray3) : Color(red: 0.6, green: 0.9, blue: 0.4)
                                                        ]),
                                                        startPoint: .leading,
                                                        endPoint: .trailing
                                                    )
                                                )
                                                .cornerRadius(12)
                                                .shadow(color: customAmount.isEmpty ? Color.clear : primaryAccent.opacity(0.3), radius: 4, x: 0, y: 2)
                                                
                                                Button("Cancel") {
                                                    lightFeedback.impactOccurred()
                                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                                        showCustomInput = false
                                                        customAmount = ""
                                                    }
                                                }
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                                .foregroundColor(.secondary)
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 12)
                                                .background(Color(.systemGray6))
                                                .cornerRadius(12)
                                            }
                                        }
                                    }
                                    .padding(20)
                                    .background(Color(.systemBackground))
                                    .cornerRadius(16)
                                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                                }
                                .padding(.horizontal, 24)
                                .transition(.scale.combined(with: .opacity))
                            }
                        }
                        
                        Spacer(minLength: 100) // Space for bottom navigation
                    }
                    .padding(.top, 12)
                }
            }
        .navigationBarHidden(true)
        .background(
            ZStack {
                // Background image
                Image("bgimage-water")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
                    .ignoresSafeArea()
                
                // Light gradient overlay for water theme
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.8), // Much lighter at top
                        Color.white.opacity(0.8), // Light in middle
                        Color.white.opacity(0.8)  // Very light at bottom
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            }
        )
        .onAppear {
            selectedDate = Date()
        }
        .overlay(
            // Fixed Bottom Navigation
            VStack {
                Spacer()
                BottomNavigationBar(selectedTab: "Water")
            }
        )
    }
}

// 2x2 Water Glass Card Component
struct WaterGlassCard2x2: View {
    let glass: WaterGlass
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                // Glass icon with water level indication
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(glass.color.opacity(0.1))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: glass.icon)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(glass.color)
                }
                
                // Glass info
                VStack(spacing: 4) {
                                    Text(glass.size)
                                        .font(.system(.subheadline, design: .rounded))
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)
                    
                    Text(glass.level)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.white.opacity(0.7))
                        .cornerRadius(6)
                }
                
                // Add button
                HStack {
                    Image(systemName: "plus")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
                .frame(width: 28, height: 28)
                .background(glass.color)
                .cornerRadius(14)
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(.systemBackground),
                                Color(.systemBackground).opacity(0.96)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: isPressed ? glass.color.opacity(0.2) : Color.black.opacity(0.06),
                           radius: isPressed ? 8 : 5, x: 0, y: isPressed ? 4 : 3)
            )
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.8), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
        .accessibilityLabel("Add \(glass.size) of water - \(glass.level) level")
    }
}

struct WaterGlass: Identifiable {
    let id = UUID()
    let size: String // ml size
    let mlAmount: Int // ml amount
    let color: Color
    let icon: String // SF Symbol icon name
    let level: String // Water level description
}

struct WaterGlassSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        WaterGlassSelectionView()
    }
}
