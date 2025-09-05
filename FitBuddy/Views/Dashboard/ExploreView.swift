import SwiftUI

// Data models for workout items
struct WorkoutItem: Identifiable {
    let id = UUID()
    let title: String
    let duration: String
    let calories: String
    let level: String
    let imageName: String
}

// Search suggestions data
struct SearchSuggestion: Identifiable {
    let id = UUID()
    let title: String
    let category: String
}

struct ExploreView: View {
    @State private var searchText = ""
    @State private var showSearchSuggestions = false
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var stepService: StepService
    @EnvironmentObject var waterService: WaterService
    
    // Sample data matching the image
    let bestForYouWorkouts = [
        WorkoutItem(title: "Belly fat burner", duration: "10 min", calories: "300 Cal", level: "Beginner", imageName: "onboarding-screen"),
        WorkoutItem(title: "Lose Fat", duration: "15 min", calories: "250 Cal", level: "Beginner", imageName: "onboarding-screen-2"),
        WorkoutItem(title: "Plank", duration: "5 min", calories: "150 Cal", level: "Expert", imageName: "onboarding-screen-3"),
        WorkoutItem(title: "Build Wide", duration: "30 min", calories: "450 Cal", level: "Intermediate", imageName: "challenge-image")
    ]
    
    // Search suggestions
    let searchSuggestions = [
        SearchSuggestion(title: "Push ups", category: "Exercise"),
        SearchSuggestion(title: "Cardio workout", category: "Workout"),
        SearchSuggestion(title: "Yoga", category: "Workout"),
        SearchSuggestion(title: "Weight loss", category: "Goal"),
        SearchSuggestion(title: "Abs workout", category: "Workout"),
        SearchSuggestion(title: "Running", category: "Exercise"),
        SearchSuggestion(title: "Strength training", category: "Workout")
    ]
    
