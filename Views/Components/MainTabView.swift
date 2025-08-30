import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: TabItem = .home
    
    var body: some View {
        ZStack {
            // Background
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Main content area
                Group {
                    switch selectedTab {
                    case .home:
                        DashboardView()
                    case .explore:
                        ExploreView()
                    case .status:
                        StatusView()
                    case .profile:
                        ProfileView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Bottom Navigation Bar
                BottomNavigationBar(selectedTab: $selectedTab)
            }
        }
    }
}

// Placeholder views for other tabs - you can replace these with your actual views
struct StatusView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Status View")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Your progress and statistics will be shown here")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .navigationTitle("Status")
        }
    }
}

struct ProfileView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Profile View")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Your profile settings and information will be shown here")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    MainTabView()
}
