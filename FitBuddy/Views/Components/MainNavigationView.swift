import SwiftUI

struct MainNavigationView: View {
    @StateObject private var navigationCoordinator = NavigationCoordinator()
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var stepService: StepService
    @EnvironmentObject var waterService: WaterService
    @EnvironmentObject var healthKitService: HealthKitService
    @EnvironmentObject var notificationService: NotificationService
    @State private var homeNavigationID = UUID()
    @State private var showNotificationPermission = false
    
    // Your app's waterBlue theme
    private let primaryAccent = Color.waterBlue
    
    var body: some View {
        TabView(selection: $navigationCoordinator.selectedTab) {
            // Home Tab
            NavigationView {
                getViewForTab("Home")
                    .id(homeNavigationID)
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
        .onChange(of: navigationCoordinator.shouldResetHomeNavigation) { value in
            if value {
                homeNavigationID = UUID() // Force recreation of the Home NavigationView
                navigationCoordinator.shouldResetHomeNavigation = false
            }
        }
        .onChange(of: navigationCoordinator.selectedTab) { value in
            if value == "Home" {
                // Always ensure we show the explore view when Home is selected
                homeNavigationID = UUID()
            }
        }
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
            
            // Request notification permission after app loads
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                print("🔔 App loaded, checking notification status...")
                print("🔔 Current authorization: \(notificationService.isAuthorized)")
                
                // Always request permission if not authorized (iOS will handle if already asked)
                if !notificationService.isAuthorized {
                    print("🔔 Not authorized, requesting permission...")
                    notificationService.requestNotificationPermission { granted in
                        print("🔔 Final permission result: \(granted)")
                    }
                } else {
                    print("🔔 Already authorized, starting notifications...")
                    notificationService.startMotivationNotifications()
                }
            }
        }
        .fullScreenCover(isPresented: $showNotificationPermission) {
            NotificationPermissionView(isPresented: $showNotificationPermission)
        }
    }
    
    @ViewBuilder
    private func getViewForTab(_ tab: String) -> some View {
        switch tab {
        case "Home":
            ExploreView()
                .environmentObject(navigationCoordinator)
                .environmentObject(waterService)
                .environmentObject(stepService)
                .environmentObject(healthKitService)
        case "Workout":
            WorkoutMainView()
                .environmentObject(navigationCoordinator)
                .environmentObject(stepService)
                .environmentObject(healthKitService)
        case "Status":
            StatusOverview()
                .environmentObject(navigationCoordinator)
                .environmentObject(waterService)
                .environmentObject(stepService)
                .environmentObject(healthKitService)
        case "Profile":
            ProfileSettingsView()
                .environmentObject(navigationCoordinator)
                .environmentObject(waterService)
                .environmentObject(stepService)
                .environmentObject(healthKitService)
        default:
            ExploreView()
                .environmentObject(navigationCoordinator)
                .environmentObject(waterService)
                .environmentObject(stepService)
                .environmentObject(healthKitService)
        }
    }
}


#Preview {
    MainNavigationView()
        .environmentObject(AuthService.shared)
        .environmentObject(StepService.shared)
        .environmentObject(WaterService.shared)
}
