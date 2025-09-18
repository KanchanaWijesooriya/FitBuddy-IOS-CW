import SwiftUI

class NavigationCoordinator: ObservableObject {
    @Published var selectedTab: String = "Home"
    @Published var workoutData: [String: Any] = [:] // Store workout data for navigation
    @Published var challengeData: [String: Any] = [:] // Store challenge data
    @Published var stepData: [String: Any] = [:] // Store step data
    @Published var waterData: [String: Any] = [:] // Store water data
    @Published var shouldResetHomeNavigation: Bool = false
    @Published var shouldNavigateToWorkoutExercise: Bool = false // For Siri navigation
    
    func navigateToTab(_ tab: String) {
        if tab == "Home" && selectedTab != "Home" {
            // When switching to Home from another tab, trigger a reset
            shouldResetHomeNavigation = true
        }
        selectedTab = tab
    }
    
    func navigateToHome() {
        shouldResetHomeNavigation = true
        selectedTab = "Home"
    }
    
    func navigateToWorkoutDetail(workoutName: String, workoutData: [String: Any] = [:]) {
        self.workoutData = workoutData
        self.workoutData["workoutName"] = workoutName
        // Navigation will be handled by NavigationView within each tab
    }
    
    func navigateToWorkoutExercise(workoutName: String = "Siri Workout", exercises: [Any] = []) {
        self.workoutData["workoutName"] = workoutName
        self.workoutData["exercises"] = exercises
        // Trigger navigation to WorkoutExerciseView
        shouldNavigateToWorkoutExercise = true
        // Switch to Workout tab if not already there
        selectedTab = "Workout"
        print("🏃‍♂️ Navigation triggered to WorkoutExerciseView with workout: \(workoutName)")
    }
    
    func navigateToStepTracker() {
        // Navigation will be handled by NavigationView within each tab
    }
    
    func navigateToWaterSelection() {
        // Navigation will be handled by NavigationView within each tab
    }
    
    func navigateToChallengeDetail(challengeId: String, challengeData: [String: Any] = [:]) {
        self.challengeData = challengeData
        self.challengeData["challengeId"] = challengeId
        // Navigation will be handled by NavigationView within each tab
    }
    
    func navigateToStatusDetail(type: String) {
        // Navigation will be handled by NavigationView within each tab
    }
    
    func goBack() {
        // Navigation back will be handled by NavigationView's built-in back functionality
    }
}
