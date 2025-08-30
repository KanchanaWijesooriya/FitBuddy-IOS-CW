import SwiftUI

enum TabItem: String, CaseIterable {
    case home = "Home"
    case explore = "Explore"
    case status = "Status"
    case profile = "Profile"
    
    var icon: String {
        switch self {
        case .home:
            return "house"
        case .explore:
            return "magnifyingglass"
        case .status:
            return "chart.bar"
        case .profile:
            return "person"
        }
    }
    
    var selectedIcon: String {
        switch self {
        case .home:
            return "house.fill"
        case .explore:
            return "magnifyingglass"
        case .status:
            return "chart.bar.fill"
        case .profile:
            return "person.fill"
        }
    }
}

struct BottomNavigationBar: View {
    @Binding var selectedTab: TabItem
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(TabItem.allCases, id: \.self) { tab in
                TabButton(
                    tab: tab,
                    selectedTab: $selectedTab
                )
            }
        }
        .frame(height: 60)
        .background(Color.white)
        .cornerRadius(25)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -5)
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
    }
}

struct TabButton: View {
    let tab: TabItem
    @Binding var selectedTab: TabItem
    
    var isSelected: Bool {
        selectedTab == tab
    }
    
    var body: some View {
        Button(action: {
            selectedTab = tab
        }) {
            VStack(spacing: 4) {
                Image(systemName: isSelected ? tab.selectedIcon : tab.icon)
                    .font(.system(size: 20, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(isSelected ? Color(red: 0.7, green: 1.0, blue: 0.3) : Color.gray)
                
                Text(tab.rawValue)
                    .font(.caption2)
                    .fontWeight(isSelected ? .semibold : .medium)
                    .foregroundColor(isSelected ? Color(red: 0.7, green: 1.0, blue: 0.3) : Color.gray)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    VStack {
        Spacer()
        BottomNavigationBar(selectedTab: .constant(.explore))
    }
    .background(Color.gray.opacity(0.1))
}
