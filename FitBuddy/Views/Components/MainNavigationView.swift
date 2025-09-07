import SwiftUI

struct MainNavigationView: View {
    @StateObject private var navigationCoordinator = NavigationCoordinator()
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var stepService: StepService
    @EnvironmentObject var waterService: WaterService
    
    // Apple Blue theme
    private let primaryAccent = Color(red: 0.0, green: 0.478, blue: 1.0)
    
    var body: some View {
        TabView(selection: $navigationCoordinator.selectedTab) {
            // Home Tab
            NavigationView {
                getViewForTab("Home")
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }
            .tag("Home")
            
            // Workout Tab
            NavigationView {
                getViewForTab("Workout")
            }
            .tabItem {
                Image(systemName: "dumbbell.fill")
                Text("Workout")
            }
            .tag("Workout")
            
            // Status Tab
            NavigationView {
                getViewForTab("Status")
            }
            .tabItem {
                Image(systemName: "chart.bar.fill")
                Text("Status")
            }
            .tag("Status")
            
            // Profile Tab
            NavigationView {
                getViewForTab("Profile")
            }
            .tabItem {
                Image(systemName: "person.fill")
                Text("Profile")
            }
            .tag("Profile")
        }
        .accentColor(primaryAccent) // Blue theme for tab bar
        .onAppear {
            // Configure tab bar appearance
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithOpaqueBackground()
            tabBarAppearance.backgroundColor = UIColor.systemBackground
            
            // Selected item color (blue)
            tabBarAppearance.stackedLayoutAppearance.selected.iconColor = UIColor(primaryAccent)
            tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                .foregroundColor: UIColor(primaryAccent)
            ]
            
            // Unselected item color (gray)
            tabBarAppearance.stackedLayoutAppearance.normal.iconColor = UIColor.systemGray
            tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                .foregroundColor: UIColor.systemGray
            ]
            
            UITabBar.appearance().standardAppearance = tabBarAppearance
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
            
            navigationCoordinator.selectedTab = "Home"
        }
    }
    
    @ViewBuilder
    private func getViewForTab(_ tab: String) -> some View {
        switch tab {
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
