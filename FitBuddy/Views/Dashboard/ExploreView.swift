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
    @EnvironmentObject var siriService: SimpleSiriService
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var stepService: StepService
    @EnvironmentObject var waterService: WaterService
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    
    private let primaryWater = Color(red: 0.024, green: 0.714, blue: 0.831) // Cyan/Water
    private let primaryPurple = Color(red: 0.588, green: 0.239, blue: 0.729) // Purple
    private let redGradient = Color(red: 0.906, green: 0.298, blue: 0.235) // Red for workout
    
    private let yellowOrangeMix = Color(red: 1.0, green: 0.6, blue: 0.0) // Yellow-Orange mix
    
    private func formatWorkoutTime(minutes: Int) -> String {
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        return "\(hours)hr \(remainingMinutes)min"
    }
    
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
                let components = email.components(separatedBy: "@")
                if let username = components.first {
                    return username.capitalized
                }
            }
        }
        return "User"
    }
    
    private func navigateToWorkout(for recommendation: WorkoutRecommendationService.WorkoutRecommendation) {
        navigationCoordinator.navigateToWorkoutDetail(workoutName: recommendation.name, workoutData: [
            "type": recommendation.type,
            "level": recommendation.level,
            "description": recommendation.description
        ])
    }
    
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
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 6) {
                            Text("Good Morning")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text("")
                                .font(.subheadline)
                        }
                        
                        Text(displayName)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .padding(.top, 2)
                        
                        Text("Explore")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .padding(.top, 4)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        Button(action: {
                            siriService.startVoiceInteraction()
                        }) {
                            ZStack {
                                Circle()
                                    .fill(siriService.isListening ? 
                                          primaryPurple : primaryPurple.opacity(0.1))
                                    .frame(width: 45, height: 45)
                                
                                Image(systemName: siriService.isListening ? "mic.fill" : "mic")
                                    .font(.system(size: 20))
                                    .foregroundColor(siriService.isListening ? .white : primaryPurple)
                            }
                        }
                        .scaleEffect(siriService.isListening ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: siriService.isListening)
                        
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
                }
                
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
            
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Text("Today's Progress")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        
                        VStack(spacing: 20) {
                            HStack(spacing: 16) {
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
                            
                            NavigationLink(destination: StatusWorkout()) {
                                WorkoutTimeCard(
                                    title: "Workout",
                                    workoutMinutes: 85, // Changed from 25 to 85 minutes to show "1hr 25min"
                                    goal: 60,
                                    icon: "figure.strengthtraining.traditional",
                                    color: redGradient,
                                    progress: 85.0 / 60.0 // Updated progress calculation
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Featured Workout")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal, 20)
                        
                        Button(action: {
                            navigationCoordinator.navigateToTab("Workout")
                        }) {
                            ZStack(alignment: .bottomLeading) {
                                Image("challenge-image")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 200)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                
                                LinearGradient(
                                    colors: [Color.clear, Color.black.opacity(0.7)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                
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
                    
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Best For You")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        
                        if recommendationService.recommendations.isEmpty {
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
                        
                        VStack(spacing: 12) {
                            weeklyChallengeCard
                            dailyChallengeCard
                        }
                        .padding(.horizontal, 20)
                    }
                    
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
                .padding(.top, 24)
                .padding(.bottom, 16)
            }
            
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
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    
                    Button(action: {
                        handleSiriButtonTap()
                    }) {
                        Image(systemName: siriService.isListening ? "waveform.circle.fill" : "mic.circle.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .background(
                                Circle()
                                    .fill(siriService.isListening ? 
                                         LinearGradient(gradient: Gradient(colors: [Color.purple, Color.blue]), 
                                                       startPoint: .topLeading, endPoint: .bottomTrailing) :
                                         LinearGradient(gradient: Gradient(colors: [primaryPurple, primaryWater]), 
                                                       startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .shadow(color: primaryPurple.opacity(0.3), radius: 8, x: 0, y: 4)
                            )
                    }
                    .padding(.trailing, 10)
                    .padding(.bottom, 100) // Account for tab bar
                    
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
            siriService.onNavigateToProfile = {
                navigationCoordinator.navigateToTab("Profile")
            }
            
            siriService.onNavigateToWorkout = {
                navigationCoordinator.navigateToTab("Workouts")
            }
            
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
    
    private func handleSiriButtonTap() {
        // Check if speech functionality is available
        if siriService.canUseSpeech {
            // Start voice interaction
            siriService.startVoiceInteraction()
        } else {
            // Speech not available, show message
            print("Speech functionality not available. Please enable microphone and speech recognition in Settings.")
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
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
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

struct WorkoutTimeCard: View {
    let title: String
    let workoutMinutes: Int
    let goal: Int
    let icon: String
    let color: Color
    let progress: Double
    
    // Format workout time as "Xhr Ymin"
    private var formattedTime: String {
        let hours = workoutMinutes / 60
        let remainingMinutes = workoutMinutes % 60
        return "\(hours)hr \(remainingMinutes)min"
    }
    
    // Create gradient variations based on the primary color
    private var gradientColors: [Color] {
        return [
            color,
            color.opacity(0.8),
            color.opacity(0.9)
        ]
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: gradientColors),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
            
            VStack(alignment: .leading, spacing: 12) {
                // Top section with icon
                HStack {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.35))
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: icon)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
                    }
                    
                    Spacer()
                }
                
                // Main time value in "Xhr Ymin" format
                Text(formattedTime)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 1)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.white)
                    .fontWeight(.bold)
                    .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 1)
            }
            .padding(16)
        }
        .frame(height: 120)
        .frame(maxWidth: .infinity)
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