    var filteredSuggestions: [SearchSuggestion] {
        if searchText.isEmpty {
            return []
        }
        return searchSuggestions.filter { suggestion in
            suggestion.title.localizedCaseInsensitiveContains(searchText) ||
            suggestion.category.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var displayName: String {
        if let user = authService.currentUser {
            if !user.name.isEmpty {
                return user.name
            } else if let email = user.email {
                // Extract name from email if no name is set
                let components = email.components(separatedBy: "@")
                if let username = components.first {
                    return username.capitalized
                }
            }
        }
        return "User"
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header Section with Good Morning, Name, and Profile
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                // Good Morning with flame icon
                                HStack(spacing: 6) {
                                    Text("Good Morning")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    Text("🔥")
                                        .font(.subheadline)
                                }
                                
                                // User Name with header 2 font - Dynamic from auth
                                Text(displayName)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                
                                // Explore with heading 1 font
                                Text("Explore")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                            }
                            
                            Spacer()
                            
                                                        // Profile photo in upper right corner
                            Button(action: {}) {
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color(red: 0.7, green: 1.0, blue: 0.3),
                                                    Color(red: 0.5, green: 0.8, blue: 0.2)
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 50, height: 50)
                                    
                                    Image(systemName: "person.fill")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                }
                                .shadow(color: Color(red: 0.7, green: 1.0, blue: 0.3).opacity(0.3), radius: 8, x: 0, y: 4)
                            }
                        }
                        
                        // Enhanced Search Bar with Suggestions
                        VStack(spacing: 0) {
                            HStack(spacing: 12) {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.secondary)
                                    .font(.body)
                                
                                TextField("Search workouts, exercises...", text: $searchText)
                                    .textFieldStyle(PlainTextFieldStyle())
                                    .font(.body)
                                    .onChange(of: searchText) { value in
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            showSearchSuggestions = !value.isEmpty
                                        }
                                    }
                                
                                if !searchText.isEmpty {
                                    Button(action: {
                                        searchText = ""
                                        showSearchSuggestions = false
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.secondary)
                                            .font(.body)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    
                    // Enhanced Status Section - More prominent
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Today's Progress")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Button(action: {
                                // View all progress
                            }) {
                                Text("View All")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(Color(red: 0.7, green: 1.0, blue: 0.3))
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Modern Status Cards Row - Enhanced scrolling
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 16) {
                                // Steps Card
                                StatusMetricCard(
                                    title: "Steps",
                                    value: "\(stepService.todaySteps)",
                                    goal: "10,000",
                                    progress: Double(stepService.todaySteps) / 10000.0,
                                    icon: "figure.walk",
                                    color: Color(red: 0.2, green: 0.6, blue: 0.9),
                                    gradient: [Color(red: 0.2, green: 0.6, blue: 0.9), Color(red: 0.1, green: 0.4, blue: 0.7)]
                                )
                                
                                // Water Card
                                StatusMetricCard(
                                    title: "Water",
                                    value: String(format: "%.1fL", waterService.todayWater),
                                    goal: "2.5L",
                                    progress: waterService.todayWater / 2.5,
                                    icon: "drop.fill",
                                    color: Color(red: 0.3, green: 0.7, blue: 1.0),
                                    gradient: [Color(red: 0.3, green: 0.7, blue: 1.0), Color(red: 0.2, green: 0.5, blue: 0.8)]
                                )
                                
                                // Calories Card
                                StatusMetricCard(
                                    title: "Calories",
                                    value: "420",
                                    goal: "500",
                                    progress: 0.84,
                                    icon: "flame.fill",
                                    color: Color(red: 1.0, green: 0.6, blue: 0.2),
                                    gradient: [Color(red: 1.0, green: 0.6, blue: 0.2), Color(red: 0.9, green: 0.4, blue: 0.1)]
                                )
                                
                                // Workout Time Card
                                StatusMetricCard(
                                    title: "Workout",
                                    value: "25 min",
                                    goal: "30 min",
                                    progress: 25.0 / 30.0,
                                    icon: "dumbbell.fill",
                                    color: Color(red: 0.7, green: 1.0, blue: 0.3),
                                    gradient: [Color(red: 0.7, green: 1.0, blue: 0.3), Color(red: 0.5, green: 0.8, blue: 0.2)]
                                )
                            }
                            .padding(.horizontal, 20)
                        }
                        .contentMargins(.horizontal, 0)
                    }
                    
                    // Featured Workout Card - Enhanced Design
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Featured Workout")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal, 20)
                        
                        ZStack {
                            // Background Image covering the whole card
                            Image("onboarding-screen-3")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 180)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                            
                            // Modern Gradient Overlay
                            RoundedRectangle(cornerRadius: 20)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.black.opacity(0.7),
                                            Color.black.opacity(0.4),
                                            Color.clear,
                                            Color.black.opacity(0.3)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(height: 180)
                            
                            // Content overlay
                            HStack {
                                VStack(alignment: .leading, spacing: 12) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("FEATURED")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .foregroundColor(Color(red: 0.7, green: 1.0, blue: 0.3))
                                            .tracking(1)
                                        
                                        Text("Best Quarantine\nWorkout")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                            .multilineTextAlignment(.leading)
                                    }
                                    
                                    Button(action: {
                                        // See more action
                                    }) {
                                        HStack(spacing: 8) {
                                            Text("Start Now")
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.black)
                                            
                                            Image(systemName: "arrow.right")
                                                .font(.caption)
                                                .fontWeight(.bold)
                                                .foregroundColor(.black)
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(Color(red: 0.7, green: 1.0, blue: 0.3))
                                        .cornerRadius(20)
                                    }
                                    
                                    Spacer()
                                }
                                .padding(.leading, 24)
                                .padding(.top, 20)
                                
                                Spacer()
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Best for you section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Best for you")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal, 20)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 12),
                            GridItem(.flexible(), spacing: 12)
                        ], spacing: 16) {
                            ForEach(bestForYouWorkouts) { workout in
                                WorkoutCard(workout: workout)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Enhanced Challenge section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Challenges")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Button(action: {
                                // View all challenges
                            }) {
                                Text("View All")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(Color(red: 0.7, green: 1.0, blue: 0.3))
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Enhanced Challenge Cards
                        VStack(spacing: 12) {
                            // Weekly Challenge Card
                            Button(action: {
                                // Navigate to weekly challenges
                            }) {
                                HStack(spacing: 16) {
                                    // Icon Section
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        Color(red: 0.7, green: 1.0, blue: 0.3),
                                                        Color(red: 0.5, green: 0.8, blue: 0.2)
                                                    ]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .frame(width: 60, height: 60)
                                        
                                        Image(systemName: "trophy.fill")
                                            .font(.title2)
                                            .foregroundColor(.white)
                                    }
                                    
                                    // Content Section
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack {
                                            Text("WEEKLY CHALLENGE")
                                                .font(.caption)
                                                .fontWeight(.bold)
                                                .foregroundColor(Color(red: 0.7, green: 1.0, blue: 0.3))
                                                .tracking(0.5)
                                            
                                            Spacer()
                                            
                                            Text("🏆 5")
                                                .font(.caption)
                                                .fontWeight(.bold)
                                        }
                                        
                                        Text("7-Day Fitness Challenge")
                                            .font(.headline)
                                            .fontWeight(.bold)
                                            .foregroundColor(.primary)
                                        
                                        Text("Complete 5 workouts this week")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    // Arrow Section
                                    Image(systemName: "chevron.right")
                                        .font(.body)
                                        .fontWeight(.semibold)
                                        .foregroundColor(Color(red: 0.7, green: 1.0, blue: 0.3))
                                }
                                .padding(20)
                                .background(Color(.systemBackground))
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color(.systemGray5), lineWidth: 1)
                                )
                                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            // Daily Challenge Card
                            Button(action: {
                                // Navigate to daily challenge
                            }) {
                                HStack(spacing: 16) {
                                    // Icon Section
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        Color.orange,
                                                        Color.red
                                                    ]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .frame(width: 60, height: 60)
                                        
                                        Image(systemName: "target")
                                            .font(.title2)
                                            .foregroundColor(.white)
                                    }
                                    
                                    // Content Section
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack {
                                            Text("DAILY CHALLENGE")
                                                .font(.caption)
                                                .fontWeight(.bold)
                                                .foregroundColor(.orange)
                                                .tracking(0.5)
                                            
                                            Spacer()
                                            
                                            Text("🔥 2")
                                                .font(.caption)
                                                .fontWeight(.bold)
                                        }
                                        
                                        Text("50 Push-ups Today")
                                            .font(.headline)
                                            .fontWeight(.bold)
                                            .foregroundColor(.primary)
                                        
                                        Text("Complete to earn flame points")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    // Arrow Section
                                    Image(systemName: "chevron.right")
                                        .font(.body)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.orange)
                                }
                                .padding(20)
                                .background(Color(.systemBackground))
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color(.systemGray5), lineWidth: 1)
                                )
                                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Enhanced View Status section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Your Progress")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        
                        Button(action: {
                            // Navigate to detailed status view
                        }) {
                            HStack(spacing: 16) {
                                // Icon Section
                                ZStack {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color.purple,
                                                    Color.blue
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 60, height: 60)
                                    
                                    Image(systemName: "chart.line.uptrend.xyaxis")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                }
                                
                                // Content Section
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text("ANALYTICS")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .foregroundColor(.purple)
                                            .tracking(0.5)
                                        
                                        Spacer()
                                        
                                        Text("📊")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                    }
                                    
                                    Text("View Detailed Analytics")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)
                                    
                                    Text("Track your complete fitness journey with insights")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                // Arrow
                                Image(systemName: "chevron.right")
                                    .font(.body)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.purple)
                            }
                            .padding(20)
                            .background(Color(.systemBackground))
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color(.systemGray5), lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal, 20)
                    }
                }
            }
            .background(Color(.systemBackground))
            
            // Search Suggestions Overlay
            if showSearchSuggestions {
                ZStack {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showSearchSuggestions = false
                            searchText = ""
                        }
                    
                    VStack {
                        VStack(spacing: 0) {
                            ForEach(filteredSuggestions.prefix(6)) { suggestion in
                                Button(action: {
                                    searchText = suggestion.title
                                    showSearchSuggestions = false
                                    // Handle search action here
                                }) {
                                    HStack(spacing: 12) {
                                        Image(systemName: "magnifyingglass")
                                            .font(.body)
                                            .foregroundColor(.secondary)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(suggestion.title)
                                                .font(.body)
                                                .foregroundColor(.primary)
                                            
                                            Text(suggestion.category)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        Spacer()
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                if suggestion.id != filteredSuggestions.prefix(6).last?.id {
                                    Divider()
                                        .padding(.leading, 44)
                                }
                            }
                        }
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                        .padding(.horizontal, 20)
                        .padding(.top, 120) // Position below search bar
                        
                        Spacer()
                    }
                }
                .transition(.opacity)
            }
        }
    }
    
