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
    @StateObject private var recommendationService = WorkoutRecommendationService()
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
    
    // Sample data matching the image - Enhanced with more workouts for better search
    let bestForYouWorkouts = [
        WorkoutItem(title: "Belly fat burner", duration: "10 min", calories: "300 Cal", level: "Beginner", imageName: "onboarding-screen"),
        WorkoutItem(title: "Lose Fat", duration: "15 min", calories: "250 Cal", level: "Beginner", imageName: "onboarding-screen-2"),
        WorkoutItem(title: "Plank", duration: "5 min", calories: "150 Cal", level: "Expert", imageName: "onboarding-screen-3"),
        WorkoutItem(title: "Build Wide", duration: "30 min", calories: "450 Cal", level: "Intermediate", imageName: "challenge-image"),
        WorkoutItem(title: "HIIT Training", duration: "20 min", calories: "400 Cal", level: "Intermediate", imageName: "onboarding-screen"),
        WorkoutItem(title: "Push ups Challenge", duration: "8 min", calories: "180 Cal", level: "Beginner", imageName: "onboarding-screen-2"),
        WorkoutItem(title: "Cardio Blast", duration: "25 min", calories: "350 Cal", level: "Advanced", imageName: "onboarding-screen-3"),
        WorkoutItem(title: "Abs Workout", duration: "12 min", calories: "200 Cal", level: "Intermediate", imageName: "challenge-image"),
        WorkoutItem(title: "Yoga Flow", duration: "40 min", calories: "220 Cal", level: "Beginner", imageName: "onboarding-screen"),
        WorkoutItem(title: "Strength Training", duration: "35 min", calories: "380 Cal", level: "Advanced", imageName: "onboarding-screen-2"),
        WorkoutItem(title: "Quick Burn", duration: "7 min", calories: "120 Cal", level: "Beginner", imageName: "onboarding-screen-3"),
        WorkoutItem(title: "Full Body", duration: "45 min", calories: "500 Cal", level: "Expert", imageName: "challenge-image")
    ]
    
    // Search suggestions - Enhanced for better workout discovery
    let searchSuggestions = [
        SearchSuggestion(title: "Push ups", category: "Strength"),
        SearchSuggestion(title: "Cardio workout", category: "Cardio"),
        SearchSuggestion(title: "Yoga", category: "Flexibility"),
        SearchSuggestion(title: "Weight loss", category: "Goal"),
        SearchSuggestion(title: "Abs workout", category: "Core"),
        SearchSuggestion(title: "Running", category: "Cardio"),
        SearchSuggestion(title: "Strength training", category: "Strength"),
        SearchSuggestion(title: "HIIT", category: "High Intensity"),
        SearchSuggestion(title: "Beginner", category: "Level"),
        SearchSuggestion(title: "Belly fat burner", category: "Fat Loss"),
        SearchSuggestion(title: "Plank", category: "Core"),
        SearchSuggestion(title: "Squats", category: "Lower Body"),
        SearchSuggestion(title: "Upper body", category: "Strength"),
        SearchSuggestion(title: "Full body", category: "Total Body"),
        SearchSuggestion(title: "Quick workout", category: "Duration")
    ]
    
    var filteredSuggestions: [SearchSuggestion] {
        if searchText.isEmpty {
            return []
        }
        return searchSuggestions.filter { suggestion in
            suggestion.title.localizedCaseInsensitiveContains(searchText) ||
            suggestion.category.localizedCaseInsensitiveContains(searchText)
        }.prefix(6).map { $0 }
    }
    
    var filteredWorkouts: [WorkoutItem] {
        if searchText.isEmpty {
            return bestForYouWorkouts
        }
        return bestForYouWorkouts.filter { workout in
            workout.title.localizedCaseInsensitiveContains(searchText) ||
            workout.level.localizedCaseInsensitiveContains(searchText) ||
            workout.duration.localizedCaseInsensitiveContains(searchText)
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
    
    // MARK: - Navigation Functions
    private func navigateToWorkout(for recommendation: WorkoutRecommendationService.WorkoutRecommendation) {
        // Navigation will be handled by NavigationLink in the card itself
        navigationCoordinator.navigateToWorkoutDetail(workoutName: recommendation.name, workoutData: [
            "type": recommendation.type,
            "level": recommendation.level,
            "description": recommendation.description
        ])
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
                    
                    // Best For You Section - ML Recommendations (exactly 3)
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Best For You")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        
                        // Show exactly 3 ML recommendations using original theme
                        if recommendationService.recommendations.isEmpty {
                            // Loading state
                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHStack(spacing: 16) {
                                    ForEach(0..<3, id: \.self) { _ in
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.secondary.opacity(0.2))
                                            .frame(width: 180, height: 200)
                                            .redacted(reason: .placeholder)
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHStack(spacing: 16) {
                                    ForEach(Array(recommendationService.recommendations.prefix(3))) { recommendation in
                                        MLWorkoutCard(recommendation: recommendation)
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        
                        // Fallback to regular workouts if search is active
                        if !searchText.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHStack(spacing: 16) {
                                    ForEach(filteredWorkouts.prefix(6)) { workout in
                                        WorkoutCard(workout: workout)
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        
                        // Show message when no workouts match search
                        if !searchText.isEmpty && filteredWorkouts.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 32))
                                    .foregroundColor(.secondary)
                                
                                Text("No workouts found")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text("Try adjusting your search terms")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 40)
                            .frame(maxWidth: .infinity)
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
            if showSearchSuggestions && !filteredSuggestions.isEmpty {
                VStack {
                    Spacer()
                        .frame(height: 180) // Account for fixed header height
                    
                    VStack(spacing: 0) {
                        ForEach(filteredSuggestions) { suggestion in
                            Button(action: {
                                searchText = suggestion.title
                                showSearchSuggestions = false
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "magnifyingglass")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(suggestion.title)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(.primary)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        Text(suggestion.category)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "arrow.up.left")
                                        .font(.caption)
                                        .foregroundColor(.waterBlue)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color.adaptiveCardBackground)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            if suggestion.id != filteredSuggestions.last?.id {
                                Divider()
                                    .padding(.horizontal, 16)
                            }
                        }
                        
                        Divider()
                            .padding(.horizontal, 16)
                        
                        Button(action: {
                            showSearchSuggestions = false
                            searchText = ""
                        }) {
                            HStack {
                                Image(systemName: "xmark.circle")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text("Cancel")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.adaptiveCardBackground)
                            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                    )
                    .padding(.horizontal, 20)
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
            
            // Load ML workout recommendations
            recommendationService.getBestWorkoutsForUser()
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

// MARK: - ML Workout Card (using original Best for You theme)
struct MLWorkoutCard: View {
    let recommendation: WorkoutRecommendationService.WorkoutRecommendation
    private let primaryWater = Color(red: 0.024, green: 0.714, blue: 0.831) // Cyan/Water
    
    var body: some View {
        NavigationLink(destination: WorkoutMainView().environmentObject(NavigationCoordinator())) {
            VStack(alignment: .leading, spacing: 0) {
                // Image section with confidence badge
                ZStack(alignment: .topTrailing) {
                    Image(recommendation.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 120)
                        .clipped()
                        .cornerRadius(12, corners: [.topLeft, .topRight])
                    
                    // Confidence badge (star rating)
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundColor(.white)
                        
                        Text("\(Int(recommendation.confidence * 100))%")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.black.opacity(0.7))
                    )
                    .padding(8)
                }
                
                // Content section (matching original WorkoutCard style)
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(recommendation.name)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                                .lineLimit(1)
                            
                            Text(recommendation.level)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(primaryWater)
                        }
                        
                        Spacer()
                        
                        // Play button with water theme
                        Image(systemName: "play.circle.fill")
                            .font(.title2)
                            .foregroundColor(primaryWater)
                    }
                    
                    // Description
                    Text(recommendation.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
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

// MARK: - Corner Radius Extension
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
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
