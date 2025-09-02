import SwiftUI

struct WorkoutDetailView: View {
    let workout: WorkoutMainView.Workout
    @State private var isFavorite = false
    @State private var isWorkoutActive = false
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) private var dismiss
    
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
                // Header
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .font(.title3)
                    }
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
                
                // Calories and Time info
                HStack(spacing: 20) {
                    // Calories with flame icon
                    HStack(spacing: 6) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(Color(red: 0.7, green: 1.0, blue: 0.3))
                            .font(.title3)
                        Text("245 kcal")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.6), radius: 1, x: 0, y: 1)
                    }
                    
                    // Time with clock icon
                    HStack(spacing: 6) {
                        Image(systemName: "clock.fill")
                            .foregroundColor(Color(red: 0.7, green: 1.0, blue: 0.3))
                            .font(.title3)
                        Text("25 min")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.6), radius: 1, x: 0, y: 1)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                    
                Spacer()
                
                // Bottom content
                VStack(alignment: .leading, spacing: 16) {
                    // Title with text shadow for better visibility
                    VStack(alignment: .leading, spacing: 4) {
                        Text("NO EXCUSES. START")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.7), radius: 2, x: 0, y: 1)
                        Text("NOW.")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.7), radius: 2, x: 0, y: 1)
                    }
                    
                    // Description with better contrast
                    Text("Crush your fitness goals with expert trainers and personalized workouts.")
                        .font(.callout)
                        .foregroundColor(.white) // Changed from white.opacity(0.9) to pure white
                        .shadow(color: .black.opacity(0.6), radius: 1, x: 0, y: 1)
                        .lineLimit(2)
                    
                    // Exercises
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Today's Exercises")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.7), radius: 2, x: 0, y: 1)
                        
                        ForEach(Array(exercises.enumerated()), id: \.element.id) { index, exercise in
                            HStack(spacing: 10) {
                                Text("\(index + 1)")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.black)
                                    .frame(width: 20, height: 20)
                                    .background(Color(red: 0.7, green: 1.0, blue: 0.3))
                                    .clipShape(Circle())
                                
                                VStack(alignment: .leading, spacing: 1) {
                                    Text(exercise.name)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.black)
                                    Text(exercise.duration)
                                        .font(.caption)
                                        .foregroundColor(.black.opacity(0.7))
                                }
                                
                                Spacer()
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(8)
                        }
                    }
                    
                    // Start button - simplified for Canvas testing
                    NavigationLink(destination: WorkoutExerciseView(workout: workout)) {
                        HStack {
                            Spacer()
                            Text("START WORKOUT")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                            Spacer()
                        }
                        .padding(.vertical, 14)
                        .background(Color(red: 0.7, green: 1.0, blue: 0.3))
                        .cornerRadius(12)
                    }
                    .accentColor(.clear) // Remove NavigationLink styling
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100) // Space for bottom navigation
            }
            
            // Bottom Navigation - positioned as overlay
            VStack {
                Spacer()
                BottomNavigationBar(selectedTab: "Workout")
            }
        }
        // Background approach - your preferred method with gradient overlay
        .background(
            ZStack {
                // Background image
                Image("onboarding-screen-3")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
                    .ignoresSafeArea()
                
                // Gradient overlay - dark at top, lighter at bottom
                LinearGradient(
                    colors: [
                        Color.black.opacity(0.7), // Dark at top
                        Color.black.opacity(0.4), // Medium in middle
                        Color.white.opacity(0.1)  // Very light at bottom
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
        NavigationView {
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
        .navigationViewStyle(StackNavigationViewStyle()) // Force stack style for previews
    }
}
