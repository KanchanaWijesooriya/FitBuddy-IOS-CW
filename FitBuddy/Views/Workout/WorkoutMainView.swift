import SwiftUI

struct WorkoutMainView: View {
    @Environment(\.dismiss) private var dismiss
    
    // Example categories and workouts
    let categories = ["All", "ABS & Cardio", "Weights", "Yoga"]
    @State private var selectedCategory = "All"
    
    // Haptic feedback
    private let lightFeedback = UIImpactFeedbackGenerator(style: .light)
    private let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    
    // App theme colors - matching StatusOverview
    private let primaryAccent = Color(red: 0.7, green: 1.0, blue: 0.3) // Main theme green
    
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
            accent: Color.orange,
            status: "Active"
        ),
        Workout(
            name: "Weights",
            category: "Weights",
            level: "Intermediate",
            progress: 0.60,
            imageName: "squats",
            accent: Color.purple,
            status: "Active"
        ),
        Workout(
            name: "Yoga",
            category: "Yoga",
            level: "Beginner",
            progress: 0.45,
            imageName: "lunge",
            accent: Color.blue,
            status: "Active"
        )
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Header with back button and title
            headerView
            
            ScrollView {
                VStack(spacing: 24) {
                    // Metrics Card - showing workout stats
                    metricsCardView
                    
                    // Category Filter Section
                    categoryFilterSection
                    
                    // Workout Cards Section
                    workoutCardsSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
            }
            .background(Color(.systemBackground))
            
            // Bottom Navigation Bar
            BottomNavigationBar(selectedTab: "Workout")
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .ignoresSafeArea(.container, edges: [])
        .toolbarColorScheme(.light, for: .navigationBar)
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 2) {
            // Back Button - iOS Standard Position
            HStack {
                BackButton(action: {
                    dismiss()
                })
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            
            // Workout Title - iOS Standard H1
            HStack {
                Text("Workouts")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
        .background(Color(.systemBackground))
    }
    
    // MARK: - Stats Item Helper
    private func statsItem(icon: String, title: String, value: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            VStack(spacing: 2) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(value)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Category Filter Section - matching StatusOverview style
    private var categoryFilterSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Categories")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
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
                                .foregroundColor(selectedCategory == category ? .white : .primary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(selectedCategory == category ? primaryAccent : Color(.systemGray6))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(
                                                    selectedCategory == category ? 
                                                    LinearGradient(
                                                        gradient: Gradient(colors: [
                                                            primaryAccent.opacity(0.3),
                                                            Color.clear
                                                        ]),
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    ) :
                                                    LinearGradient(
                                                        gradient: Gradient(colors: [Color.clear]),
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    ),
                                                    lineWidth: 1
                                                )
                                        )
                                )
                                .shadow(
                                    color: selectedCategory == category ? primaryAccent.opacity(0.2) : Color.clear,
                                    radius: selectedCategory == category ? 8 : 0,
                                    x: 0,
                                    y: selectedCategory == category ? 4 : 0
                                )
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
    
    // MARK: - Metrics Card View - showing workout statistics
    private var metricsCardView: some View {
        ZStack {
            // Background with gradient using app theme
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white,
                            primaryAccent.opacity(0.15),
                            primaryAccent.opacity(0.25)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(primaryAccent.opacity(0.3), lineWidth: 1.5)
                )
                .shadow(color: primaryAccent.opacity(0.2), radius: 15, x: 0, y: 8)
            
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Workout Statistics")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "chart.bar.fill")
                        .font(.title3)
                        .foregroundColor(primaryAccent)
                }
                
                // Stats row with workout metrics
                HStack(spacing: 24) {
                    statsItem(
                        icon: "flame.fill",
                        title: "CALORIES",
                        value: "2,350",
                        color: Color.orange
                    )
                    
                    Divider()
                        .background(primaryAccent.opacity(0.4))
                    
                    statsItem(
                        icon: "clock.fill",
                        title: "TIME",
                        value: "85 min",
                        color: Color.blue
                    )
                    
                    Divider()
                        .background(primaryAccent.opacity(0.4))
                    
                    statsItem(
                        icon: "target",
                        title: "STREAK",
                        value: "7 days",
                        color: primaryAccent
                    )
                }
            }
            .padding(20)
        }
    }
    
    // MARK: - Category Filter Section - matching StatusOverview style
    private var workoutCardsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Training Programs")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            LazyVStack(spacing: 16) {
                ForEach(workouts.filter { selectedCategory == "All" || $0.category == selectedCategory }) { workout in
                    NavigationLink(destination: WorkoutDetailView(workout: workout)) {
                        WorkoutStatusCard(workout: workout)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .contentShape(Rectangle())
                }
            }
        }
    }
    
    private func workoutSquareCard(workout: Workout) -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 16) {
                // 3D Square image with reference-style design
                ZStack {
                    // Base shadow layer for 3D effect
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.black.opacity(0.2))
                        .frame(width: 120, height: 120)
                        .offset(x: 3, y: 3)
                    
                    // Main image container
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .frame(width: 120, height: 120)
                        .overlay(
                            // Workout image
                            Image(workout.imageName)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 120, height: 120)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        )
                        .overlay(
                            // Gradient overlay for better text contrast
                            // Gradient overlay for better text contrast
                            RoundedRectangle(cornerRadius: 16)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.clear,
                                            Color.black.opacity(0.3)
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                        )
                        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                }
                
                // Workout details section
                VStack(alignment: .leading, spacing: 8) {
                    // Workout name and level
                    VStack(alignment: .leading, spacing: 4) {
                        Text(workout.name)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .lineLimit(1)
                        
                        // Compact level label
                        Text(workout.level)
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(Color.black)
                            )
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.7), lineWidth: 1)
                            )
                    }
                    
                    Spacer()
                    
                    // Start Workout button with arrow
                    HStack(spacing: 8) {
                        Text("Start Workout")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(workout.accent)
                        
                        Image(systemName: "arrow.right")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(workout.accent)
                    }
                }
                
                Spacer()
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 20, x: 0, y: 8)
        )
        .padding(.horizontal, 4) // Extra padding for shadow
    }
    
}

