import SwiftUI
import AVKit

struct WorkoutDetailView: View {
    let workout: WorkoutMainView.Workout
    @State private var isFavorite = false
    @State private var isWorkoutActive = false
    @State private var setTime: Int = 60 // seconds per set
    @State private var breakTime: Int = 30 // seconds per break
    @State private var currentSet: Int = 1
    @State private var timerActive = false
    @State private var timerType: TimerType = .set
    @State private var timeRemaining: Int = 60
    @State private var caloriesBurned: Int = 0
    @State private var showBreak = false
    
    enum TimerType { case set, breakTime }
    
    // Example data for demo
    let description = "This workout targets your core and cardiovascular system. Improve your strength, endurance, and burn calories with a mix of abs and cardio exercises."
    let equipments = ["Yoga Mat", "Dumbbells", "Water Bottle"]
    let sets = 3
    let reps = 15
    let difficulty = "Intermediate"
    let videoURL = URL(string: "https://www.apple.com/105/media/us/apple-fitness-plus/2022/7b7e2e7c-2e2c-4e2e-8e2e-7e2e2e2e2e2e/anim/fitnessplus-hero.mp4")
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Video or Image
                if let url = videoURL {
                    VideoPlayer(player: AVPlayer(url: url))
                        .frame(height: 220)
                        .cornerRadius(24)
                        .shadow(radius: 8)
                } else {
                    Image(workout.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 220)
                        .cornerRadius(24)
                        .shadow(radius: 8)
                }
                // Title & Favorite
                HStack {
                    Text(workout.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    Spacer()
                    Button(action: { isFavorite.toggle() }) {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .foregroundColor(isFavorite ? .red : .gray)
                            .font(.title2)
                    }
                }
                // Description
                Text(description)
                    .font(.body)
                    .foregroundColor(.gray)
                    .lineLimit(4)
                // Equipments
                HStack {
                    Image(systemName: "hammer.fill")
                        .foregroundColor(.accentColor)
                    Text("Equipments: ")
                        .fontWeight(.semibold)
                    ForEach(equipments, id: \.self) { eq in
                        Text(eq)
                            .font(.caption)
                            .padding(6)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                }
                // Sets & Reps & Difficulty
                HStack(spacing: 16) {
                    Label("Sets: \(sets)", systemImage: "repeat")
                        .foregroundColor(.accentColor)
                    Label("Reps: \(reps)", systemImage: "number")
                        .foregroundColor(.accentColor)
                    Label("Difficulty: \(difficulty)", systemImage: "flame")
                        .foregroundColor(.orange)
                }
                // Calories Burned
                HStack {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.red)
                    Text("Calories Burned: \(caloriesBurned)")
                        .font(.headline)
                }
                // Timer Section
                VStack(spacing: 12) {
                    Text(timerType == .set ? "Set \(currentSet) Timer" : "Break Timer")
                        .font(.headline)
                    Text("\(timeString(timeRemaining))")
                        .font(.system(size: 36, weight: .bold, design: .monospaced))
                        .foregroundColor(timerType == .set ? .accentColor : .orange)
                    HStack(spacing: 24) {
                        Button(action: startTimer) {
                            Label(timerActive ? "Pause" : "Start", systemImage: timerActive ? "pause.fill" : "play.fill")
                                .font(.title2)
                                .padding()
                                .background(Color.accentColor.opacity(0.2))
                                .cornerRadius(12)
                        }
                        Button(action: resetTimer) {
                            Label("Reset", systemImage: "arrow.counterclockwise")
                                .font(.title2)
                                .padding()
                                .background(Color(.systemGray5))
                                .cornerRadius(12)
                        }
                    }
                }
                // Start/Complete Workout Button
                Button(action: { isWorkoutActive.toggle() }) {
                    Text(isWorkoutActive ? "Complete Workout" : "Start Workout with Siri")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isWorkoutActive ? Color.green : Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                }
                .padding(.top, 8)
                // Schedule Button
                Button(action: {}) {
                    Label("Add to Schedule", systemImage: "calendar")
                        .font(.subheadline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray6))
                        .foregroundColor(.accentColor)
                        .cornerRadius(16)
                }
            }
            .padding(24)
        }
        .navigationTitle("Workout Details")
        .navigationBarTitleDisplayMode(.inline)
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
