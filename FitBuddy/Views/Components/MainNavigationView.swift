import SwiftUI

struct MainNavigationView: View {
    @StateObject private var navigationCoordinator = NavigationCoordinator()
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var stepService: StepService
    @EnvironmentObject var waterService: WaterService
    
    var body: some View {
        ZStack {
            // Main content area
            VStack(spacing: 0) {
                // Content area
                getCurrentView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Bottom navigation bar
                BottomNavigationBar()
                    .environmentObject(navigationCoordinator)
            }
        }
        .onAppear {
            navigationCoordinator.navigateToTab("Home")
        }
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
