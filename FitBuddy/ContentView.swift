//
//  ContentView.swift
//  FitBuddy
//
//  Created by Chanuka Wijesooriya on 2025-08-24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authService: AuthService
    @State private var showLoginView = false
    
    var body: some View {
        ZStack {
            if authService.isUserLoggedIn {
                ExploreView()
            } else {
                OnboardingView()
                    .fullScreenCover(isPresented: $showLoginView) {
                        LoginView()
                    }
                    .onReceive(NotificationCenter.default.publisher(for: .showLoginView)) { _ in
                        showLoginView = true
                    }
            }
        }
    }
}

extension Notification.Name {
    static let showLoginView = Notification.Name("showLoginView")
}

#Preview {
    ContentView()
        .environmentObject(AuthService.shared)
}
