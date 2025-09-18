//
//  NotificationSettingsView.swift
//  FitBuddy
//
//  User notification preferences and settings management
//

import SwiftUI

struct NotificationSettingsView: View {
    @EnvironmentObject var notificationService: NotificationService
    @Environment(\.presentationMode) var presentationMode
    
    @State private var motivationEnabled = true
    @State private var goalNotificationsEnabled = true
    @State private var workoutRemindersEnabled = true
    @State private var showPermissionAlert = false
    
    var body: some View {
        NavigationView {
            List {
                // Permission Status Section
                Section(header: Text("Permission Status")) {
                    HStack {
                        Image(systemName: notificationService.isAuthorized ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(notificationService.isAuthorized ? .green : .red)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Notifications")
                                .font(.headline)
                            
                            Text(notificationService.isAuthorized 
                                ? "Enabled - You'll receive app notifications" 
                                : "Disabled - Enable in device settings to receive notifications")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if !notificationService.isAuthorized {
                            Button("Enable") {
                                showPermissionAlert = true
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                    }
                }
                
                // Notification Types Section
                Section(header: Text("Notification Types"), 
                       footer: Text("Control which types of notifications you receive to stay motivated and on track with your fitness goals.")) {
                    
                    NotificationToggleRow(
                        icon: "heart.circle.fill",
                        title: "Motivation Tips",
                        description: "Inspiring messages every 5 minutes",
                        isEnabled: $motivationEnabled,
                        color: .hydrationTeal
                    ) {
                        notificationService.setMotivationNotificationsEnabled(motivationEnabled)
                    }
                    
                    NotificationToggleRow(
                        icon: "trophy.circle.fill",
                        title: "Goal Achievements",
                        description: "Celebrate when you reach your goals",
                        isEnabled: $goalNotificationsEnabled,
                        color: .waterBlue
                    ) {
                        notificationService.setGoalNotificationsEnabled(goalNotificationsEnabled)
                    }
                    
                    NotificationToggleRow(
                        icon: "bell.circle.fill",
                        title: "Workout Reminders",
                        description: "Gentle nudges to stay active",
                        isEnabled: $workoutRemindersEnabled,
                        color: .lightBlue
                    ) {
                        notificationService.setWorkoutRemindersEnabled(workoutRemindersEnabled)
                    }
                }
                
                // Information Section
                Section(header: Text("About Notifications")) {
                    InfoRow(
                        icon: "clock.circle.fill",
                        title: "Timing",
                        description: "Notifications are sent every 5 minutes when the app is active",
                        color: .darkBlue
                    )
                    
                    InfoRow(
                        icon: "shield.circle.fill",
                        title: "Privacy",
                        description: "All notifications are generated locally on your device",
                        color: .vibrantCyan
                    )
                    
                    InfoRow(
                        icon: "gear.circle.fill",
                        title: "Device Settings",
                        description: "You can also manage notifications in your device Settings app",
                        color: .softMint
                    )
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        .onAppear {
            loadCurrentSettings()
        }
        .alert("Enable Notifications", isPresented: $showPermissionAlert) {
            Button("Open Settings") {
                openDeviceSettings()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("To receive notifications, please enable them in your device Settings app. Go to Settings > FitBuddy > Notifications and turn on Allow Notifications.")
        }
    }
    
    private func loadCurrentSettings() {
        motivationEnabled = notificationService.isMotivationNotificationsEnabled()
        goalNotificationsEnabled = notificationService.isGoalNotificationsEnabled()
        workoutRemindersEnabled = notificationService.isWorkoutRemindersEnabled()
    }
    
    private func openDeviceSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
}

struct NotificationToggleRow: View {
    let icon: String
    let title: String
    let description: String
    @Binding var isEnabled: Bool
    let color: Color
    let onToggle: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title2)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: $isEnabled)
                .onChange(of: isEnabled) { _ in
                    onToggle()
                }
        }
        .padding(.vertical, 4)
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title2)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NotificationSettingsView()
}