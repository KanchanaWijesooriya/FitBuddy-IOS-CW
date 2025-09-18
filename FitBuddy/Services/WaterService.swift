// WaterService.swift
import Foundation
import Firebase
import FirebaseFirestore
import Combine
import UIKit

class WaterService: ObservableObject {
    static let shared = WaterService()
    
    private let db = Firestore.firestore()
    private let authService = AuthService.shared
    
    @Published var todayWater: Double = 0.0 // in liters
    @Published var isLoading = false
    @Published var lastLoadedDate: Date = Date()
    
    private init() {
        // Only load today's water if user is authenticated
        if authService.currentUserId != nil {
            loadTodayWater()
        }
        
        // Set up daily reset check
        setupDailyResetCheck()
    }
    
    // MARK: - Reset Method
    func resetData() {
        DispatchQueue.main.async {
            self.todayWater = 0.0
            self.isLoading = false
            self.lastLoadedDate = Date()
        }
    }
    
    // MARK: - Daily Reset Check
    private func setupDailyResetCheck() {
        // Check for day change every time the app becomes active
        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.checkForDayChange()
        }
    }
    
    func checkForDayChange() {
        let calendar = Calendar.current
        if !calendar.isDate(lastLoadedDate, inSameDayAs: Date()) {
            // New day detected, reload today's water data
            lastLoadedDate = Date()
            loadTodayWater()
        }
    }
    
    // MARK: - Water Management
    
    func saveWater(amount: Double, date: Date = Date(), completion: @escaping (Result<String, Error>) -> Void) {
        guard let userId = authService.currentUserId else {
            completion(.failure(NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        
        let waterData: [String: Any] = [
            "amount": amount,
            "date": Timestamp(date: date),
            "userId": userId,
            "lastUpdated": Timestamp()
        ]
        
        db.collection("users").document(userId).collection("water").document(dateString).setData(waterData, merge: true) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                print("✅ Water saved: \(amount)L on \(dateString)")
                completion(.success("Water intake saved successfully"))
            }
        }
    }
    
    func getWaterForDate(date: Date, completion: @escaping (Result<Double, Error>) -> Void) {
        guard let userId = authService.currentUserId else {
            completion(.failure(NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        
        db.collection("users").document(userId).collection("water").document(dateString).getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let data = snapshot?.data(),
               let amount = data["amount"] as? Double {
                completion(.success(amount))
            } else {
                completion(.success(0.0)) // No data for this date
            }
        }
    }
    
    func loadTodayWater() {
        guard authService.currentUserId != nil else {
            // Silently return if user is not authenticated
            return
        }
        
        getWaterForDate(date: Date()) { [weak self] result in
            switch result {
            case .success(let amount):
                DispatchQueue.main.async {
                    self?.todayWater = amount
                    self?.lastLoadedDate = Date()
                }
            case .failure(let error):
                print("❌ Failed to load today's water: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Water Statistics
    
    func getWeeklyWater(completion: @escaping (Result<[WaterLog], Error>) -> Void) {
        guard let userId = authService.currentUserId else {
            completion(.failure(NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        let calendar = Calendar.current
        let today = Date()
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today
        let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek) ?? today
        
        db.collection("users").document(userId).collection("water")
            .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: startOfWeek))
            .whereField("date", isLessThanOrEqualTo: Timestamp(date: endOfWeek))
            .order(by: "date")
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                var waterLogs: [WaterLog] = []
                snapshot?.documents.forEach { document in
                    let data = document.data()
                    if let amount = data["amount"] as? Double,
                       let timestamp = data["date"] as? Timestamp {
                        
                        let waterLog = WaterLog(
                            date: timestamp.dateValue(),
                            amount: amount
                        )
                        waterLogs.append(waterLog)
                    }
                }
                completion(.success(waterLogs))
            }
    }
    
    func getMonthlyWater(completion: @escaping (Result<[WaterLog], Error>) -> Void) {
        guard let userId = authService.currentUserId else {
            completion(.failure(NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        let calendar = Calendar.current
        let today = Date()
        let startOfMonth = calendar.dateInterval(of: .month, for: today)?.start ?? today
        let endOfMonth = calendar.dateInterval(of: .month, for: today)?.end ?? today
        
        db.collection("users").document(userId).collection("water")
            .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: startOfMonth))
            .whereField("date", isLessThan: Timestamp(date: endOfMonth))
            .order(by: "date")
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                var waterLogs: [WaterLog] = []
                snapshot?.documents.forEach { document in
                    let data = document.data()
                    if let amount = data["amount"] as? Double,
                       let timestamp = data["date"] as? Timestamp {
                        
                        let waterLog = WaterLog(
                            date: timestamp.dateValue(),
                            amount: amount
                        )
                        waterLogs.append(waterLog)
                    }
                }
                completion(.success(waterLogs))
            }
    }
    
    func getWaterProgress(for date: Date, completion: @escaping (Result<Double, Error>) -> Void) {
        getWaterForDate(date: date) { result in
            switch result {
            case .success(let amount):
                let goal = AuthService.shared.currentUser?.dailyWaterGoal ?? 2.5
                let progress = min(amount / goal, 1.0)
                completion(.success(progress))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Real-time Updates
    
    func addWater(amount: Double) {
        let previousTotal = todayWater
        let newTotal = todayWater + amount
        let dailyGoal = 2.0 // 2 liters daily goal
        
        // Update the UI immediately to prevent navigation issues
        DispatchQueue.main.async {
            self.todayWater = newTotal
        }
        
        saveWater(amount: newTotal) { result in
            switch result {
            case .success:
                print("✅ Water added: \(amount)L")
                
                // Check for goal achievements
                self.checkWaterGoalAchievements(previous: previousTotal, current: newTotal, goal: dailyGoal)
                
            case .failure(let error):
                print("❌ Failed to add water: \(error.localizedDescription)")
                // Revert the UI update if save failed
                DispatchQueue.main.async {
                    self.todayWater = previousTotal
                }
            }
        }
    }
    
    private func checkWaterGoalAchievements(previous: Double, current: Double, goal: Double) {
        let notificationService = NotificationService.shared
        let challengeService = ChallengeService.shared
        
        // Check challenge progress (convert to ml)
        challengeService.checkWaterChallenges(currentWaterML: Int(current * 1000))
        
        // Check if daily goal was completed
        if previous < goal && current >= goal {
            let goalText = String(format: "%.1fL", goal)
            notificationService.notifyDailyGoalCompleted(goalType: "hydration", value: goalText)
        }
        // Check if reached halfway point
        else if previous < (goal * 0.5) && current >= (goal * 0.5) {
            let progress = "50%"
            notificationService.notifyHalfwayGoal(goalType: "hydration", progress: progress)
        }
    }
    
    // Common water amounts in liters
    func addCup() { addWater(amount: 0.25) } // 250ml
    func addBottle() { addWater(amount: 0.5) } // 500ml
    func addLargeBottle() { addWater(amount: 1.0) } // 1L
    
    // MARK: - Test Functions
    
    func testWaterSave() {
        saveWater(amount: 1.5) { result in
            switch result {
            case .success(let message):
                print("✅ Test water saved: \(message)")
            case .failure(let error):
                print("❌ Failed to save water: \(error.localizedDescription)")
            }
        }
    }
}
