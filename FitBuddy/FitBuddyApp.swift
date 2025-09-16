//
//  FitBuddyApp.swift
//  FitBuddy
//
//  Created by Chanuka Wijesooriya on 2025-08-24.
//

import SwiftUI
import Firebase

import SwiftUI
import Firebase

import SwiftUI
import Firebase

@main
struct FitBuddyApp: App {
    @StateObject private var authService = AuthService.shared
    @StateObject private var workoutService = WorkoutService.shared
    @StateObject private var stepService = StepService.shared
    @StateObject private var waterService = WaterService.shared
    @StateObject private var healthKitService = HealthKitService.shared
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authService)
                .environmentObject(workoutService)
                .environmentObject(stepService)
                .environmentObject(waterService)
                .environmentObject(healthKitService)
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willTerminateNotification)) { _ in
                    // Sign out user when app is about to terminate
                    authService.signOut()
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
                    // Optionally sign out when app goes to background (uncomment if you want this)
                    // authService.signOut()
                }
        }
    }
}
