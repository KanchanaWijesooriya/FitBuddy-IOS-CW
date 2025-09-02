import SwiftUI

struct WorkoutMainView: View {
    // Example categories and workouts
    let categories = ["All", "ABS & Cardio", "Weights", "Yoga"]
    @State private var selectedCategory = "All"
    
    // Haptic feedback
    private let lightFeedback = UIImpactFeedbackGenerator(style: .light)
    private let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    
    // App theme colors
    private let primaryAccent = Color(red: 0.7, green: 1.0, blue: 0.3) // Your app's original green
    private let workoutOrange = Color(red: 1.0, green: 0.8, blue: 0.3)
    private let workoutBlue = Color(red: 0.3, green: 0.8, blue: 1.0)
    
    struct Workout: Identifiable {
        let id = UUID()
        let name: String
        let category: String
        let level: String
        let progress: Double
        let imageName: String
        let accent: Color
        let status: String
    }
    
    let workouts: [Workout] = [
        Workout(
            name: "ABS & Cardio", 
            category: "ABS & Cardio", 
            level: "Professional", 
            progress: 0.72, 
            imageName: "abs-placeholder", 
            accent: Color(red: 0.7, green: 1.0, blue: 0.3), 
            status: "Active"
        ),
        Workout(
            name: "Weights", 
            category: "Weights", 
            level: "Intermediate", 
            progress: 0.60, 
            imageName: "weights-placeholder", 
            accent: Color(red: 1.0, green: 0.8, blue: 0.3), 
            status: "Active"
        ),
        Workout(
            name: "Yoga", 
            category: "Yoga", 
            level: "Beginner", 
            progress: 0.45, 
            imageName: "yoga-placeholder", 
            accent: Color(red: 0.3, green: 0.8, blue: 1.0), 
            status: "Active"
        )
    ]

    var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    headerSection
                        .padding(.top, 20)
                    
                    todayStatusCard
                    categoryFilterSection
                    workoutCardsSection
                    
