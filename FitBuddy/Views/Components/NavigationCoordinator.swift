import SwiftUI

class NavigationCoordinator: ObservableObject {
    @Published var selectedTab: String = "Home"
    @Published var navigationStack: [String] = []
    
    func navigateToTab(_ tab: String) {
        selectedTab = tab
        navigationStack = [tab] // Reset stack when navigating via tab
    }
    
    func navigateToView(_ viewName: String) {
        navigationStack.append(viewName)
    }
    
    func goBack() {
        if !navigationStack.isEmpty {
            navigationStack.removeLast()
        }
        
        // Update selected tab based on current view
        if let currentView = navigationStack.last {
            updateSelectedTabForView(currentView)
        } else {
            updateSelectedTabForView(selectedTab)
        }
    }
    
    private func updateSelectedTabForView(_ viewName: String) {
        switch viewName {
        case "Home", "ExploreView":
            selectedTab = "Home"
        case "Workout", "WorkoutMainView":
            selectedTab = "Workout"
        case "Status", "StatusOverview":
            selectedTab = "Status"
        case "Profile", "ProfileSettingsView":
            selectedTab = "Profile"
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
