//
//  NotificationTestView.swift
//  FitBuddy
//
//  Test view for notification system
//

import SwiftUI

struct NotificationTestView: View {
    @EnvironmentObject var notificationService: NotificationService
    @EnvironmentObject var challengeService: ChallengeService
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    headerSection
                    
                    VStack(spacing: 16) {
                        notificationTestSection
                        challengeTestSection
                        reminderSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
            .background(Color.adaptiveBackground)
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.waterBlue)
            )
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "bell.badge.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(Color.waterBlue)
            
            Text("Notification Center")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text("Test different notification scenarios")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 20)
        .padding(.horizontal, 20)
    }
    
    private var notificationTestSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Achievement Notifications", icon: "trophy.circle.fill")
            
            VStack(spacing: 12) {
                testButton(
                    title: "Daily Step Goal",
                    description: "Test reaching 10,000 steps",
                    color: .waterBlue
                ) {
                    notificationService.notifyDailyGoalCompleted(goalType: "steps", value: "10,000 steps")
                }
                
                testButton(
                    title: "Hydration Goal",
                    description: "Test reaching 2L water goal",
                    color: .hydrationTeal
                ) {
                    notificationService.notifyDailyGoalCompleted(goalType: "hydration", value: "2.0L")
                }
                
                testButton(
                    title: "Halfway Progress",
                    description: "Test 50% goal progress",
                    color: .lightBlue
                ) {
                    notificationService.notifyHalfwayGoal(goalType: "steps", progress: "50%")
                }
                
                testButton(
                    title: "Workout Complete",
                    description: "Test workout completion",
                    color: .vibrantCyan
                ) {
                    notificationService.notifyWorkoutCompleted(workoutName: "HIIT Training", duration: "25m", calories: 320)
                }
                
                testButton(
                    title: "Weekly Goal",
                    description: "Test weekly achievement",
                    color: .darkBlue
                ) {
                    notificationService.notifyWeeklyGoalCompleted(goalType: "consistency")
                }
            }
        }
        .padding(20)
        .background(Color.adaptiveCardBackground)
        .cornerRadius(16)
    }
    
    private var challengeTestSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Challenge Notifications", icon: "flag.circle.fill")
            
            VStack(spacing: 12) {
                testButton(
                    title: "Challenge Enrolled",
                    description: "Test joining a challenge",
                    color: .waterBlue
                ) {
                    notificationService.notifyChallengeEnrolled(challengeName: "10K Steps Daily")
                }
                
                testButton(
                    title: "Challenge Completed",
                    description: "Test completing a challenge",
                    color: .hydrationTeal
                ) {
                    notificationService.notifyChallengeCompleted(challengeName: "Hydration Hero")
                }
            }
        }
        .padding(20)
        .background(Color.adaptiveCardBackground)
        .cornerRadius(16)
    }
    
    private var reminderSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Reminder Notifications", icon: "bell.circle.fill")
            
            VStack(spacing: 12) {
                testButton(
                    title: "Hydration Reminder",
                    description: "Test water drinking reminder",
                    color: .vibrantCyan
                ) {
                    notificationService.notifyHydrationReminder()
                }
                
                testButton(
                    title: "Workout Reminder",
                    description: "Test exercise reminder",
                    color: .softMint
                ) {
                    notificationService.notifyWorkoutReminder()
                }
                
                testButton(
                    title: "Schedule Daily Reminders",
                    description: "Setup automatic reminders",
                    color: .lightBlue
                ) {
                    notificationService.scheduleDailyReminders()
                    notificationService.showInAppNotification(
                        InAppNotification(
                            type: .info,
                            title: "Reminders Scheduled",
                            message: "Daily hydration and workout reminders have been set up",
                            duration: 3.0
                        )
                    )
                }
            }
        }
        .padding(20)
        .background(Color.adaptiveCardBackground)
        .cornerRadius(16)
    }
    
    private func sectionHeader(_ title: String, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.waterBlue)
                .font(.title3)
            
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
    
    private func testButton(
        title: String,
        description: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(color)
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(color.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    NotificationTestView()
        .environmentObject(NotificationService.shared)
        .environmentObject(ChallengeService.shared)
}