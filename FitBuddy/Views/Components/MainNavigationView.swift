import SwiftUI

struct MainNavigationView: View {
    @StateObject private var navigationCoordinator = NavigationCoordinator()
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var stepService: StepService
    @EnvironmentObject var waterService: WaterService
    
    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottom) {
                getCurrentView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemBackground))
                    .ignoresSafeArea(.keyboard, edges: .bottom)

                // Floating pill nav bar
                BottomNavigationBar()
                    .environmentObject(navigationCoordinator)
                    .padding(.horizontal, 24)
                    .padding(.bottom, max(proxy.safeAreaInsets.bottom, 12))
            }
            .edgesIgnoringSafeArea(.bottom)
        }
        .onAppear { navigationCoordinator.navigateToTab("Home") }
    }
    
    @ViewBuilder
    private func getCurrentView() -> some View {
        let currentView = navigationCoordinator.currentView
        
        switch currentView {
        case "Home":
            ExploreView()
                .environmentObject(navigationCoordinator)
        case "Workout":
            WorkoutMainView()
                .environmentObject(navigationCoordinator)
        case "Status":
            StatusOverview()
                .environmentObject(navigationCoordinator)
        case "Profile":
            ProfileSettingsView()
                .environmentObject(navigationCoordinator)
        // Workout Navigation
        case "WorkoutDetailView":
            WorkoutDetailView()
                .environmentObject(navigationCoordinator)
        case "WorkoutExerciseView":
            WorkoutExerciseView()
                .environmentObject(navigationCoordinator)
        // Status Navigation
        case "StatusWorkout":
            StatusWorkout()
                .environmentObject(navigationCoordinator)
        case "StatusStep":
            StatusStep()
                .environmentObject(navigationCoordinator)
        case "StatusWater":
            StatusWater()
                .environmentObject(navigationCoordinator)
        // Activity Navigation
        case "StepTrackerView":
            StepTrackerView()
                .environmentObject(navigationCoordinator)
        case "WaterGlassSelectionView":
            WaterGlassSelectionView()
                .environmentObject(navigationCoordinator)
        // Challenge Navigation
        case "ChallengeMainView":
            ChallengeMainView()
                .environmentObject(navigationCoordinator)
        case "ChallengeDetailView":
            ChallengeDetailView()
                .environmentObject(navigationCoordinator)
        default:
            ExploreView()
                .environmentObject(navigationCoordinator)
        }
    }
}

#Preview {
    MainNavigationView()
        .environmentObject(AuthService.shared)
        .environmentObject(StepService.shared)
        .environmentObject(WaterService.shared)
}
