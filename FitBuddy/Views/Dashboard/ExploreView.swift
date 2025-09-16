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
    @State private var showOnboardingHelp = false
    @State private var hasShownOnboarding = false
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var stepService: StepService
    @EnvironmentObject var waterService: WaterService
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    
    // Water & Purple theme colors
    private let primaryWater = Color(red: 0.024, green: 0.714, blue: 0.831) // Cyan/Water
    private let primaryPurple = Color(red: 0.588, green: 0.239, blue: 0.729) // Purple
    private let redGradient = Color(red: 0.906, green: 0.298, blue: 0.235) // Red for workout
    
    // New yellow/orange mix color to replace purple
    private let yellowOrangeMix = Color(red: 1.0, green: 0.6, blue: 0.0) // Yellow-Orange mix
    
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
    
    // MARK: - Computed Properties for Challenge Cards
    private var weeklyChallengeCard: some View {
        NavigationLink(destination: ChallengeDetailView()
            .environmentObject(navigationCoordinator)
            .onAppear {
                navigationCoordinator.navigateToChallengeDetail(
                    challengeId: "weekly-challenge",
                    challengeData: [
                        "title": "7-Day Fitness Challenge",
                        "type": "workout",
                        "participants": 1247,
                        "description": "Complete daily workouts for 7 consecutive days"
                    ]
                )
            }
        ) {
            HStack(alignment: .center, spacing: 16) {
                // Icon Section - Centered icon only
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    primaryWater,
                                    primaryWater.opacity(0.7)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: "calendar")
                        .font(.title2)
                        .foregroundColor(.white)
                }
                
                // Content Section
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("WEEKLY CHALLENGE")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(primaryWater)
                            .tracking(0.5)
                        
                        Spacer()
                    }
                    
                    Text("7-Day Fitness Challenge")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("1,247 joined • 5 days left")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Arrow Section
                Image(systemName: "chevron.right")
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(primaryWater)
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
    
    private var dailyChallengeCard: some View {
        NavigationLink(destination: ChallengeDetailView()
            .environmentObject(navigationCoordinator)
            .onAppear {
                navigationCoordinator.navigateToChallengeDetail(
                    challengeId: "daily-challenge",
                    challengeData: [
                        "title": "50 Push-ups Today",
                        "type": "exercise",
                        "participants": 892,
                        "description": "Complete 50 push-ups to earn flame points"
                    ]
                )
            }
        ) {
            HStack(alignment: .center, spacing: 16) {
                // Icon Section - Centered icon only
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    redGradient,
                                    redGradient.opacity(0.7)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: "flame.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                }
                
                // Content Section
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("DAILY CHALLENGE")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(redGradient)
                            .tracking(0.5)
                        
                        Spacer()
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
                    .foregroundColor(redGradient)
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
    
    private var analyticsCard: some View {
        Button(action: {
            navigationCoordinator.navigateToTab("Status")
        }) {
            HStack(alignment: .center, spacing: 16) {
                // Icon Section - Centered icon only
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    yellowOrangeMix,
                                    yellowOrangeMix.opacity(0.7)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: "chart.bar.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                }
                
                // Content Section
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("ANALYTICS")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(yellowOrangeMix)
                            .tracking(0.5)
                        
                        Spacer()
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
                
                // Arrow Section
                Image(systemName: "chevron.right")
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(yellowOrangeMix)
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

    var body: some View {
        VStack(spacing: 0) {
            // Fixed Header Section with improved spacing
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        // Good Morning with flame icon
                        HStack(spacing: 6) {
                            Text("Good Morning")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text("🔥")
                                .font(.subheadline)
                        }
                        
                        // User Name with proper spacing
                        Text(displayName)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .padding(.top, 2)
                        
                        // Explore with proper spacing
                        Text("Explore")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .padding(.top, 4)
                    }
                    
                    Spacer()
                    
                    // Profile Avatar with water theme
                    Button(action: {
                        navigationCoordinator.navigateToTab("Profile")
                    }) {
                        ZStack {
                            Circle()
                                .fill(primaryWater.opacity(0.1))
                                .frame(width: 50, height: 50)
                            
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(primaryWater)
                        }
                    }
                }
                
                // Search Bar with water theme
                HStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Search workouts, exercises...", text: $searchText, onEditingChanged: { isEditing in
                            showSearchSuggestions = isEditing && !searchText.isEmpty
                        })
                        .onChange(of: searchText) { _ in showSearchSuggestions = !searchText.isEmpty }
                        
                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                                showSearchSuggestions = false
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(primaryWater)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .background(Color(.systemBackground))
            
            // Scrollable Content
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    // Enhanced Status Section - More prominent
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Text("Today's Progress")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        
                        // Today's Highlights Cards - Water & Purple theme
                        VStack(spacing: 20) {
                            HStack(spacing: 16) {
                                // Steps Card - Water gradient
                                NavigationLink(destination: StatusStepTrackingView()) {
                                    MetricRectangleCard(
                                        title: "Steps",
                                        value: stepService.todaySteps,
                                        goal: 10000,
                                        unit: "steps",
                                        icon: "figure.walk",
                                        color: primaryWater,
                                        progress: Double(stepService.todaySteps) / 10000.0
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                // Water Card - Yellow/Orange mix gradient
                                NavigationLink(destination: StatusHydrationView()
                                    .environmentObject(waterService)) {
                                    MetricRectangleCard(
                                        title: "Water",
                                        value: Int(waterService.todayWater * 1000),
                                        goal: 2500,
                                        unit: "ml",
                                        icon: "drop.fill",
                                        color: yellowOrangeMix,
                                        progress: waterService.todayWater / 2.5
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            
                            // Workout Card - Red gradient
                            NavigationLink(destination: StatusWorkout()) {
                                MetricRectangleCard(
                                    title: "Workout",
                                    value: 25,
                                    goal: 60,
                                    unit: "min",
                                    icon: "figure.strengthtraining.traditional",
                                    color: redGradient,
                                    progress: 25.0 / 60.0
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Featured Workout Card - Enhanced Design
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Featured Workout")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal, 20)
                        
                        Button(action: {
                            navigationCoordinator.navigateToTab("Workout")
                        }) {
                            ZStack(alignment: .bottomLeading) {
                                // Workout image
                                Image("challenge-image")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 200)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                
                                // Gradient overlay
                                LinearGradient(
                                    colors: [Color.clear, Color.black.opacity(0.7)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                
                                // Content overlay
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("FEATURED")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .foregroundColor(primaryWater)
                                            .tracking(0.5)
                                        
                                        Spacer()                                
                                    }
                                    
                                    Text("Best Quarantine\nWorkout")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.leading)
                                }
                                .padding(20)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal, 20)
                    }
                    
                    // Best For You Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Best For You")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 16) {
                                ForEach(bestForYouWorkouts) { workout in
                                    WorkoutCard(workout: workout)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    
                    // Enhanced Challenge section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Challenges")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            NavigationLink(destination: ChallengeMainView().environmentObject(navigationCoordinator)) {
                                Text("View All")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(primaryWater)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Enhanced Challenge Cards
                        VStack(spacing: 12) {
                            weeklyChallengeCard
                            dailyChallengeCard
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Enhanced View Status section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Your Analytics")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        
                        analyticsCard
                            .padding(.horizontal, 20)
                    }
                }
                // Add more top padding for spacing between search bar and content
                .padding(.top, 24)
                // Remove large bottom padding; space for nav bar handled by safeAreaInset in MainNavigationView
                .padding(.bottom, 16)
            }
            
            // Search Suggestions Overlay
            if showSearchSuggestions {
                VStack {
                    Spacer()
                        .frame(height: 180) // Account for fixed header height
                    
                    VStack {
                        ForEach(filteredSuggestions.prefix(5)) { suggestion in
                            Button(action: {
                                searchText = suggestion.title
                                showSearchSuggestions = false
                            }) {
                                HStack {
                                    Image(systemName: "magnifyingglass")
                                        .foregroundColor(.secondary)
                                    
                                    VStack(alignment: .leading) {
                                        Text(suggestion.title)
                                            .foregroundColor(.primary)
                                        Text(suggestion.category)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                }
                                .padding()
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            if suggestion.id != filteredSuggestions.prefix(5).last?.id {
                                Divider()
                            }
                        }
                        
                        Button(action: {
                            showSearchSuggestions = false
                            searchText = ""
                        }) {
                            Text("Cancel")
                                .foregroundColor(.secondary)
                                .padding()
                        }
                    }
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(radius: 10)
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
                .background(Color.black.opacity(0.3))
                .transition(.opacity)
            }
        }
        .overlay(
            // Help button in bottom right corner
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        showOnboardingHelp = true
                    }) {
                        Image(systemName: "questionmark")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .background(
                                Circle()
                                    .fill(primaryWater)
                                    .shadow(color: primaryWater.opacity(0.3), radius: 8, x: 0, y: 4)
                            )
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 100) // Account for tab bar
                }
            }
        )
        .sheet(isPresented: $showOnboardingHelp) {
            OnboardingHelpView(isPresented: $showOnboardingHelp)
        }
        .onAppear {
            // Check if this is a new user and show onboarding
            if authService.isUserLoggedIn && !hasShownOnboarding {
                let hasSeenOnboarding = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
                if !hasSeenOnboarding {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        showOnboardingHelp = true
                        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
                    }
                }
                hasShownOnboarding = true
            }
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
    
    init(title: String, value: String, goal: String, progress: Double, icon: String, color: Color, gradient: [Color]) {
        self.title = title
        self.value = value
        self.goal = goal
        self.progress = progress
        self.icon = icon
        self.color = color
        self.gradient = gradient
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with icon
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                
                Spacer()
                
                Text(title.uppercased())
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                    .tracking(0.5)
            }
            
            // Progress value
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            // Goal and progress bar
            VStack(alignment: .leading, spacing: 4) {
                Text("of \(goal)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                ProgressView(value: min(progress, 1.0))
                    .progressViewStyle(LinearProgressViewStyle(tint: color))
                    .scaleEffect(y: 0.6)
            }
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
}

struct WorkoutCard: View {
    let workout: WorkoutItem
    
    // Water theme color for consistency
    private let primaryWater = Color(red: 0.024, green: 0.714, blue: 0.831) // Cyan/Water
    
    var body: some View {
        NavigationLink(destination: StatusWorkout()) {
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
                                Image(systemName: "clock")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(workout.duration)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            // Fire with calories - using water theme
                            HStack(spacing: 4) {
                                Image(systemName: "flame")
                                    .font(.caption)
                                    .foregroundColor(primaryWater)
                                Text(workout.calories)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        // Play button with water theme
                        Image(systemName: "play.circle.fill")
                            .font(.title2)
                            .foregroundColor(primaryWater)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
            }
            .frame(width: 180)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    NavigationView {
        VStack {
            Text("ExploreView Preview")
                .font(.title)
            Text("Services require authentication")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}
