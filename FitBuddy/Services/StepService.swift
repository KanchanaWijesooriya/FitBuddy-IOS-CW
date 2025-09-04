// StepService.swift
import Foundation
import Firebase
import FirebaseFirestore
import Combine

class StepService: ObservableObject {
    static let shared = StepService()
    
    private let db = Firestore.firestore()
    private let authService = AuthService.shared
    
    @Published var todaySteps: Int = 0
    @Published var isLoading = false
    
    private init() {
        // Only load today's steps if user is authenticated
        if authService.currentUserId != nil {
            loadTodaySteps()
        }
    }
    
    // MARK: - Reset Method
    func resetData() {
        DispatchQueue.main.async {
            self.todaySteps = 0
            self.isLoading = false
        }
    }
    
    // MARK: - Step Management
    
    func saveSteps(steps: Int, date: Date = Date(), completion: @escaping (Result<String, Error>) -> Void) {
        guard let userId = authService.currentUserId else {
            completion(.failure(NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        
        let stepData: [String: Any] = [
            "steps": steps,
            "date": Timestamp(date: date),
            "userId": userId,
            "lastUpdated": Timestamp()
        ]
        
        db.collection("users").document(userId).collection("steps").document(dateString).setData(stepData, merge: true) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                print("✅ Steps saved: \(steps) steps on \(dateString)")
                completion(.success("Steps saved successfully"))
                
                // Update today's steps if it's today's date
                if Calendar.current.isDate(date, inSameDayAs: Date()) {
                    DispatchQueue.main.async {
                        self.todaySteps = steps
                    }
                }
            }
        }
    }
    
    func getStepsForDate(date: Date, completion: @escaping (Result<Int, Error>) -> Void) {
        guard let userId = authService.currentUserId else {
            completion(.failure(NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        
        db.collection("users").document(userId).collection("steps").document(dateString).getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let data = snapshot?.data(),
               let steps = data["steps"] as? Int {
                completion(.success(steps))
            } else {
                completion(.success(0)) // No data for this date
            }
        }
    }
    
    func loadTodaySteps() {
        guard authService.currentUserId != nil else {
            // Silently return if user is not authenticated
            return
        }
        
        getStepsForDate(date: Date()) { [weak self] result in
            switch result {
            case .success(let steps):
                DispatchQueue.main.async {
                    self?.todaySteps = steps
                }
            case .failure(let error):
                print("❌ Failed to load today's steps: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Step Statistics
    
    func getWeeklySteps(completion: @escaping (Result<[StepLog], Error>) -> Void) {
        guard let userId = authService.currentUserId else {
            completion(.failure(NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        let calendar = Calendar.current
        let today = Date()
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today
        let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek) ?? today
        
        db.collection("users").document(userId).collection("steps")
            .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: startOfWeek))
            .whereField("date", isLessThanOrEqualTo: Timestamp(date: endOfWeek))
            .order(by: "date")
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                var stepLogs: [StepLog] = []
                snapshot?.documents.forEach { document in
                    let data = document.data()
                    if let steps = data["steps"] as? Int,
                       let timestamp = data["date"] as? Timestamp {
                        
                        let stepLog = StepLog(
                            date: timestamp.dateValue(),
                            steps: steps
                        )
                        stepLogs.append(stepLog)
                    }
                }
                completion(.success(stepLogs))
            }
    }
    
    func getMonthlySteps(completion: @escaping (Result<[StepLog], Error>) -> Void) {
        guard let userId = authService.currentUserId else {
            completion(.failure(NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        let calendar = Calendar.current
        let today = Date()
        let startOfMonth = calendar.dateInterval(of: .month, for: today)?.start ?? today
        let endOfMonth = calendar.dateInterval(of: .month, for: today)?.end ?? today
        
        db.collection("users").document(userId).collection("steps")
            .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: startOfMonth))
            .whereField("date", isLessThan: Timestamp(date: endOfMonth))
            .order(by: "date")
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                var stepLogs: [StepLog] = []
                snapshot?.documents.forEach { document in
                    let data = document.data()
                    if let steps = data["steps"] as? Int,
                       let timestamp = data["date"] as? Timestamp {
                        
                        let stepLog = StepLog(
                            date: timestamp.dateValue(),
                            steps: steps
                        )
                        stepLogs.append(stepLog)
                    }
                }
                completion(.success(stepLogs))
            }
    }
    
    func getStepProgress(for date: Date, completion: @escaping (Result<Double, Error>) -> Void) {
        getStepsForDate(date: date) { result in
            switch result {
            case .success(let steps):
                let goal = AuthService.shared.currentUser?.dailyStepGoal ?? 10000
                let progress = min(Double(steps) / Double(goal), 1.0)
                completion(.success(progress))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Real-time Updates
    
    func incrementSteps(by amount: Int) {
        let newTotal = todaySteps + amount
        saveSteps(steps: newTotal) { result in
            switch result {
            case .success:
                print("✅ Steps incremented by \(amount)")
            case .failure(let error):
                print("❌ Failed to increment steps: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Test Functions
    
    func testStepsSave() {
        saveSteps(steps: 1500) { result in
            switch result {
            case .success(let message):
                print("✅ Test steps saved: \(message)")
            case .failure(let error):
                print("❌ Failed to save steps: \(error.localizedDescription)")
            }
        }
    }
}
