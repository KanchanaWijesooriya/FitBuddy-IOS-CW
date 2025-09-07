import SwiftUI

struct WorkoutDetailView: View {
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    @State private var isFavorite = false
    @State private var isWorkoutActive = false
    @State private var showExerciseCard = false
    @Environment(\.dismiss) private var dismiss
    
    // Apple Blue theme
    private let primaryAccent = Color(red: 0.0, green: 0.478, blue: 1.0) // Apple system blue
    private let accentGradient = LinearGradient(
        gradient: Gradient(colors: [Color(red: 0.0, green: 0.478, blue: 1.0), Color.blue.opacity(0.7)]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Get workout data from NavigationCoordinator
    private var workoutName: String {
        return navigationCoordinator.workoutData["workoutName"] as? String ?? "Workout"
    }
    
    private var workoutLevel: String {
        return navigationCoordinator.workoutData["level"] as? String ?? "Beginner"
    }
    
    private var workoutProgress: Double {
        return navigationCoordinator.workoutData["progress"] as? Double ?? 0.0
    }
    
    private var workoutImageName: String {
        return navigationCoordinator.workoutData["imageName"] as? String ?? "abs-placeholder"
    }
    
    private var workoutCategory: String {
        return navigationCoordinator.workoutData["category"] as? String ?? "General"
    }
    
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
    
    // MARK: - Background View
    private var backgroundView: some View {
        GeometryReader { geometry in
            Image("onboarding-screen-3")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: geometry.size.width, height: geometry.size.height)
                .clipped()
                .overlay(backgroundGradient)
        }
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.black.opacity(0.7),
                Color.black.opacity(0.3),
                Color.black.opacity(0.8)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack {
            BackButton()
            Spacer()
            Button(action: { 
                isFavorite.toggle() 
            }) {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .foregroundColor(.white)
                    .font(.title2)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 50)
    }
    
    // MARK: - Hero Section
    private var heroSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(workoutName)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
            
            metricsRow
        }
        .padding(.horizontal, 20)
        .padding(.top, 30)
    }
    
    private var metricsRow: some View {
        HStack(spacing: 24) {
            HStack(spacing: 6) {
                Image(systemName: "flame.fill")
                    .foregroundColor(primaryAccent)
                    .font(.title3)
                    .font(.caption)
                    .foregroundColor(.white)
                Text("245 kcal")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            HStack(spacing: 6) {
                Image(systemName: "clock.fill")
                    .foregroundColor(primaryAccent)
                    .font(.title3)
                    .font(.caption)
                    .foregroundColor(.white)
                Text("25 time")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Center Section
    private var centerSection: some View {
        VStack {
            Text("Ready to Push Your Limits?")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)
            
            startNowButton
        }
    }
    
    private var startNowButton: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.6)) {
                showExerciseCard = true
            }
        }) {
            Text("Start Now")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .padding(.horizontal, 60)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [primaryAccent, primaryAccent.opacity(0.8)]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(25)
                .shadow(color: primaryAccent.opacity(0.4), radius: 8, x: 0, y: 4)
        }
        .padding(.top, 20)
        .padding(.horizontal, 40)
    }
    
    // MARK: - Exercise Card View
    private var exerciseCardView: some View {
        VStack(spacing: 0) {
            // Drag indicator
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 5)
                .padding(.top, 8)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    descriptionSection
                    exercisesSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 30)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .ignoresSafeArea(.container, edges: .bottom)
        )
        .frame(maxHeight: .infinity)
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .gesture(swipeDownGesture)
    }
    
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Transform Your Body")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text("Scientifically designed workouts that deliver real results with expert guidance. Our comprehensive training programs are crafted by certified fitness professionals to help you achieve your fitness goals effectively and safely.")
                .font(.body)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    private var exercisesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            exerciseHeader
            exerciseList
            
            // Move the Begin Workout button here, right after exercises
            finalStartButton
        }
    }
    
    private var exerciseHeader: some View {
        HStack(spacing: 8) {
            Text("Today's Exercises")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Image(systemName: "list.bullet.circle.fill")
                .font(.title3)
                .foregroundColor(primaryAccent)
            
            Spacer()
            
            Text("\(exercises.count) exercises")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var exerciseList: some View {
        VStack(spacing: 8) {
            ForEach(Array(exercises.enumerated()), id: \.element.id) { index, exercise in
                exerciseRow(index: index, exercise: exercise)
            }
        }
    }
    
    private func exerciseRow(index: Int, exercise: Exercise) -> some View {
        HStack(spacing: 12) {
            // Number badge
            ZStack {
                Circle()
                    .fill(primaryAccent)
                    .frame(width: 24, height: 24)
                
                Text("\(index + 1)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            // Exercise info
            VStack(alignment: .leading, spacing: 2) {
                Text(exercise.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(exercise.duration)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Status icon
            Image(systemName: "play.circle")
                .font(.title3)
                .foregroundColor(primaryAccent.opacity(0.6))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray6))
        )
    }
    
    private var finalStartButton: some View {
        Button(action: {
            navigationCoordinator.navigateToWorkoutExercise(
                workoutName: workoutName,
                exercises: exercises.map { ["name": $0.name, "duration": $0.duration] }
            )
        }) {
            HStack(spacing: 12) {
                Image(systemName: "play.fill")
                    .font(.title3)
                    .foregroundColor(.white)
                
                Text("Begin Workout")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "arrow.right")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [primaryAccent, primaryAccent.opacity(0.8)]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
        }
    }
    
    private var swipeDownGesture: some Gesture {
        DragGesture()
            .onEnded { value in
                // If user swipes down more than 100 points, hide the card
                if value.translation.height > 100 {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        showExerciseCard = false
                    }
                }
            }
    }

    var body: some View {
        ZStack {
            backgroundView
            
            VStack(spacing: 0) {
                headerView
                heroSection
                Spacer()
                
                // Only show center section when exercise card is NOT visible
                if !showExerciseCard {
                    centerSection
                    Spacer()
                }
                
                if showExerciseCard {
                    exerciseCardView
                }
            }
        }
        .ignoresSafeArea()
        .navigationBarHidden(true)
    }
}


struct WorkoutDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            WorkoutDetailView()
                .environmentObject(NavigationCoordinator())
        }
    }
}
