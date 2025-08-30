import SwiftUI

// Data models for workout items
struct WorkoutItem: Identifiable {
    let id = UUID()
    let title: String
    let duration: String
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
        WorkoutItem(title: "Belly fat burner", duration: "10 min", level: "Beginner", imageName: "onboarding-screen"),
        WorkoutItem(title: "Lose Fat", duration: "10 min", level: "Beginner", imageName: "onboarding-screen-2"),
        WorkoutItem(title: "Plank", duration: "5 min", level: "Expert", imageName: "onboarding-screen-3"),
        WorkoutItem(title: "Build Wide", duration: "30 min", level: "Intermediate", imageName: "challenge-image")
    ]
    
    let challenges = [
        ChallengeItem(title: "Plank", subtitle: "Challenge", color: Color(red: 0.7, green: 1.0, blue: 0.3), icon: "flame.fill"),
        ChallengeItem(title: "Sprint", subtitle: "Challenge", color: Color(red: 0.2, green: 0.2, blue: 0.3), icon: "figure.run"),
        ChallengeItem(title: "Squat", subtitle: "Challenge", color: Color(red: 0.7, green: 1.0, blue: 0.3).opacity(0.3), icon: "figure.strengthtraining.traditional")
    ]
    
    let fastWarmupWorkouts = [
        WorkoutItem(title: "Leg excercises", duration: "10 min", level: "Beginner", imageName: "onboarding-screen"),
        WorkoutItem(title: "Backward lunge", duration: "5 min", level: "Beginner", imageName: "onboarding-screen-2")
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
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
                .padding(.top, 20) // Add top padding for status bar area
                
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
                
                // Fast Warmup section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Fast Warmup")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 20)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12)
                    ], spacing: 16) {
                        ForEach(fastWarmupWorkouts) { workout in
                            WorkoutCard(workout: workout)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                Spacer(minLength: 100) // Space for bottom tab bar
            }
        }
        .background(Color(.systemBackground))
        .overlay(
            VStack {
                Spacer()
                BottomNavigationBar(selectedTab: "Explore")
            }
        )
    }
}

struct WorkoutCard: View {
    let workout: WorkoutItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Workout Image
            Image(workout.imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            VStack(alignment: .leading, spacing: 8) {
                Text(workout.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                VStack(alignment: .leading, spacing: 6) {
                    // Duration with black background
                    Text(workout.duration)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.black)
                        .cornerRadius(8)
                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                    
                    // Level with black background
                    Text(workout.level)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.black)
                        .cornerRadius(8)
                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 8)
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