// MARK: - Supporting Views
struct WorkoutStatusCard: View {
    let workout: WorkoutMainView.Workout
    
    private var backgroundImageName: String {
        switch workout.category {
        case "ABS & Cardio":
            return "bgimage-workout"
        case "Weights":
            return "squats"
        case "Yoga":
            return "lunge"
        default:
            return "bgimage-workout"
        }
    }
    
    var body: some View {
        ZStack {
            // Background Image
            Image(backgroundImageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 170)
                .clipped()
            
            // Gradient Overlay
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.black.opacity(0.7),
                            Color.black.opacity(0.4),
                            workout.accent.opacity(0.3)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 170)
            
            // Content Overlay
            HStack(spacing: 16) {
                // Icon section with enhanced design
                VStack(spacing: 8) {
                    ZStack {
                        // Outer glow circle
                        Circle()
                            .fill(
                                RadialGradient(
                                    gradient: Gradient(colors: [
                                        workout.accent.opacity(0.3),
                                        Color.clear
                                    ]),
                                    center: .center,
                                    startRadius: 25,
                                    endRadius: 45
                                )
                            )
                            .frame(width: 70, height: 70)
                        
                        // Main icon background
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        workout.accent.opacity(0.9),
                                        workout.accent.opacity(0.7)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 50, height: 50)
                        
                        // Icon
                        Image(systemName: workoutIcon(for: workout.category))
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .shadow(color: workout.accent.opacity(0.5), radius: 10, x: 0, y: 5)
                }
                
                // Content section
                VStack(alignment: .leading, spacing: 12) {
                    // Title and subtitle
                    VStack(alignment: .leading, spacing: 4) {
                        Text(workout.name)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .lineLimit(nil)
                            .fixedSize(horizontal: true, vertical: false)
                            .multilineTextAlignment(.leading)
                        
                        Text(workout.level)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    // Progress metrics
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(alignment: .bottom, spacing: 4) {
                            Text("\(Int(workout.progress * 100))%")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("completed")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        Text("Keep going!")
                            .font(.caption2)
                            .foregroundColor(workout.accent.opacity(0.9))
                            .fontWeight(.medium)
                    }
                    
                    // Enhanced Progress bar
                    VStack(alignment: .leading, spacing: 4) {
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.white.opacity(0.2))
                                .frame(height: 8)
                            
                            RoundedRectangle(cornerRadius: 6)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            workout.accent.opacity(0.9),
                                            workout.accent
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: max(8, 160 * workout.progress), height: 8)
                                .animation(Animation.easeInOut(duration: 0.8), value: workout.progress)
                                .shadow(color: workout.accent.opacity(0.4), radius: 4, x: 0, y: 2)
                        }
                        .frame(width: 160)
                    }
                }
                
                Spacer()
                
                // Enhanced chevron
                VStack {
                    Spacer()
                    
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.15))
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                    
                    Spacer()
                }
            }
            .padding(20)
        }
        .frame(height: 170)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: workout.accent.opacity(0.2), radius: 15, x: 0, y: 8)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            workout.accent.opacity(0.3),
                            Color.clear
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
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

#Preview {
    NavigationStack {
        WorkoutMainView()
    }
    .preferredColorScheme(.light)
}
