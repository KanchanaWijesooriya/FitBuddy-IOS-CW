//
//  NotificationPermissionView.swift
//  FitBuddy
//
//  Notification permission request view for onboarding
//

import SwiftUI

struct NotificationPermissionView: View {
    @EnvironmentObject var notificationService: NotificationService
    @Binding var isPresented: Bool
    
    @State private var showPermissionResult = false
    @State private var permissionGranted = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [.darkBlue, .lightBlue]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "bell.badge.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.white)
                    
                    Text("Enable Notifications in Settings")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("You can enable notifications for FitBuddy in your device Settings to receive motivational tips and goal celebrations.")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // Benefits list
                VStack(alignment: .leading, spacing: 16) {
                    NotificationBenefitRow(
                        icon: "heart.circle.fill",
                        title: "Daily Motivation",
                        description: "Inspiring tips every 5 minutes to keep you motivated"
                    )
                    
                    NotificationBenefitRow(
                        icon: "trophy.circle.fill",
                        title: "Goal Celebrations",
                        description: "Celebrate your achievements and milestones"
                    )
                    
                    NotificationBenefitRow(
                        icon: "arrow.clockwise.circle.fill",
                        title: "Progress Updates",
                        description: "Regular reminders to track and update your progress"
                    )
                    
                    NotificationBenefitRow(
                        icon: "bell.circle.fill",
                        title: "Friendly Reminders",
                        description: "Gentle nudges to stay active and hydrated"
                    )
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Action buttons
                VStack(spacing: 16) {
                    Button(action: openSettings) {
                        Text("Open Settings")
                            .font(.headline)
                            .foregroundColor(.darkBlue)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                    }
                    
                    Button(action: skipPermission) {
                        Text("Not Now")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
        }
        .alert("Notifications", isPresented: $showPermissionResult) {
            Button("OK") {
                isPresented = false
            }
        } message: {
            Text(permissionGranted 
                ? "Great! You'll now receive motivational reminders and updates to help you stay on track."
                : "You can always enable notifications later in your device settings or app preferences.")
        }
    }
    
    private func openSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
        isPresented = false
    }
    
    private func skipPermission() {
        isPresented = false
    }
}

struct NotificationBenefitRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
        }
    }
}

#Preview {
    NotificationPermissionView(isPresented: .constant(true))
        .environmentObject(NotificationService.shared)
}