import SwiftUI

struct WorkoutMainView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    
    // Example categories and workouts
    let categories = ["All", "ABS & Cardio", "Weights", "Yoga"]
    @State private var selectedCategory = "All"
    
    // Haptic feedback
    private let lightFeedback = UIImpactFeedbackGenerator(style: .light)
    private let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    
    // Water Blue theme from hydration
    private let primaryAccent = Color.waterBlue // Water blue hydration theme
    
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
            accent: Color.lightBlue,
            status: "Active"
        ),
        Workout(
            name: "Weights",
            category: "Weights",
            level: "Intermediate",
            progress: 0.60,
            imageName: "squats",
            accent: Color.darkBlue,
            status: "Active"
        ),
        Workout(
            name: "Yoga",
            category: "Yoga",
            level: "Beginner",
            progress: 0.45,
            imageName: "lunge",
            accent: Color.hydrationTeal,
            status: "Active"
        )
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Header without back button for main page
            mainHeaderView
            
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
                .padding(.bottom, 16) // Minimal bottom padding; nav bar handled by safeAreaInset
            }
            .background(Color.adaptiveBackground)
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .toolbarColorScheme(.light, for: .navigationBar)
    }
    
    // MARK: - Main Header View (without back button)
    private var mainHeaderView: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Workout Title - iOS Standard H1 with better spacing
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Workouts")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Stay fit with personalized training")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Profile or notification icon
                Button(action: {
                    // Handle profile action
                }) {
                    ZStack {
                        Circle()
                            .fill(primaryAccent.opacity(0.1))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "person.circle.fill")
                            .font(.title2)
                            .foregroundColor(primaryAccent)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 8)
        }
        .background(Color(.systemBackground))
    }
    
    // MARK: - Header View (with back button for sub-pages)
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 2) {
            // Back Button - iOS Standard Position
            HStack {
                BackButton()
                
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
    
    // MARK: - Category Filter Section - enhanced design with blue theme
    private var categoryFilterSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Categories")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(workouts.filter { selectedCategory == "All" || $0.category == selectedCategory }.count) workouts")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(categories, id: \.self) { category in
                        Button(action: {
                            lightFeedback.impactOccurred()
                            withAnimation(.easeInOut(duration: 0.3)) {
                                selectedCategory = category
                            }
                        }) {
                            HStack(spacing: 6) {
                                if selectedCategory == category {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                }
                                
                                Text(category)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(selectedCategory == category ? .white : .primary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(
                                        selectedCategory == category ? 
                                        LinearGradient(
                                            colors: [
                                                Color.waterBlue,                              // Your app's main blue
                                                Color.waterBlue.opacity(0.8)                 // Lighter variant
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ) :
                                        LinearGradient(
                                            colors: [
                                                Color.waterBlue.opacity(0.1),                // Very light blue
                                                Color.waterBlue.opacity(0.05)               // Light blue tint
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(
                                                selectedCategory == category ? 
                                                Color.clear :
                                                Color.waterBlue.opacity(0.4),
                                                lineWidth: 1
                                            )
                                    )
                            )
                            .shadow(
                                color: selectedCategory == category ? 
                                    Color.waterBlue.opacity(0.4) : 
                                    Color.waterBlue.opacity(0.2),
                                radius: selectedCategory == category ? 10 : 4,
                                x: 0,
                                y: selectedCategory == category ? 6 : 2
                            )
                        }
                        .scaleEffect(selectedCategory == category ? 1.05 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: selectedCategory)
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
    
    // MARK: - Metrics Card View - enhanced design with light blue gradient theme
    private var metricsCardView: some View {
        ZStack {
            // Enhanced background with light blue mix gradient
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.waterBlue.opacity(0.05),                  // Very light waterBlue
                            Color.waterBlue.opacity(0.08),                  // Light waterBlue
                            Color.waterBlue.opacity(0.06),                  // Light waterBlue with subtle tint
                            Color.waterBlue.opacity(0.15)                   // Primary waterBlue tint
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
                                    primaryAccent.opacity(0.3),
                                    Color.waterBlue.opacity(0.4),
                                    primaryAccent.opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
                .shadow(
                    color: Color.waterBlue.opacity(0.15),
                    radius: 25,
                    x: 0,
                    y: 12
                )
            
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Today's Progress")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("Keep up the great work!")
                            .font(.caption)
                            .foregroundColor(Color(red: 0.3, green: 0.5, blue: 0.8))
                    }
                    
                    Spacer()
                    
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        primaryAccent.opacity(0.2),
                                        Color.waterBlue.opacity(0.3)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 36, height: 36)
                        
                        Image(systemName: "chart.bar.fill")
                            .font(.title3)
                            .foregroundColor(primaryAccent)
                    }
                }
                
                // Enhanced stats row with better design
                HStack(spacing: 0) {
                    enhancedStatsItem(
                        icon: "flame.fill",
                        title: "CALORIES",
                        value: "2,350",
                        color: Color.orange
                    )
                    
                    Rectangle()
                        .fill(Color.waterBlue.opacity(0.6))
                        .frame(width: 1, height: 40)
                        .padding(.horizontal, 16)
                    
                    enhancedStatsItem(
                        icon: "clock.fill",
                        title: "TIME",
                        value: "85 min",
                        color: primaryAccent
                    )
                    
                    Rectangle()
                        .fill(Color.waterBlue.opacity(0.6))
                        .frame(width: 1, height: 40)
                        .padding(.horizontal, 16)
                    
                    enhancedStatsItem(
                        icon: "target",
                        title: "STREAK",
                        value: "7 days",
                        color: primaryAccent
                    )
                }
            }
            .padding(24)
        }
    }
    
    // MARK: - Enhanced Stats Item Helper
    private func enhancedStatsItem(icon: String, title: String, value: String, color: Color) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 32, height: 32)
                
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(color)
            }
            
            VStack(spacing: 2) {
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(title)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Workout Cards Section - enhanced design
    private var workoutCardsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Training Programs")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text("Choose your workout style")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    // Handle view all action
                }) {
                    HStack(spacing: 4) {
                        Text("View All")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(primaryAccent)
                        
                        Image(systemName: "arrow.right")
                            .font(.caption2)
                            .foregroundColor(primaryAccent)
                    }
                }
            }
            
            LazyVStack(spacing: 16) {
                ForEach(workouts.filter { selectedCategory == "All" || $0.category == selectedCategory }) { workout in
                    NavigationLink(destination: WorkoutDetailView()
                        .environmentObject(navigationCoordinator)
                        .onAppear {
                            // Set workout data in navigation coordinator
                            navigationCoordinator.navigateToWorkoutDetail(
                                workoutName: workout.name,
                                workoutData: [
                                    "level": workout.level,
                                    "progress": workout.progress,
                                    "imageName": workout.imageName,
                                    "accent": workout.accent,
                                    "status": workout.status,
                                    "category": workout.category
                                ]
                            )
                        }
                    ) {
                        WorkoutStatusCard(workout: workout)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .contentShape(Rectangle())
                    .simultaneousGesture(TapGesture().onEnded {
                        impactFeedback.impactOccurred()
                    })
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
                            .foregroundColor(Color.adaptiveBackground)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(Color.adaptivePrimaryText)
                            )
                            .overlay(
                                Capsule()
                                    .stroke(Color.adaptivePrimaryText.opacity(0.7), lineWidth: 1)
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
                .fill(Color.adaptiveCardBackground)
                .shadow(color: Color.primary.opacity(0.1), radius: 12, x: 0, y: 6)
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
            
            // Gradient Overlay - Lighter with good text contrast
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.black.opacity(0.5),
                            Color.black.opacity(0.4),
                            Color.black.opacity(0.3)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 170)
            
            // Content Overlay - Optimized spacing for better text display
            HStack(spacing: 12) {
                // Icon section with enhanced design - Slightly smaller for more text space
                VStack(spacing: 6) {
                    ZStack {
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
                            .frame(width: 45, height: 45)
                        
                        // Icon
                        Image(systemName: workoutIcon(for: workout.category))
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .shadow(color: workout.accent.opacity(0.5), radius: 8, x: 0, y: 4)
                }
                
                // Content section - Optimized layout for better text display
                VStack(alignment: .leading, spacing: 8) {
                    // Title and subtitle - Enhanced visibility for lighter background
                    VStack(alignment: .leading, spacing: 2) {
                        Text(workout.name)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(1.0), radius: 3, x: 1, y: 1)
                            .shadow(color: .black.opacity(0.8), radius: 1, x: 0, y: 0)
                            .lineLimit(1)
                        
                        Text(workout.level)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(1.0), radius: 2, x: 1, y: 1)
                            .shadow(color: .black.opacity(0.8), radius: 1, x: 0, y: 0)
                    }
                    
                    // Progress metrics - Enhanced visibility with lighter background
                    VStack(alignment: .leading, spacing: 6) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(Int(workout.progress * 100))% completed")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(1.0), radius: 3, x: 1, y: 1)
                                .shadow(color: .black.opacity(0.8), radius: 1, x: 0, y: 0)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                        }
                        
                        Text("Keep going!")
                            .font(.caption)
                            .foregroundColor(.white)
                            .fontWeight(.semibold)
                            .shadow(color: .black.opacity(1.0), radius: 2, x: 1, y: 1)
                            .shadow(color: .black.opacity(0.8), radius: 1, x: 0, y: 0)
                    }
                    
                    // Enhanced Progress bar - Compact size for better text space
                    VStack(alignment: .leading, spacing: 4) {
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white.opacity(0.3))
                                .frame(height: 5)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(Color.black.opacity(0.2), lineWidth: 0.5)
                                )
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.white,
                                            Color.white.opacity(0.95)
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: max(5, 120 * workout.progress), height: 5)
                                .animation(Animation.easeInOut(duration: 0.8), value: workout.progress)
                                .shadow(color: Color.black.opacity(0.3), radius: 1, x: 0, y: 1)
                        }
                        .frame(width: 120)
                    }
                }
                
                Spacer()
                
                // Enhanced chevron - Smaller for more text space
                VStack {
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(1.0), radius: 2, x: 1, y: 1)
                        .shadow(color: .black.opacity(0.8), radius: 1, x: 0, y: 0)
                    
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
    NavigationView {
        WorkoutMainView()
    }
    .environmentObject(NavigationCoordinator())
    .preferredColorScheme(.light)
}
