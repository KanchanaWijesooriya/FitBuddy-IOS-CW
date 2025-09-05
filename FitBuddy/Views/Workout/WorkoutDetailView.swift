import SwiftUI

struct WorkoutDetailView: View {
    let workout: WorkoutMainView.Workout
    @State private var isFavorite = false
    @State private var isWorkoutActive = false
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) private var dismiss
    
    // App theme colors - matching the common theme
    private let primaryAccent = Color(red: 0.7, green: 1.0, blue: 0.3) // Main theme green
    
    let exercises = [
        Exercise(name: "Barbell training", duration: "06:10"),
        Exercise(name: "Kettlebell training", duration: "07:12"),
        Exercise(name: "Shoulder press", duration: "05:30")
    ]
    
    struct Exercise: Identifiable {
        let id = UUID()
        let name: String
        let duration: String
    }
    
    var body: some View {
        ZStack {
            // Main content
            VStack(spacing: 0) {
                // Header with BackButton component
                HStack {
                    BackButton()
                    Spacer()
                    
                    Button(action: { isFavorite.toggle() }) {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .foregroundColor(.white)
                            .font(.title3)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                // Workout Title - Apple standard heading
                Text(workout.name)
                    .font(.largeTitle) // Apple standard heading 1
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.8), radius: 3, x: 0, y: 2)
                    .padding(.top, 20)
                    .padding(.horizontal, 20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Calories and Time info - enhanced with theme colors
                HStack(spacing: 20) {
                    // Calories with flame icon
                    HStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(primaryAccent.opacity(0.2))
                                .frame(width: 32, height: 32)
                            
                            Image(systemName: "flame.fill")
                                .foregroundColor(primaryAccent)
                                .font(.title3)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("245 kcal")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.6), radius: 1, x: 0, y: 1)
                            
                            Text("Calories")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.8))
                                .shadow(color: .black.opacity(0.6), radius: 1, x: 0, y: 1)
                        }
                    }
                    
                    // Time with clock icon
                    HStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(Color.blue.opacity(0.2))
                                .frame(width: 32, height: 32)
                            
                            Image(systemName: "clock.fill")
                                .foregroundColor(Color.blue)
                                .font(.title3)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("25 min")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.6), radius: 1, x: 0, y: 1)
                            
                            Text("Duration")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.8))
                                .shadow(color: .black.opacity(0.6), radius: 1, x: 0, y: 1)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                    
                Spacer()
                
                // Bottom content with enhanced card design
                VStack(alignment: .leading, spacing: 20) {
                    // Enhanced motivational section
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Text("NO EXCUSES. START")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.7), radius: 2, x: 0, y: 1)
                            
                            // Animated motivation icon
                            Image(systemName: "bolt.fill")
                                .font(.title3)
                                .foregroundColor(primaryAccent)
                                .scaleEffect(1.2)
                                .animation(
                                    Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                                    value: isFavorite
                                )
                        }
                        
                        Text("NOW.")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.7), radius: 2, x: 0, y: 1)
                    }
                    
                    // Description with better styling
                    Text("Crush your fitness goals with expert trainers and personalized workouts.")
                        .font(.callout)
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.6), radius: 1, x: 0, y: 1)
                        .lineLimit(2)
                        .padding(.bottom, 8)
                    
                    // Enhanced Exercises section with card design
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Text("Today's Exercises")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.7), radius: 2, x: 0, y: 1)
                            
                            Image(systemName: "list.bullet.circle.fill")
                                .font(.title3)
                                .foregroundColor(primaryAccent)
                        }
                        
                        // Exercise cards with enhanced design
                        ForEach(Array(exercises.enumerated()), id: \.element.id) { index, exercise in
                            HStack(spacing: 12) {
                                // Enhanced number badge
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    primaryAccent,
                                                    primaryAccent.opacity(0.8)
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 28, height: 28)
                                        .shadow(color: primaryAccent.opacity(0.3), radius: 4, x: 0, y: 2)
                                    
                                    Text("\(index + 1)")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.black)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(exercise.name)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.primary)
                                    Text(exercise.duration)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .fontWeight(.medium)
                                }
                                
                                Spacer()
                                
                                // Exercise status icon
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title3)
                                    .foregroundColor(primaryAccent.opacity(0.7))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.95))
                                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                            )
                        }
                    }
                    
                    // Enhanced Start button with gradient design
                    NavigationLink(destination: WorkoutExerciseView(workout: workout)) {
                        HStack(spacing: 12) {
                            Image(systemName: "play.fill")
                                .font(.title3)
                                .foregroundColor(.black)
                            
                            Text("START WORKOUT")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            Image(systemName: "arrow.right")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                        }
                        .padding(.vertical, 16)
                        .padding(.horizontal, 20)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    primaryAccent,
                                    primaryAccent.opacity(0.8)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: primaryAccent.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .accentColor(.clear)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30) // Reduced space for better layout
            }
        }
        // Enhanced background with better gradient
        .background(
            ZStack {
                // Background image
                Image("onboarding-screen-3")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
                    .ignoresSafeArea()
                
                // Enhanced gradient overlay with theme colors
                LinearGradient(
                    colors: [
                        Color.black.opacity(0.8), // Darker at top for better text contrast
                        Color.black.opacity(0.5), // Medium in middle
                        Color.black.opacity(0.3), // Lighter at bottom
                        primaryAccent.opacity(0.1)  // Subtle theme color at bottom
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            }
        )
        .navigationBarHidden(true)
    }
}


struct WorkoutDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            WorkoutDetailView(workout: WorkoutMainView.Workout(
                name: "ABS & Cardio", 
                category: "ABS & Cardio", 
                level: "Professional", 
                progress: 0.72, 
                imageName: "abs-placeholder", 
                accent: Color(red: 0.7, green: 1.0, blue: 0.3), 
                status: "Active"
            ))
        }
    }
}
