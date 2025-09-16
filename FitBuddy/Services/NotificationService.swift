//
//  NotificationService.swift
//  FitBuddy
//
//  Comprehensive notification system for fitness tracking events
//

import Foundation
import UserNotifications
import SwiftUI

class NotificationService: NSObject, ObservableObject {
    static let shared = NotificationService()
    
    @Published var isAuthorized = false
    @Published var showInAppNotification = false
    @Published var currentNotification: InAppNotification?
    
    private override init() {
        super.init()
        checkAuthorizationStatus()
    }
    
    // MARK: - Permission Management
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                self.isAuthorized = granted
                if granted {
                    print("✅ Notification permission granted")
                } else {
                    print("❌ Notification permission denied")
                }
            }
        }
    }
    
    private func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
    
    // MARK: - In-App Notifications
    
    func showInAppNotification(_ notification: InAppNotification) {
        DispatchQueue.main.async {
            self.currentNotification = notification
            
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                self.showInAppNotification = true
            }
            
            // Auto-hide after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + notification.duration) {
                self.hideInAppNotification()
            }
        }
    }
    
    func hideInAppNotification() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            showInAppNotification = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            currentNotification = nil
        }
    }
    
    // MARK: - Local Notifications (Background)
    
    func scheduleLocalNotification(
        title: String,
        body: String,
        timeInterval: TimeInterval,
        identifier: String
    ) {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to schedule notification: \(error)")
            } else {
                print("✅ Notification scheduled: \(identifier)")
            }
        }
    }
    
    // MARK: - Predefined Notification Scenarios
    
    func notifySuccessfulLogin(username: String) {
        let notification = InAppNotification(
            type: .success,
            title: "Welcome to FitBuddy!",
            message: "Your fitness journey starts now. Let's track your daily progress!",
            duration: 3.0
        )
        showInAppNotification(notification)
    }
    
    func notifyChallengeEnrolled(challengeName: String) {
        let notification = InAppNotification(
            type: .info,
            title: "Challenge Enrolled",
            message: "You've joined \(challengeName). Track your progress and achieve your goals!",
            duration: 3.0
        )
        showInAppNotification(notification)
    }
    
    func notifyChallengeCompleted(challengeName: String) {
        let notification = InAppNotification(
            type: .achievement,
            title: "Challenge Completed!",
            message: "Congratulations! You've successfully completed \(challengeName).",
            duration: 4.0
        )
        showInAppNotification(notification)
    }
    
    func notifyDailyGoalCompleted(goalType: String, value: String) {
        let notification = InAppNotification(
            type: .achievement,
            title: "Daily Goal Achieved!",
            message: "You've reached your daily \(goalType) goal of \(value). Keep up the great work!",
            duration: 3.5
        )
        showInAppNotification(notification)
    }
    
    func notifyWeeklyGoalCompleted(goalType: String) {
        let notification = InAppNotification(
            type: .achievement,
            title: "Weekly Goal Completed!",
            message: "Amazing! You've achieved your weekly \(goalType) goal. You're on fire!",
            duration: 4.0
        )
        showInAppNotification(notification)
    }
    
    func notifyHalfwayGoal(goalType: String, progress: String) {
        let notification = InAppNotification(
            type: .progress,
            title: "Halfway There!",
            message: "You're \(progress) of the way to your daily \(goalType) goal. Keep pushing!",
            duration: 3.0
        )
        showInAppNotification(notification)
    }
    
    func notifyWorkoutCompleted(workoutName: String, duration: String, calories: Int) {
        let notification = InAppNotification(
            type: .achievement,
            title: "Workout Completed!",
            message: "Great job! You completed \(workoutName) in \(duration) and burned \(calories) calories.",
            duration: 3.5
        )
        showInAppNotification(notification)
    }
    
    func notifyHydrationReminder() {
        let notification = InAppNotification(
            type: .reminder,
            title: "Stay Hydrated",
            message: "Don't forget to drink water. Your body needs hydration to perform at its best.",
            duration: 3.0
        )
        showInAppNotification(notification)
    }
    
    func notifyWorkoutReminder() {
        let notification = InAppNotification(
            type: .reminder,
            title: "Time to Move",
            message: "Ready for your workout? A few minutes of exercise can boost your energy.",
            duration: 3.0
        )
        showInAppNotification(notification)
    }
    
    // MARK: - Daily Reminder Scheduling
    
    func scheduleDailyReminders() {
        // Hydration reminder - 2 PM
        scheduleLocalNotification(
            title: "Stay Hydrated",
            body: "Don't forget to drink water throughout the day.",
            timeInterval: getTimeIntervalFor(hour: 14, minute: 0),
            identifier: "daily_hydration"
        )
        
        // Evening workout reminder - 6 PM
        scheduleLocalNotification(
            title: "Evening Workout",
            body: "Ready for your evening workout? Let's get moving!",
            timeInterval: getTimeIntervalFor(hour: 18, minute: 0),
            identifier: "evening_workout"
        )
        
        // Weekly summary - Sunday 8 PM
        scheduleWeeklyNotification(
            title: "Weekly Summary",
            body: "Check out your weekly fitness progress and plan for the week ahead.",
            weekday: 1, // Sunday
            hour: 20,
            identifier: "weekly_summary"
        )
    }
    
    private func getTimeIntervalFor(hour: Int, minute: Int) -> TimeInterval {
        let calendar = Calendar.current
        let now = Date()
        
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: now)
        dateComponents.hour = hour
        dateComponents.minute = minute
        dateComponents.second = 0
        
        if let scheduledDate = calendar.date(from: dateComponents) {
            if scheduledDate <= now {
                // Schedule for tomorrow if time has passed today
                return scheduledDate.addingTimeInterval(24 * 60 * 60).timeIntervalSinceNow
            } else {
                return scheduledDate.timeIntervalSinceNow
            }
        }
        
        return 3600 // Default to 1 hour if calculation fails
    }
    
    private func scheduleWeeklyNotification(title: String, body: String, weekday: Int, hour: Int, identifier: String) {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        
        var dateComponents = DateComponents()
        dateComponents.weekday = weekday
        dateComponents.hour = hour
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to schedule weekly notification: \(error)")
            } else {
                print("✅ Weekly notification scheduled: \(identifier)")
            }
        }
    }
    
    // MARK: - Notification Management
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("🗑️ All notifications cancelled")
    }
    
    func cancelNotification(identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        print("🗑️ Cancelled notification: \(identifier)")
    }
}

// MARK: - In-App Notification Model

struct InAppNotification {
    let id = UUID()
    let type: NotificationType
    let title: String
    let message: String
    let duration: TimeInterval
    
    enum NotificationType {
        case success
        case achievement
        case progress
        case info
        case reminder
        case warning
        
        var color: Color {
            switch self {
            case .success:
                return .waterBlue
            case .achievement:
                return .hydrationTeal
            case .progress:
                return .lightBlue
            case .info:
                return .darkBlue
            case .reminder:
                return .vibrantCyan
            case .warning:
                return .softMint
            }
        }
        
        var iconName: String {
            switch self {
            case .success:
                return "checkmark.circle.fill"
            case .achievement:
                return "trophy.circle.fill"
            case .progress:
                return "chart.line.uptrend.xyaxis.circle.fill"
            case .info:
                return "info.circle.fill"
            case .reminder:
                return "bell.circle.fill"
            case .warning:
                return "exclamationmark.triangle.fill"
            }
        }
    }
}