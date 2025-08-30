import SwiftUI
import AVKit

struct WorkoutDetailView: View {
    let workout: WorkoutMainView.Workout
    @State private var isFavorite = false
    @State private var isWorkoutActive = false
    @State private var setTime: Int = 60 // seconds per set
    @State private var breakTime: Int = 30 // seconds per break
    @State private var currentSet: Int = 1
    @State private var totalSets: Int = 8
    @State private var timerActive = false
    @State private var timerType: TimerType = .set
    @State private var timeRemaining: Int = 60
    @State private var caloriesBurned: Int = 95
    @State private var totalTime: Int = 20 // minutes
    @State private var showBreak = false
    
    enum TimerType { case set, breakTime }
    
    // Exercise data
    let exercises = [
        Exercise(name: "Jumping Jacks", duration: "00:30", imageName: "jumping-jacks"),
        Exercise(name: "Squats", duration: "00:45", imageName: "squats"),
        Exercise(name: "Backward Lunge", duration: "00:30", imageName: "lunge")
    ]
    
    struct Exercise: Identifiable {
        let id = UUID()
        let name: String
        let duration: String
        let imageName: String
    }
    
    var body: some View {
        ZStack {
            // Light background instead of dark
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with back button and title
                HStack {
                    Button(action: {
                        // Back action
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.black)
                    }
                    
                    Spacer()
                    
                    Text("Workout")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    // Invisible button for balance
                    Button(action: {}) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.clear)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Main workout image/video with overlay stats
                        ZStack(alignment: .bottom) {
                            // Main workout image
                            Image(workout.imageName)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 300)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .overlay(
                                    // Dark gradient overlay
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.6)]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                )
                            
                            // Overlay stats (Time and Burn) - Centered 50-50
                            HStack(spacing: 0) {
                                // Time card
                                HStack(spacing: 8) {
                                    Image(systemName: "clock.fill")
                                        .foregroundColor(Color(red: 0.7, green: 1.0, blue: 0.3))
                                        .font(.system(size: 18, weight: .medium))
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Time")
                                            .font(.caption2)
                                            .foregroundColor(.white)
                                        Text("\(totalTime) min")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(Color.black.opacity(0.6))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                
                                Spacer().frame(width: 16) // Space between cards
                                
                                // Burn card
                                HStack(spacing: 8) {
                                    Image(systemName: "flame.fill")
                                        .foregroundColor(Color(red: 0.7, green: 1.0, blue: 0.3))
                                        .font(.system(size: 18, weight: .medium))
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Burn")
                                            .font(.caption2)
                                            .foregroundColor(.white)
                                        Text("\(caloriesBurned) kcal")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(Color.black.opacity(0.6))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                        }
                        .padding(.horizontal, 20)
                        
                        // Workout title
                        HStack {
                            Text(workout.name)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        
                        // Description
                        HStack {
                            Text("The lower abdomen and hips are the most difficult areas of the body to reduce when we are on a diet. Even so, in this area, especially the legs as a whole, you can reduce weight even if you don't use tools.")
                                .font(.body)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.leading)
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        
                        // Rounds section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Rounds")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.black)
                                Spacer()
                                Text("\(currentSet)/\(totalSets)")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal, 20)
                            
                            // Exercise list
                            VStack(spacing: 12) {
                                ForEach(Array(exercises.enumerated()), id: \.element.id) { index, exercise in
                                    HStack(spacing: 12) {
                                        // Exercise image
                                        Image(exercise.imageName)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 60, height: 60)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                        
                                        // Exercise info
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(exercise.name)
                                                .font(.headline)
                                                .foregroundColor(.black)
                                            Text(exercise.duration)
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }
                                        
                                        Spacer()
                                        
                                        // Play button
                                        Button(action: {
                                            // Start specific exercise
                                        }) {
                                            Image(systemName: "play.fill")
                                                .font(.system(size: 20))
                                                .foregroundColor(.black)
                                                .frame(width: 40, height: 40)
                                                .background(Color(red: 0.7, green: 1.0, blue: 0.3))
                                                .clipShape(Circle())
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(Color(.systemGray6))
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        Spacer(minLength: 120) // Space for the floating button
                    }
                }
                .padding(.top, 20)
            }
            
            // Floating "Lets Workout" button
            VStack {
                Spacer()
                Button(action: {
                    isWorkoutActive.toggle()
                    // SiriKit integration placeholder
                }) {
                    Text(isWorkoutActive ? "Complete Workout" : "Lets Workout")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(red: 0.7, green: 1.0, blue: 0.3))
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100) // Space for bottom navigation
            }
        }
        .navigationBarHidden(true)
        .overlay(
            VStack {
                Spacer()
                BottomNavigationBar(selectedTab: "Explore")
            }
        )
    }
    
    // Timer helpers
    func startTimer() {
        timerActive.toggle()
        // Timer logic here (can use Timer.publish)
    }
    
    func resetTimer() {
        timerActive = false
        timeRemaining = timerType == .set ? setTime : breakTime
    }
    
    func timeString(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}

struct WorkoutDetailView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutDetailView(workout: WorkoutMainView.Workout(
            name: "ABS & Cardio", category: "ABS & Cardio", level: "Professional", progress: 0.72, imageName: "abs-placeholder", accent: Color(red: 0.7, green: 1.0, blue: 0.3), status: "Active"
        ))
    }
}