struct StatusMetricCard: View {
    let title: String
    let value: String
    let goal: String
    let progress: Double
    let icon: String
    let color: Color
    let gradient: [Color]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with icon and title
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: gradient),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: icon)
                        .font(.body)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Text(title.uppercased())
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(color)
                    .tracking(0.5)
            }
            
            // Value section
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("of \(goal)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Progress bar
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray5))
                    .frame(height: 6)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(color)
                    .frame(width: CGFloat(min(progress, 1.0)) * 130, height: 6)
            }
            .frame(width: 130)
        }
        .padding(16)
        .frame(width: 160, height: 140)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
};    struct WorkoutCard: View {
        let workout: WorkoutItem
        
        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                // Workout Image with level badge
                ZStack(alignment: .topTrailing) {
                    Image(workout.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    // Level badge in top-right corner
                    Text(workout.level)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.black)
                        .cornerRadius(8)
                        .padding(12)
                }
                
                // Content section
                VStack(alignment: .leading, spacing: 12) {
                    Text(workout.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    // Time, Calories and Play button layout
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            // Clock with time
                            HStack(spacing: 4) {
                                Image(systemName: "clock.fill")
                                    .font(.caption)
                                    .foregroundColor(Color(red: 0.7, green: 1.0, blue: 0.3))
                                Text(workout.duration)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                            }
                            
                            // Flame with calories
                            HStack(spacing: 4) {
                                Image(systemName: "flame.fill")
                                    .font(.caption)
                                    .foregroundColor(Color(red: 0.7, green: 1.0, blue: 0.3))
                                Text(workout.calories)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                            }
                        }
                        
                        Spacer()
                        
                        // Play button
                        Button(action: {}) {
                            Image(systemName: "play.circle.fill")
                                .font(.title2)
                                .foregroundColor(Color(red: 0.7, green: 1.0, blue: 0.3))
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
            }
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
    }
}

#Preview {
    NavigationStack {
        VStack {
            Text("ExploreView Preview")
                .font(.title)
            Text("Services require authentication")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}
