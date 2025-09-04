// WorkoutService.swift
import Foundation
import Firebase
import FirebaseFirestore
import Combine

class WorkoutService: ObservableObject {
    static let shared = WorkoutService()
    
    private let db = Firestore.firestore()
    private let authService = AuthService.shared
    
    @Published var recentWorkouts: [WorkoutLog] = []
    @Published var isLoading = false
    
    private init() {}
    
    // MARK: - Workout Session Management
    
    func saveWorkout(type: String, duration: Int, calories: Int, completion: @escaping (Result<String, Error>) -> Void) {
        guard let userId = authService.currentUserId else {
            completion(.failure(NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        let workoutData: [String: Any] = [
            "type": type,
            "duration": duration,
            "calories": calories,
            "date": Timestamp(),
            "userId": userId
        ]
        
        db.collection("users").document(userId).collection("workouts").addDocument(data: workoutData) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                print("✅ Workout saved: \(type) - \(duration) minutes - \(calories) calories")
                completion(.success("Workout saved successfully"))
                
                // Refresh recent workouts
                self.fetchRecentWorkouts()
            }
        }
    }
    
    func saveWorkoutSession(_ workout: WorkoutLog, completion: @escaping (Result<String, Error>) -> Void) {
        guard let userId = authService.currentUserId else {
            completion(.failure(NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        do {
            let workoutData = try Firestore.Encoder().encode(workout)
            db.collection("users").document(userId).collection("workouts").addDocument(data: workoutData) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    print("✅ Workout session saved: \(workout.workoutType)")
                    completion(.success("Workout session saved successfully"))
                    
                    // Refresh recent workouts
                    self.fetchRecentWorkouts()
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    // MARK: - Fetch Workouts
    
    func fetchRecentWorkouts(limit: Int = 10) {
        guard let userId = authService.currentUserId else {
            print("❌ No authenticated user for fetching workouts")
            return
        }
        
        isLoading = true
        
        db.collection("users").document(userId).collection("workouts")
            .order(by: "date", descending: true)
            .limit(to: limit)
            .getDocuments { [weak self] snapshot, error in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    
                    if let error = error {
                        print("❌ Error fetching workouts: \(error.localizedDescription)")
                        return
                    }
                    
                    var workouts: [WorkoutLog] = []
                    snapshot?.documents.forEach { document in
                        let data = document.data()
                        if let type = data["type"] as? String,
                           let duration = data["duration"] as? Int,
                           let calories = data["calories"] as? Int,
                           let timestamp = data["date"] as? Timestamp {
                            
                            let workout = WorkoutLog(
                                id: UUID(),
                                workoutType: type,
                                duration: duration,
                                caloriesBurned: calories,
                                date: timestamp.dateValue()
                            )
                            workouts.append(workout)
                        }
                    }
                    
                    self?.recentWorkouts = workouts
                    print("✅ Fetched \(workouts.count) recent workouts")
                }
            }
    }
    
    func getWorkoutsForDateRange(startDate: Date, endDate: Date, completion: @escaping (Result<[WorkoutLog], Error>) -> Void) {
        guard let userId = authService.currentUserId else {
            completion(.failure(NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        db.collection("users").document(userId).collection("workouts")
            .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: startDate))
            .whereField("date", isLessThanOrEqualTo: Timestamp(date: endDate))
            .order(by: "date", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                var workouts: [WorkoutLog] = []
                snapshot?.documents.forEach { document in
                    let data = document.data()
                    if let type = data["type"] as? String,
                       let duration = data["duration"] as? Int,
                       let calories = data["calories"] as? Int,
                       let timestamp = data["date"] as? Timestamp {
                        
                        let workout = WorkoutLog(
                            id: UUID(),
                            workoutType: type,
                            duration: duration,
                            caloriesBurned: calories,
                            date: timestamp.dateValue()
                        )
                        workouts.append(workout)
                    }
                }
                completion(.success(workouts))
            }
    }
    
    // MARK: - Workout Statistics
    
    func getTotalWorkoutTime(for date: Date, completion: @escaping (Result<Int, Error>) -> Void) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        getWorkoutsForDateRange(startDate: startOfDay, endDate: endOfDay) { result in
            switch result {
            case .success(let workouts):
                let totalMinutes = workouts.reduce(0) { $0 + $1.duration }
                completion(.success(totalMinutes))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getTotalCaloriesBurned(for date: Date, completion: @escaping (Result<Int, Error>) -> Void) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        getWorkoutsForDateRange(startDate: startOfDay, endDate: endOfDay) { result in
            switch result {
            case .success(let workouts):
                let totalCalories = workouts.reduce(0) { $0 + $1.caloriesBurned }
                completion(.success(totalCalories))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Test Functions
    
    func testWorkoutSave() {
        saveWorkout(type: "Test Workout", duration: 30, calories: 200) { result in
            switch result {
            case .success(let message):
                print("✅ Test workout saved: \(message)")
            case .failure(let error):
                print("❌ Failed to save workout: \(error.localizedDescription)")
            }
        }
    }
    
    func getWorkoutHistory(completion: @escaping (Result<[WorkoutLog], Error>) -> Void) {
        guard let userId = authService.currentUserId else {
            completion(.failure(NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        db.collection("users").document(userId).collection("workouts")
            .order(by: "date", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                var workouts: [WorkoutLog] = []
                snapshot?.documents.forEach { document in
                    do {
                        let workout = try document.data(as: WorkoutLog.self)
                        workouts.append(workout)
                    } catch {
                        print("Error decoding workout: \(error)")
                    }
                }
                
                DispatchQueue.main.async {
                    completion(.success(workouts))
                }
            }
    }
    
    func getTotalWorkoutMinutes(completion: @escaping (Result<Int, Error>) -> Void) {
        getWorkoutHistory { result in
            switch result {
            case .success(let workouts):
                let totalMinutes = workouts.reduce(0.0) { $0 + Double($1.duration) }
                completion(.success(Int(totalMinutes / 60))) // Convert to minutes
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getTotalCaloriesBurned(completion: @escaping (Result<Int, Error>) -> Void) {
        getWorkoutHistory { result in
            switch result {
            case .success(let workouts):
                let totalCalories = workouts.reduce(0) { $0 + $1.caloriesBurned }
                completion(.success(totalCalories))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
