//
//  ChallengeService.swift
//  FitBuddy
//
//  Service for managing challenges with notifications
//

import Foundation
import Firebase
import FirebaseFirestore

class ChallengeService: ObservableObject {
    static let shared = ChallengeService()
    
    private let db = Firestore.firestore()
    private let authService = AuthService.shared
    private let notificationService = NotificationService.shared
    
    @Published var enrolledChallenges: [Challenge] = []
    @Published var availableChallenges: [Challenge] = []
    @Published var isLoading = false
    
    private init() {
        loadChallenges()
    }
    
    func enrollInChallenge(_ challenge: Challenge) {
        guard let userId = authService.currentUserId else { return }
        
        isLoading = true
        
        var updatedChallenge = challenge
        updatedChallenge.isJoined = true
        
        let challengeData: [String: Any] = [
            "id": challenge.id.uuidString,
            "name": challenge.name,
            "type": challenge.type,
            "goal": challenge.goal,
            "isJoined": true,
            "enrolledDate": Timestamp(date: Date()),
            "progress": 0,
            "isCompleted": false
        ]
        
        db.collection("users").document(userId).collection("challenges").document(challenge.id.uuidString).setData(challengeData) { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if error == nil {
                    // Update local state
                    self?.enrolledChallenges.append(updatedChallenge)
                    
                    // Remove from available challenges
                    self?.availableChallenges.removeAll { $0.id == challenge.id }
                    
                    // Show notification
                    self?.notificationService.notifyChallengeEnrolled(challengeName: challenge.name)
                    
                    print("Successfully enrolled in challenge: \(challenge.name)")
                } else {
                    print("Failed to enroll in challenge: \(error?.localizedDescription ?? "")")
                }
            }
        }
    }
    
    func completeChallenge(_ challengeId: UUID) {
        guard let userId = authService.currentUserId else { return }
        
        // Find the challenge
        guard let challengeIndex = enrolledChallenges.firstIndex(where: { $0.id == challengeId }) else { return }
        
        let challenge = enrolledChallenges[challengeIndex]
        
        // Update in Firebase
        db.collection("users").document(userId).collection("challenges").document(challengeId.uuidString).updateData([
            "isCompleted": true,
            "completedDate": Timestamp(date: Date()),
            "progress": challenge.goal
        ]) { [weak self] error in
            DispatchQueue.main.async {
                if error == nil {
                    // Update local state
                    self?.enrolledChallenges[challengeIndex].isJoined = false // Mark as completed
                    
                    // Show completion notification
                    self?.notificationService.notifyChallengeCompleted(challengeName: challenge.name)
                    
                    print("Challenge completed: \(challenge.name)")
                } else {
                    print("Failed to complete challenge: \(error?.localizedDescription ?? "")")
                }
            }
        }
    }
    
    func updateChallengeProgress(_ challengeId: UUID, progress: Int) {
        guard let userId = authService.currentUserId else { return }
        
        // Find the challenge
        guard let challengeIndex = enrolledChallenges.firstIndex(where: { $0.id == challengeId }) else { return }
        
        let challenge = enrolledChallenges[challengeIndex]
        
        // Check if challenge is completed
        if progress >= challenge.goal {
            completeChallenge(challengeId)
            return
        }
        
        // Update progress in Firebase
        db.collection("users").document(userId).collection("challenges").document(challengeId.uuidString).updateData([
            "progress": progress,
            "lastUpdated": Timestamp(date: Date())
        ]) { error in
            if let error = error {
                print("Failed to update challenge progress: \(error.localizedDescription)")
            } else {
                print("Challenge progress updated: \(progress)/\(challenge.goal)")
            }
        }
    }
    
    private func loadChallenges() {
        availableChallenges = createSampleChallenges()
        
        loadEnrolledChallenges()
    }
    
    private func loadEnrolledChallenges() {
        guard let userId = authService.currentUserId else { return }
        
        db.collection("users").document(userId).collection("challenges")
            .whereField("isJoined", isEqualTo: true)
            .whereField("isCompleted", isEqualTo: false)
            .getDocuments { [weak self] snapshot, error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("Failed to load enrolled challenges: \(error.localizedDescription)")
                        return
                    }
                    
                    guard let documents = snapshot?.documents else { return }
                    
                    self?.enrolledChallenges = documents.compactMap { doc -> Challenge? in
                        let data = doc.data()
                        guard let idString = data["id"] as? String,
                              let id = UUID(uuidString: idString),
                              let name = data["name"] as? String,
                              let type = data["type"] as? String,
                              let goal = data["goal"] as? Int else { return nil }
                        
                        return Challenge(id: id, name: name, type: type, goal: goal, isJoined: true)
                    }
                    
                    // Remove enrolled challenges from available list
                    let enrolledIds = self?.enrolledChallenges.map { $0.id } ?? []
                    self?.availableChallenges.removeAll { enrolledIds.contains($0.id) }
                }
            }
    }
    
    private func createSampleChallenges() -> [Challenge] {
        return [
            Challenge(
                id: UUID(),
                name: "10K Steps Daily",
                type: "steps",
                goal: 10000,
                isJoined: false
            ),
            Challenge(
                id: UUID(),
                name: "Hydration Hero",
                type: "water",
                goal: 2000, // 2L in ml
                isJoined: false
            ),
            Challenge(
                id: UUID(),
                name: "7-Day Consistency",
                type: "consistency",
                goal: 7,
                isJoined: false
            ),
            Challenge(
                id: UUID(),
                name: "Weekend Warrior",
                type: "workout",
                goal: 2, // 2 workouts over weekend
                isJoined: false
            ),
            Challenge(
                id: UUID(),
                name: "Step Master",
                type: "steps",
                goal: 50000, // 50K steps in a week
                isJoined: false
            )
        ]
    }
    
    func checkStepChallenges(currentSteps: Int) {
        for challenge in enrolledChallenges.filter({ $0.type == "steps" }) {
            updateChallengeProgress(challenge.id, progress: currentSteps)
        }
    }
    
    func checkWaterChallenges(currentWaterML: Int) {
        for challenge in enrolledChallenges.filter({ $0.type == "water" }) {
            updateChallengeProgress(challenge.id, progress: currentWaterML)
        }
    }
    
    func checkWorkoutChallenges(completedWorkouts: Int) {
        for challenge in enrolledChallenges.filter({ $0.type == "workout" }) {
            updateChallengeProgress(challenge.id, progress: completedWorkouts)
        }
    }
    
    func checkWeeklyGoals() {
        let mockWeeklyWorkouts = 5
        if mockWeeklyWorkouts >= 5 {
            notificationService.notifyWeeklyGoalCompleted(goalType: "workout")
        }
        
        // Example: Check if user maintained daily step goal for 7 days
        let mockConsistentDays = 7
        if mockConsistentDays >= 7 {
            notificationService.notifyWeeklyGoalCompleted(goalType: "consistency")
        }
    }
}