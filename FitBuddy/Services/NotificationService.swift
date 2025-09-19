//
//  NotificationService.swift
//  FitBuddy
//
//  Comprehensive notification system for fitness tracking events
//

import Foundation
import UserNotifications
import SwiftUI

class NotificationService: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationService()
    
    @Published var isAuthorized = false
    @Published var showInAppNotification = false
    @Published var currentNotification: InAppNotification?
    @Published var hasRequestedPermission = false
    
    private var motivationTimer: Timer?
    private var currentMotivationIndex = 0
    
    private override init() {
        super.init()
        setupNotificationCenter()
        checkAuthorizationStatus()
        checkPermissionRequestStatus()
    }
    
    private func setupNotificationCenter() {
        UNUserNotificationCenter.current().delegate = self
    }
    
    func requestNotificationPermission(completion: @escaping (Bool) -> Void = { _ in }) {
        print("Requesting notification permission...")
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                print(" Permission result: granted=\(granted), error=\(String(describing: error))")
                self.isAuthorized = granted
                self.hasRequestedPermission = true
                UserDefaults.standard.set(true, forKey: "hasRequestedNotificationPermission")
                
                if granted {
                    print(" Notification permission granted - starting notifications")
                    self.startMotivationNotifications()
                    
                    // Enable 3-minute reminders by default
                    if UserDefaults.standard.object(forKey: "3MinuteRemindersEnabled") == nil {
                        UserDefaults.standard.set(true, forKey: "3MinuteRemindersEnabled")
                    }
                    
                    // Send a welcome notification immediately
                    self.sendWelcomeNotification()
                } else {
                    print("Notification permission denied")
                }
                completion(granted)
            }
        }
    }
    
    private func sendWelcomeNotification() {
        let notification = InAppNotification(
            type: .success,
            title: "Notifications Enabled",
            message: "Great! You'll now receive motivational tips and goal celebrations to keep you on track.",
            duration: 4.0
        )
        showInAppNotification(notification)
    }
    
    private func checkPermissionRequestStatus() {
        hasRequestedPermission = UserDefaults.standard.bool(forKey: "hasRequestedNotificationPermission")
    }
    
    func shouldRequestPermission() -> Bool {
        return !hasRequestedPermission && !isAuthorized
    }
    
    // Debug function to reset permission state for testing
    func resetPermissionState() {
        hasRequestedPermission = false
        UserDefaults.standard.set(false, forKey: "hasRequestedNotificationPermission")
        print("Permission state reset for testing")
    }
    
    private func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized
                if self.isAuthorized && self.hasRequestedPermission {
                    self.startMotivationNotifications()
                    
                    // Start 3-minute reminders if enabled
                    if self.is3MinuteRemindersEnabled() {
                        self.start3MinuteReminders()
                    }
                }
            }
        }
    }
    
    
    private let motivationTips = [
        "Small steps daily lead to big changes yearly.",
        "Consistency beats perfection every time.",
        "Your body can do it. Your mind just needs to catch up.",
        "Progress not perfection. Every step counts.",
        "The hardest workout is the one you skip.",
        "Believe in yourself and all that you are.",
        "Champions train, legends never give up.",
        "Fitness is not about being better than someone else. It's about being better than you used to be.",
        "The only bad workout is the one that didn't happen.",
        "Your health is an investment, not an expense.",
        "Strong is the new beautiful.",
        "You don't have to be great to get started, but you have to get started to be great.",
        "Fitness is not a destination, it's a way of life.",
        "Every workout brings you one step closer to your goals.",
        "Your future self will thank you for the work you put in today.",
        "Discipline is choosing between what you want now and what you want most.",
        "The pain you feel today will be the strength you feel tomorrow.",
        "Strive for progress, not perfection.",
        "Your only limit is you.",
        "Make yourself proud."
    ]
    
    private let updateMessages = [
        "Check your daily progress and see how far you've come today.",
        "Review your weekly stats and celebrate your achievements.",
        "Update your goals to match your growing strength and determination.",
        "Log your latest workout and track your improvement.",
        "Record your water intake and stay on top of your hydration goals.",
        "Check your step count and see if you're on track for today.",
        "Review your fitness trends and plan your next workout.",
        "Update your profile with your latest achievements.",
        "Set new challenges to keep your fitness journey exciting.",
        "Check your progress charts and visualize your success."
    ]
    
    
    func startMotivationNotifications() {
        guard isAuthorized else { 
            print("Cannot start notifications - not authorized")
            return 
        }
        
        print("Starting 3-minute interval reminder notifications")
        
        // Send a test notification to confirm notifications work
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.sendTestLocalNotification()
        }
        
        // Start 3-minute interval timer for reminder notifications
        start3MinuteReminderTimer()
    }
    
    private func start3MinuteReminderTimer() {
        guard isAuthorized else { return }
        
        // Stop any existing timer
        motivationTimer?.invalidate()
        
        print("Starting 3-minute reminder timer")
        
        // Create a timer that fires every 3 minutes (180 seconds)
        motivationTimer = Timer.scheduledTimer(withTimeInterval: 180.0, repeats: true) { [weak self] _ in
            self?.send3MinuteReminder()
        }
    }
    
    func send3MinuteReminder() {
        guard isAuthorized else { return }
        
        print("Sending 3-minute reminder notification")
        
        let reminderMessages = [
            "Time for a quick hydration break!",
            "Take a moment to stretch and move!",
            "How's your posture? Stand up and take a deep breath!",
            "Quick check: Are you drinking enough water today?",
            "Time to move! Do 10 jumping jacks or walk around!",
            "Remember your fitness goals - you're doing great!",
            "Hydration reminder: Your body needs water to perform!",
            "Take a 30-second movement break! Your body will thank you!"
        ]
        
        let randomMessage = reminderMessages[currentMotivationIndex % reminderMessages.count]
        currentMotivationIndex += 1
        
        // Send both in-app and local notification
        let inAppNotification = InAppNotification(
            type: .reminder,
            title: "Fitness Reminder",
            message: randomMessage,
            duration: 3.0
        )
        showInAppNotification(inAppNotification)
        
        // Also send a local notification
        sendLocalNotification(
            title: "FitBuddy Reminder",
            body: randomMessage,
            delay: 1.0
        )
    }
    
    private func sendTestLocalNotification() {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "FitBuddy Notifications Ready!"
        content.body = "You'll receive notifications for goals, challenges, and achievements."
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "test_notification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("ailed to send test notification: \(error)")
            } else {
                print("Test notification scheduled successfully")
            }
        }
    }
    
    func stopMotivationNotifications() {
        motivationTimer?.invalidate()
        motivationTimer = nil
        print("Stopped 3-minute reminder notification timer")
    }
    
    func stop3MinuteReminders() {
        motivationTimer?.invalidate()
        motivationTimer = nil
        print("Stopped 3-minute reminder notifications")
    }
    
    func start3MinuteReminders() {
        guard isAuthorized else {
            print("Cannot start 3-minute reminders - not authorized")
            return
        }
        start3MinuteReminderTimer()
    }
    
    
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
            self.showInAppNotification = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.currentNotification = nil
        }
    }
    
    
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
                print("Failed to schedule notification: \(error)")
            } else {
                print("Notification scheduled: \(identifier)")
            }
        }
    }
    
    
    func notifySuccessfulLogin(username: String) {
        print("Sending login notification for \(username)")
        
        // In-app welcome message
        let welcomeNotification = InAppNotification(
            type: .success,
            title: "Welcome to FitBuddy",
            message: "Hello \(username)! Your fitness journey continues here. Let's make today count.",
            duration: 4.0
        )
        showInAppNotification(welcomeNotification)
        
        // Send local push notification if authorized
        if isAuthorized {
            sendLocalNotification(
                title: "Welcome Back, \(username)!",
                body: "Ready to continue your fitness journey? Your goals are waiting for you.",
                delay: 2.0
            )
            
            // Start notification system
            startMotivationNotifications()
        }
    }
    
    func notifyGoalCompleted(goalType: String, value: String, isDaily: Bool = true) {
        let timeFrame = isDaily ? "daily" : "weekly"
        let celebration = isDaily ? "Excellent work" : "Outstanding achievement"
        
        print("Sending goal completion notification for \(goalType)")
        
        // In-app notification
        let notification = InAppNotification(
            type: .achievement,
            title: "Goal Completed",
            message: "\(celebration)! You've reached your \(timeFrame) \(goalType) goal of \(value). Keep building these healthy habits.",
            duration: 4.5
        )
        showInAppNotification(notification)
        
        // Send local push notification if authorized
        if isAuthorized {
            sendLocalNotification(
                title: "\(timeFrame.capitalized) Goal Achieved!",
                body: "Congratulations! You completed your \(goalType) goal of \(value). Keep up the amazing work!",
                delay: 1.0
            )
        }
    }
    
    func notifyChallengeEnrolled(challengeName: String) {
        print("Sending challenge enrollment notification for \(challengeName)")
        
        // In-app notification
        let notification = InAppNotification(
            type: .success,
            title: "Challenge Joined",
            message: "Welcome to \(challengeName)! You're now part of an exciting fitness journey. Let's track your progress and achieve greatness together.",
            duration: 4.0
        )
        showInAppNotification(notification)
        
        // Send local push notification if authorized
        if isAuthorized {
            sendLocalNotification(
                title: "Challenge Joined: \(challengeName)",
                body: "You're all set! Start working towards your new fitness challenge today.",
                delay: 1.0
            )
        }
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
                print("Failed to schedule weekly notification: \(error)")
            } else {
                print("Weekly notification scheduled: \(identifier)")
            }
        }
    }
    
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        stopMotivationNotifications()
        print("All notifications cancelled")
    }
    
    func cancelNotification(identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        print("Cancelled notification: \(identifier)")
    }
    
    
    func setMotivationNotificationsEnabled(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: "motivationNotificationsEnabled")
        
        if enabled && isAuthorized {
            startMotivationNotifications()
        } else {
            stopMotivationNotifications()
        }
    }
    
    func isMotivationNotificationsEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey: "motivationNotificationsEnabled")
    }
    
    func set3MinuteRemindersEnabled(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: "3MinuteRemindersEnabled")
        
        if enabled && isAuthorized {
            start3MinuteReminders()
        } else {
            stop3MinuteReminders()
        }
    }
    
    func is3MinuteRemindersEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey: "3MinuteRemindersEnabled")
    }
    
    func setGoalNotificationsEnabled(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: "goalNotificationsEnabled")
    }
    
    func isGoalNotificationsEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey: "goalNotificationsEnabled")
    }
    
    func setWorkoutRemindersEnabled(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: "workoutRemindersEnabled")
    }
    
    func isWorkoutRemindersEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey: "workoutRemindersEnabled")
    }
    
    
    private func sendLocalNotification(title: String, body: String, delay: TimeInterval = 1.0) {
        guard isAuthorized else {
            print("Cannot send local notification - not authorized")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to send local notification: \(error)")
            } else {
                print("Local notification scheduled: \(title)")
            }
        }
    }
}


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
        case motivation
        case update
        
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
            case .motivation:
                return .hydrationTeal
            case .update:
                return .lightBlue
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
            case .motivation:
                return "heart.circle.fill"
            case .update:
                return "arrow.clockwise.circle.fill"
            }
        }
    }
}


extension NotificationService {
    // Handle notification when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print(" Notification received while app is active")
        // Show notification even when app is active
        completionHandler([.alert, .badge, .sound])
    }
    
    // Handle notification tap
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print(" User tapped notification: \(response.notification.request.content.title)")
        completionHandler()
    }
}
