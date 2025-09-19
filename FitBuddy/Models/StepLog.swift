// Step tracking models with workout sessions

import Foundation
import FirebaseFirestore

struct StepLog: Codable, Identifiable {
    @DocumentID var id: String?
    var date: Date
    var steps: Int
    var distance: Double // km
    var calories: Int
    var activeMinutes: Int
    var goalSteps: Int
    var userId: String
    var lastUpdated: Date
    
    init(date: Date = Date(), steps: Int = 0, distance: Double = 0.0, calories: Int = 0, activeMinutes: Int = 0, goalSteps: Int = 10000, userId: String) {
        self.date = date
        self.steps = steps
        self.distance = distance
        self.calories = calories
        self.activeMinutes = activeMinutes
        self.goalSteps = goalSteps
        self.userId = userId
        self.lastUpdated = Date()
    }
    
    var progressPercentage: Double {
        return min(Double(steps) / Double(goalSteps), 1.0)
    }
    
    var isGoalAchieved: Bool {
        return steps >= goalSteps
    }
}

struct WorkoutSession: Codable, Identifiable {
    @DocumentID var id: String?
    var userId: String
    var startTime: Date
    var endTime: Date?
    var pausedDuration: TimeInterval // Total time paused
    var startSteps: Int
    var endSteps: Int
    var totalSteps: Int
    var distance: Double // km
    var calories: Int
    var status: WorkoutStatus
    var sessionType: WorkoutType
    var lastUpdated: Date
    
    init(userId: String, startSteps: Int, sessionType: WorkoutType = .walking) {
        self.userId = userId
        self.startTime = Date()
        self.startSteps = startSteps
        self.endSteps = startSteps
        self.totalSteps = 0
        self.distance = 0.0
        self.calories = 0
        self.pausedDuration = 0
        self.status = .active
        self.sessionType = sessionType
        self.lastUpdated = Date()
    }
    
    var duration: TimeInterval {
        let end = endTime ?? Date()
        return end.timeIntervalSince(startTime) - pausedDuration
    }
    
    var isActive: Bool {
        return status == .active || status == .paused
    }
}

enum WorkoutStatus: String, Codable, CaseIterable {
    case active = "active"
    case paused = "paused"
    case completed = "completed"
    case cancelled = "cancelled"
}

enum WorkoutType: String, Codable, CaseIterable {
    case walking = "walking"
    case running = "running"
    case general = "general"
}
