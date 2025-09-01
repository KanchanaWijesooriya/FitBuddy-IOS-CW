//
//  FitBuddyApp.swift
//  FitBuddy
//
//  Created by Chanuka Wijesooriya on 2025-08-24.
//

import SwiftUI
import Firebase

@main
struct FitBuddyApp: App {
    
    init() {
        FirebaseApp.configure()
        print("Firebase configured successfully")
    }
    
    var body: some Scene {
        WindowGroup {
            ExploreView()
        }
    }
}
