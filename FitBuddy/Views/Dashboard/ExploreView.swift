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

struct ChallengeItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let color: Color
    let icon: String
}

struct ExploreView: View {
    @State private var searchText = ""
    
    // Sample data matching the image
    let bestForYouWorkouts = [
        WorkoutItem(title: "Belly fat burner", duration: "10 min", calories: "300 Cal", level: "Beginner", imageName: "onboarding-screen"),
        WorkoutItem(title: "Lose Fat", duration: "15 min", calories: "250 Cal", level: "Beginner", imageName: "onboarding-screen-2"),
        WorkoutItem(title: "Plank", duration: "5 min", calories: "150 Cal", level: "Expert", imageName: "onboarding-screen-3"),
        WorkoutItem(title: "Build Wide", duration: "30 min", calories: "450 Cal", level: "Intermediate", imageName: "challenge-image")
    ]
    
    let challenges = [
        ChallengeItem(title: "Plank", subtitle: "Challenge", color: Color(red: 0.7, green: 1.0, blue: 0.3), icon: "flame.fill"),
        ChallengeItem(title: "Sprint", subtitle: "Challenge", color: Color(red: 0.2, green: 0.2, blue: 0.3), icon: "figure.run"),
        ChallengeItem(title: "Squat", subtitle: "Challenge", color: Color(red: 0.7, green: 1.0, blue: 0.3).opacity(0.3), icon: "figure.strengthtraining.traditional")
    ]
    
    var body: some View {
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
                            
                            // User Name with header 2 font
                            Text("Chanuka Wijesooriya")
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
                    
                    // Modern Search Bar
                    HStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                            .font(.body)
                        
                        TextField("Search workouts, exercises...", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                            .font(.body)
                        
                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
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
                .padding(.horizontal, 20)
                .padding(.top, 8)
                
                // Featured Workout Card
                ZStack {
                    // Background Image covering the whole card
                    Image("onboarding-screen-3")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    
                    // Gradient Overlay
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.black.opacity(0.6),
                                    Color.black.opacity(0.3),
                                    Color.clear
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 200)
                    
                    // Content overlay
                    HStack {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Best Quarantine\nWorkout")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)
                            
                            Button(action: {
                                // See more action
                            }) {
                                Text("See more")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(Color(red: 0.7, green: 1.0, blue: 0.3))
                            }
                            
                            Spacer()
                        }
                        .padding(.leading, 24)
                        .padding(.top, 24)
                        
                        Spacer()
                    }
                }
                .padding(.horizontal, 20)
                
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
                
                // Challenge section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Challenge")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 20)
                    
                    HStack(spacing: 8) {
                        ForEach(challenges) { challenge in
                            ChallengeCard(challenge: challenge)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                // Status Progress section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Your Status")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 20)
                    
                    // Long Status Card
                    HStack(spacing: 20) {
                        // Icon section
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.2))
                                .frame(width: 60, height: 60)
                            
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                        
                        // Content section
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Weekly Progress")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Text("5/7 days")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                            }
                            
                            Text("You're on track to reach your goal")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.9))
                                .lineLimit(2)
                            
                            // Progress bar
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.white.opacity(0.3))
                                    .frame(height: 8)
                                
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.white)
                                    .frame(width: CGFloat(0.71) * 200, height: 8)
                            }
                            .frame(width: 200)
                        }
                        
                        Spacer()
                    }
                    .padding(20)
                    .background(
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: Color(red: 0.4, green: 0.7, blue: 0.2), location: 0.0),
                                .init(color: Color(red: 0.3, green: 0.6, blue: 0.15), location: 0.7),
                                .init(color: Color(red: 0.25, green: 0.5, blue: 0.1), location: 1.0)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(20)
                    .shadow(color: Color(red: 0.4, green: 0.7, blue: 0.2).opacity(0.4), radius: 12, x: 0, y: 6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.white.opacity(0.3),
                                        Color.clear
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .padding(.horizontal, 20)
                }
                
                Spacer(minLength: 100) // Space for bottom tab bar
            }
        }
        .background(Color(.systemBackground))
        .overlay(
            VStack {
                Spacer()
                BottomNavigationBar(selectedTab: "Home")
            }
        )
    }
}

struct WorkoutCard: View {
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

struct ChallengeCard: View {
    let challenge: ChallengeItem
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: challenge.icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
            
            VStack(spacing: 2) {
                Text(challenge.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text(challenge.subtitle)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .frame(height: 120)
        .frame(maxWidth: .infinity)
        .background(challenge.color)
        .cornerRadius(16)
    }
}

#Preview {
    ExploreView()
}
