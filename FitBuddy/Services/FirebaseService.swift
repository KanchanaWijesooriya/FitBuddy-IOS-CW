// FirebaseService.swift
import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

class FirebaseService: ObservableObject {
    @Published var isUserLoggedIn = false
    @Published var currentUser: User?
    
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    
    init() {
        // Listen for authentication state changes
        _ = auth.addStateDidChangeListener { [weak self] _, user in
            self?.isUserLoggedIn = user != nil
            if let user = user {
                self?.fetchUserData(uid: user.uid)
            } else {
                self?.currentUser = nil
            }
        }
    }
    
    // MARK: - Authentication
    func signUp(email: String, password: String, name: String, completion: @escaping (Result<String, Error>) -> Void) {
        auth.createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let user = result?.user else {
                completion(.failure(NSError(domain: "SignUpError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to create user"])))
                return
            }
            
            // Save user data to Firestore
            self?.saveUserData(uid: user.uid, name: name, email: email) { result in
                completion(result)
            }
        }
    }
    
    func signIn(email: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        auth.signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success("Login successful"))
            }
        }
    }
    
    func signOut() {
        try? auth.signOut()
    }
    
    // MARK: - Firestore Operations
    private func saveUserData(uid: String, name: String, email: String, completion: @escaping (Result<String, Error>) -> Void) {
        let userData: [String: Any] = [
            "name": name,
            "email": email,
            "createdAt": Timestamp(),
            "dailyStepGoal": 10000,
            "dailyWaterGoal": 2000.0
        ]
        
        db.collection("users").document(uid).setData(userData) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success("User data saved successfully"))
            }
        }
    }
    
    private func fetchUserData(uid: String) {
        db.collection("users").document(uid).getDocument { [weak self] document, error in
            if let document = document, document.exists {
                let data = document.data()
                // Convert Firestore data to User model
                if let name = data?["name"] as? String,
                   let _ = data?["email"] as? String,
                   let stepGoal = data?["dailyStepGoal"] as? Int,
                   let waterGoal = data?["dailyWaterGoal"] as? Double {
                    
                    DispatchQueue.main.async {
                        self?.currentUser = User(
                            id: UUID(),
                            name: name,
                            age: 25, // Default values - can be updated later
                            weight: 70.0,
                            dailyStepGoal: stepGoal,
                            dailyWaterGoal: waterGoal
                        )
                    }
                }
            }
        }
    }
    
    // MARK: - Workout Operations
    func saveWorkout(type: String, duration: TimeInterval, completion: @escaping (Result<String, Error>) -> Void) {
        guard let uid = auth.currentUser?.uid else {
            completion(.failure(NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        let workoutData: [String: Any] = [
            "type": type,
            "duration": duration,
            "date": Timestamp(),
            "userId": uid
        ]
        
        db.collection("workouts").addDocument(data: workoutData) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success("Workout saved successfully"))
            }
        }
    }
    
    func getWorkouts(completion: @escaping (Result<[WorkoutLog], Error>) -> Void) {
        guard let uid = auth.currentUser?.uid else {
            completion(.failure(NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        db.collection("workouts")
            .whereField("userId", isEqualTo: uid)
            .order(by: "date", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion(.success([]))
                    return
                }
                
                var workouts: [WorkoutLog] = []
                for document in documents {
                    let data = document.data()
                    if let type = data["type"] as? String,
                       let duration = data["duration"] as? TimeInterval,
                       let calories = data["calories"] as? Int,
                       let timestamp = data["date"] as? Timestamp {
                        
                        let workout = WorkoutLog(
                            workoutType: type,
                            duration: Int(duration),
                            caloriesBurned: calories,
                            date: timestamp.dateValue()
                        )
                        workouts.append(workout)
                    }
                }
                completion(.success(workouts))
            }
    }
    
    // MARK: - Step Operations
    func saveStepCount(_ steps: Int, date: Date, completion: @escaping (Result<String, Error>) -> Void) {
        guard let uid = auth.currentUser?.uid else {
            completion(.failure(NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        let stepData: [String: Any] = [
            "steps": steps,
            "date": Timestamp(date: date),
            "userId": uid
        ]
        
        db.collection("steps").addDocument(data: stepData) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success("Steps saved successfully"))
            }
        }
    }
    
    // MARK: - Water Operations
    func saveWaterIntake(_ amount: Double, date: Date, completion: @escaping (Result<String, Error>) -> Void) {
        guard let uid = auth.currentUser?.uid else {
            completion(.failure(NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        let waterData: [String: Any] = [
            "amount": amount,
            "date": Timestamp(date: date),
            "userId": uid
        ]
        
        db.collection("water").addDocument(data: waterData) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success("Water intake saved successfully"))
            }
        }
    }
}
