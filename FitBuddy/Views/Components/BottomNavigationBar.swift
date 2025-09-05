import SwiftUI

struct BottomNavigationBar: View {
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    
    var body: some View {
        HStack {
            Spacer()
            
            // Home
            BottomNavItem(
                icon: "house.fill",
                label: "Home",
                isSelected: navigationCoordinator.selectedTab == "Home"
            ) {
                navigationCoordinator.navigateToTab("Home")
            }
            
            Spacer()
            
            // Workout
            BottomNavItem(
                icon: "dumbbell.fill",
                label: "Workout",
                isSelected: navigationCoordinator.selectedTab == "Workout"
            ) {
                navigationCoordinator.navigateToTab("Workout")
            }
            
            Spacer()
            
            // Status
            BottomNavItem(
                icon: "chart.bar.fill",
                label: "Status",
                isSelected: navigationCoordinator.selectedTab == "Status"
            ) {
                navigationCoordinator.navigateToTab("Status")
            }
            
            Spacer()
            
            // Profile
            BottomNavItem(
                icon: "person.fill",
                label: "Profile",
                isSelected: navigationCoordinator.selectedTab == "Profile"
            ) {
                navigationCoordinator.navigateToTab("Profile")
            }
            
            Spacer()
        }
        .frame(height: 70)
        .background(
            RoundedRectangle(cornerRadius: 35)
                .fill(Color.black)
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: -5)
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
}

struct BottomNavItem: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let isHighlighted: Bool
    let action: () -> Void
    
    init(icon: String, label: String, isSelected: Bool, isHighlighted: Bool = false, action: @escaping () -> Void) {
        self.icon = icon
        self.label = label
        self.isSelected = isSelected
        self.isHighlighted = isHighlighted
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack {
                    if isSelected {
                        // Green rounded background for selected item
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(red: 0.7, green: 1.0, blue: 0.3))
                            .frame(width: 60, height: 32)
                    }
                    
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(
                            isSelected ? .black : .white
                        )
                }
                
                Text(label)
                    .font(.caption2)
                    .foregroundColor(
                        isSelected ? Color(red: 0.7, green: 1.0, blue: 0.3) : .white
                    )
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct BottomNavigationBar_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            BottomNavigationBar()
                .environmentObject(NavigationCoordinator())
        }
        .background(Color(.systemBackground))
    }
}