                    Spacer()
                        .frame(height: 100) // Space for bottom navigation
                }
            }
            
            // Bottom Navigation Bar (Fixed position)
            VStack {
                Spacer()
                BottomNavigationBar(selectedTab: "Workout")
            }
        }
        .background(Color.white)
        .navigationBarHidden(true)
    }
    
    // MARK: - View Components
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Back button and profile
            HStack {
                Button(action: {
                    lightFeedback.impactOccurred()
                    // Back action (handled by NavigationView automatically)
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .fontWeight(.medium)
                        Text("Back")
                            .font(.body)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(primaryAccent)
                }
                
                Spacer()
                
                // Profile button
                Button(action: {
                    lightFeedback.impactOccurred()
                    // TODO: Navigate to profile
                }) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.title2)
                        .foregroundColor(.black)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            
            // Title section with Apple standard typography
            VStack(alignment: .leading, spacing: 8) {
                Text("Workouts")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                Text("Choose your training program")
                    .font(.subheadline)
                    .foregroundColor(.black)
            }
            .padding(.horizontal, 20)
        }
    }
    
    private var categoryFilterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(categories, id: \.self) { category in
                    Button(action: { 
                        lightFeedback.impactOccurred()
                        selectedCategory = category 
                    }) {
                        Text(category)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(selectedCategory == category ? .white : .black)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(selectedCategory == category ? primaryAccent : Color(.systemGray4))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(selectedCategory == category ? Color.clear : Color.gray.opacity(0.4), lineWidth: 1)
                                    )
                            )
                            .shadow(
                                color: selectedCategory == category ? primaryAccent.opacity(0.3) : Color.clear,
                                radius: selectedCategory == category ? 6 : 0,
                                x: 0,
                                y: selectedCategory == category ? 3 : 0
                            )
                    }
                }
            }
            .padding(.horizontal, 24)
        }
        .padding(.vertical, 16)
    }
    
    private var todayStatusCard: some View {
        VStack(spacing: 16) {
            ZStack {
                // Glassmorphism background
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(.systemGray6),
                                Color(.systemGray5)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.1), radius: 15, x: 0, y: 8)
                
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Today's Progress")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.title3)
                            .foregroundColor(primaryAccent)
                    }
                    
                    // Calories section with enhanced styling
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.orange, Color.red.opacity(0.8)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 50, height: 50)
                            
                            Image(systemName: "flame.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("2,350 kcal")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                            
                            Text("Calories burned today")
                                .font(.caption)
                                .foregroundColor(.black)
                        }
                        
                        Spacer()
                    }
                    
                    // Stats row
                    HStack(spacing: 24) {
                        statsItem(
                            icon: "figure.walk",
                            title: "STEPS",
                            value: "12,340",
                            color: workoutBlue
                        )
                        
                        Divider()
                            .background(Color.gray.opacity(0.3))
                        
                        statsItem(
                            icon: "drop.fill",
                            title: "WATER",
                            value: "1.8 L",
                            color: Color.cyan
                        )
                        
                        Divider()
                            .background(Color.gray.opacity(0.3))
                        
                        statsItem(
                            icon: "heart.fill",
                            title: "HEART",
                            value: "145 BPM",
                            color: Color.red
                        )
                    }
                }
                .padding(24)
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 16)
    }
    
    private func statsItem(icon: String, title: String, value: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            VStack(spacing: 2) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.black)
                
                Text(value)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private var workoutCardsSection: some View {
        LazyVStack(spacing: 16) {
            ForEach(workouts.filter { selectedCategory == "All" || $0.category == selectedCategory }) { workout in
                NavigationLink(destination: WorkoutDetailView(workout: workout)) {
                    workoutCard(workout: workout)
                }
                .buttonStyle(PlainButtonStyle())
                .onTapGesture {
                    lightFeedback.impactOccurred()
                    print("Tapped workout: \(workout.name)")
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 20)
    }
    
    private func workoutCard(workout: Workout) -> some View {
        ZStack {
            // Much more vibrant and darker card background
            RoundedRectangle(cornerRadius: 20)
                .fill(workout.accent)
                .shadow(color: workout.accent.opacity(0.6), radius: 18, x: 0, y: 10)
            
            HStack(spacing: 16) {
                // Enhanced workout icon section with white background
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .frame(width: 80, height: 80)
                        .shadow(color: Color.black.opacity(0.25), radius: 10, x: 0, y: 5)
                    
                    Image(systemName: workoutIcon(for: workout.category))
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(workout.accent)
                }
                
                // Workout details with bold black text
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(workout.name)
                            .font(.headline)
                            .fontWeight(.heavy)
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        // Level badge with white background and bold black text
                        Text(workout.level.uppercased())
                            .font(.caption)
                            .fontWeight(.heavy)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(Color.white)
                                    .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                            )
                            .foregroundColor(.black)
                    }
                    
                    Text(workout.status)
                        .font(.subheadline)
                        .fontWeight(.heavy)
                        .foregroundColor(.black)
                    
                    // Progress bar with bold black text
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("PROGRESS")
                                .font(.caption)
                                .fontWeight(.heavy)
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            Text("\(Int(workout.progress * 100))%")
                                .font(.caption)
                                .fontWeight(.heavy)
                                .foregroundColor(.black)
                        }
                        
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.black.opacity(0.25))
                                .frame(height: 12)
                            
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.white)
                                .frame(width: CGFloat(workout.progress) * 180, height: 12)
                                .shadow(color: Color.black.opacity(0.2), radius: 3, x: 0, y: 1)
                        }
                    }
                }
                
                // Arrow indicator in bold black
                Image(systemName: "chevron.right")
                    .font(.title2)
                    .fontWeight(.heavy)
                    .foregroundColor(.black)
            }
            .padding(20)
        }
        .frame(height: 120)
    }
    
    private func workoutIcon(for category: String) -> String {
        switch category {
        case "ABS & Cardio":
            return "figure.core.training"
        case "Weights":
            return "dumbbell.fill"
        case "Yoga":
            return "figure.yoga"
        default:
            return "figure.run"
        }
    }
}

struct WorkoutMainView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            WorkoutMainView()
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .preferredColorScheme(.light)
    }
}
