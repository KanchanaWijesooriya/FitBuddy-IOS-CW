import SwiftUI

struct WaterGlassSelectionView: View {
    @State private var currentHydration: Double = 2000 // ml
    @State private var dailyGoal: Double = 3000 // ml
    @State private var selectedDate = Date()
    @State private var customAmount: String = ""
    @State private var showCustomInput = false
    
    // Date formatter for days
    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E" // Mon, Tue, Wed, etc.
        return formatter
    }()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d" // 1, 2, 3, etc.
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
    
    // Different water glass sizes
    let waterGlasses = [
        WaterGlass(size: "100ml", mlAmount: 100, color: Color(red: 0.2, green: 0.6, blue: 0.9)),
        WaterGlass(size: "250ml", mlAmount: 250, color: Color(red: 0.1, green: 0.5, blue: 0.8)),
        WaterGlass(size: "350ml", mlAmount: 350, color: Color(red: 0.3, green: 0.7, blue: 1.0)),
        WaterGlass(size: "500ml", mlAmount: 500, color: Color(red: 0.0, green: 0.4, blue: 0.7))
    ]
    
    var progressPercentage: Double {
        return min(currentHydration / dailyGoal, 1.0)
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Main scrollable content
            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    VStack(alignment: .leading, spacing: 0) {
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
                        .padding(.top, 24)
                        .padding(.leading, 24)
                        
                        HStack {
                            Text("Water Intake")
                                .font(.system(.largeTitle, design: .default))
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                            Spacer()
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 8)
                    }
                    .background(Color(.systemBackground))
                    
                    // Weekly Date Selector
                    HStack(spacing: 0) {
                        ForEach(weekDates, id: \.self) { date in
                            let isToday = Calendar.current.isDate(date, inSameDayAs: Date())
                            let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedDate)
                            
                            Button(action: { selectedDate = date }) {
                                VStack(spacing: 8) {
                                    Text(dayFormatter.string(from: date).uppercased())
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(isSelected ? .white : .gray)
                                    
                                    Text(dateFormatter.string(from: date))
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(isSelected ? .white : .black)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 70)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(isToday && isSelected ? Color(red: 0.2, green: 0.6, blue: 0.9) : 
                                             isSelected ? Color.gray : Color.clear)
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                    .padding(.bottom, 30)
                    
                    // Main Circular Progress View
                    VStack(spacing: 40) {
                        ZStack {
                            // Background circle
                            Circle()
                                .stroke(Color(.systemGray5), lineWidth: 25)
                                .frame(width: 280, height: 280)
                            
                            // Progress circle
                            Circle()
                                .trim(from: 0, to: progressPercentage)
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 0.3, green: 0.7, blue: 1.0),
                                            Color(red: 0.2, green: 0.6, blue: 0.9),
                                            Color(red: 0.1, green: 0.5, blue: 0.8)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    style: StrokeStyle(lineWidth: 25, lineCap: .round)
                                )
                                .frame(width: 280, height: 280)
                                .rotationEffect(.degrees(-90))
                                .animation(.easeInOut(duration: 1.0), value: progressPercentage)
                            
                            // Center content
                            VStack(spacing: 8) {
                                Image(systemName: "drop.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.9))
                                
                                Text("\(Int(currentHydration))")
                                    .font(.system(size: 48, weight: .bold, design: .default))
                                    .foregroundColor(.black)
                                
                                Text("Today")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                
                                Text("GOAL \(Int(dailyGoal))ml")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        // Water Glass Options - Single Row
                        VStack(spacing: 20) {
                            HStack(spacing: 12) {
                                ForEach(waterGlasses, id: \.size) { glass in
                                    WaterGlassCard(glass: glass) {
                                        // Add water glass action
                                        currentHydration += Double(glass.mlAmount)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            
                            // Custom Water Input Section
                            if showCustomInput {
                                VStack(spacing: 16) {
                                    Text("Add Custom Amount of Water")
                                        .font(.headline)
                                        .foregroundColor(.black)
                                    
                                    HStack(spacing: 12) {
                                        TextField("Amount", text: $customAmount)
                                            .textFieldStyle(.roundedBorder)
                                            .keyboardType(.numberPad)
                                            .frame(maxWidth: 120)
                                        
                                        Text("ml")
                                            .font(.headline)
                                            .foregroundColor(.gray)
                                        
                                        Button(action: {
                                            if let amount = Double(customAmount), amount > 0 {
                                                currentHydration += amount
                                                customAmount = ""
                                                showCustomInput = false
                                            }
                                        }) {
                                            Text("Add")
                                                .font(.headline)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 20)
                                                .padding(.vertical, 8)
                                                .background(Color(red: 0.2, green: 0.6, blue: 0.9))
                                                .cornerRadius(8)
                                        }
                                        .disabled(customAmount.isEmpty)
                                        .opacity(customAmount.isEmpty ? 0.6 : 1.0)
                                    }
                                    
                                    Button(action: {
                                        showCustomInput = false
                                        customAmount = ""
                                    }) {
                                        Text("Cancel")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding(16)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                                .padding(.horizontal, 16)
                            } else {
                                // Add Water Button
                                Button(action: {
                                    showCustomInput = true
                                }) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color(red: 0.2, green: 0.6, blue: 0.9))
                                            .frame(width: 70, height: 70)
                                        
                                        VStack(spacing: 4) {
                                            Image(systemName: "drop.fill")
                                                .font(.system(size: 20))
                                                .foregroundColor(.white)
                                            
                                            Text("Custom")
                                                .font(.caption)
                                                .fontWeight(.bold)
                                                .foregroundColor(.white)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 120) // Space for fixed bottom navigation
                    }
                }
            }
            
            // Fixed Bottom Navigation (doesn't move with scroll)
            VStack {
                Spacer()
                BottomNavigationBar(selectedTab: "Status")
            }
        }
        .background(Color(.systemBackground))
        .navigationBarHidden(true)
        .onAppear {
            selectedDate = Date() // Set today as default
        }
    }
    }



struct WaterGlass {
    let size: String // ml size
    let mlAmount: Int // ml amount
    let color: Color
}

struct WaterGlassCard: View {
    let glass: WaterGlass
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                // Glass icon container with water level visualization
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(glass.color.opacity(0.1))
                        .frame(width: 60, height: 60)
                    
                    // Glass visualization
                    ZStack {
                        // Glass outline
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(glass.color.opacity(0.3), lineWidth: 1.5)
                            .frame(width: 28, height: 36)
                        
                        // Water in glass (different levels for different sizes)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        glass.color.opacity(0.8),
                                        glass.color
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 24, height: getWaterLevel(for: glass.size))
                            .offset(y: getWaterOffset(for: glass.size))
                    }
                }
                
                // Glass size info
                VStack(spacing: 2) {
                    Text(glass.size)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    
                    Text("Water")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                
                // Add button
                Button(action: action) {
                    Image(systemName: "plus")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 20, height: 20)
                        .background(glass.color)
                        .clipShape(Circle())
                }
            }
            .padding(8)
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.systemGray5), lineWidth: 1)
            )
            .cornerRadius(12)
            .shadow(color: glass.color.opacity(0.1), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // Helper functions to create different water levels in glasses
    private func getWaterLevel(for size: String) -> CGFloat {
        switch size {
        case "100ml": return 12
        case "250ml": return 18
        case "350ml": return 24
        case "500ml": return 30
        default: return 18
        }
    }
    
    private func getWaterOffset(for size: String) -> CGFloat {
        switch size {
        case "100ml": return 12
        case "250ml": return 9
        case "350ml": return 6
        case "500ml": return 3
        default: return 9
        }
    }
}

struct WaterGlassSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        WaterGlassSelectionView()
    }
}
