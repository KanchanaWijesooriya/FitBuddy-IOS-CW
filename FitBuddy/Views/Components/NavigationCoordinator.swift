import SwiftUI

class NavigationCoordinator: ObservableObject {
    @Published var selectedTab: String = "Home"
    @Published var navigationStack: [String] = []
    @Published var workoutData: [String: Any] = [:] // Store workout data for navigation
    @Published var challengeData: [String: Any] = [:] // Store challenge data
    @Published var stepData: [String: Any] = [:] // Store step data
    @Published var waterData: [String: Any] = [:] // Store water data
    
    func navigateToTab(_ tab: String) {
        selectedTab = tab
        navigationStack = [tab] // Reset stack when navigating via tab
    }
    
    func navigateToView(_ viewName: String) {
        // Add to navigation stack for proper back navigation
        navigationStack.append(viewName)
    }
    
    func navigateToWorkoutDetail(workoutName: String, workoutData: [String: Any] = [:]) {
        self.workoutData = workoutData
        self.workoutData["workoutName"] = workoutName
        navigateToView("WorkoutDetailView")
    }
    
    func navigateToWorkoutExercise(workoutName: String, exercises: [Any] = []) {
        self.workoutData["workoutName"] = workoutName
        self.workoutData["exercises"] = exercises
        navigateToView("WorkoutExerciseView")
    }
    
    func navigateToStepTracker() {
        navigateToView("StepTrackerView")
    }
    
    func navigateToWaterSelection() {
        navigateToView("WaterGlassSelectionView")
    }
    
    func navigateToChallengeDetail(challengeId: String, challengeData: [String: Any] = [:]) {
        self.challengeData = challengeData
        self.challengeData["challengeId"] = challengeId
        navigateToView("ChallengeDetailView")
    }
    
    func navigateToStatusDetail(type: String) {
        switch type {
        case "workout":
            navigateToView("StatusWorkout")
        case "steps":
            navigateToView("StatusStep")
        case "water":
            navigateToView("StatusWater")
        default:
            break
        }
    }
    
    func goBack() {
        if navigationStack.count > 1 {
            navigationStack.removeLast()
            // Update selected tab based on current view after going back
            if let currentView = navigationStack.last {
                updateSelectedTabForView(currentView)
            }
        } else if navigationStack.count == 1 {
            // If we're on a tab root, stay on that tab
            let currentTab = navigationStack.first ?? selectedTab
            selectedTab = currentTab
        }
    }
    
    private func updateSelectedTabForView(_ viewName: String) {
        switch viewName {
        case "Home", "ExploreView":
            selectedTab = "Home"
        case "Workout", "WorkoutMainView", "WorkoutDetailView", "WorkoutExerciseView":
            selectedTab = "Workout"
        case "Status", "StatusOverview", "StatusWorkout", "StatusStep", "StatusWater":
            selectedTab = "Status"
        case "Profile", "ProfileSettingsView":
            selectedTab = "Profile"
        case "StepTrackerView":
            selectedTab = "Home" // Step tracker accessible from Home
        case "WaterGlassSelectionView":
            selectedTab = "Home" // Water tracker accessible from Home
        case "ChallengeDetailView", "ChallengeMainView":
            selectedTab = "Home" // Challenges accessible from Home
        default:
            selectedTab = "" // No selection for other views
        }
    }
    
    var currentView: String {
        return navigationStack.last ?? selectedTab
    }
    
    var isOnMainTab: Bool {
        return navigationStack.isEmpty || navigationStack.count == 1
    }
}
