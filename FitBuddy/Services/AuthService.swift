// AuthService.swift
import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import Combine

class AuthService: ObservableObject {
    static let shared = AuthService()
    
    @Published var isUserLoggedIn = false
    @Published var currentUser: User?
    
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    
    private init() {
        // Always start with user logged out - sign out any existing session
        try? auth.signOut()
        
        // Listen for authentication state changes
        auth.addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.isUserLoggedIn = user != nil
                if let user = user {
                    self?.fetchUserData(uid: user.uid)
                    // Notify other services that user is authenticated
                    self?.notifyServicesOfAuthChange()
                } else {
                    self?.currentUser = nil
                }
            }
        }
    }
    
    // MARK: - Authentication
    
    func signUp(email: String, password: String, name: String, completion: @escaping (Result<String, Error>) -> Void) {
        auth.createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                let nsError = error as NSError
                
                // Handle specific Firebase errors
                if nsError.code == AuthErrorCode.emailAlreadyInUse.rawValue {
                    completion(.failure(NSError(domain: "SignUpError", code: 0, userInfo: [NSLocalizedDescriptionKey: "This email is already registered. Try logging in instead, or use a different email address."])))
                } else if nsError.code == AuthErrorCode.invalidEmail.rawValue {
                    completion(.failure(NSError(domain: "SignUpError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Please enter a valid email address."])))
                } else if nsError.code == AuthErrorCode.weakPassword.rawValue {
                    completion(.failure(NSError(domain: "SignUpError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Password is too weak. Please use at least 6 characters."])))
                } else {
                    // For the specific issue you're facing, provide a helpful message
                    completion(.failure(NSError(domain: "SignUpError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Registration failed. If you recently deleted this account, please wait a few minutes and try again, or use a different email address."])))
                }
                return
            }
            
            guard let user = result?.user else {
                completion(.failure(NSError(domain: "SignUpError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to create user"])))
                return
            }
            
            // Save user data to Firestore
            self?.saveUserData(uid: user.uid, name: name, email: email) { result in
                switch result {
                case .success:
                    // Don't sign out automatically - let user manually login
                    // Sign out immediately after account creation to prevent auto-login
                    try? self?.auth.signOut()
                    completion(.success("Account created successfully! Please log in with your credentials."))
                case .failure(let error):
                    completion(.failure(error))
                }
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
        do {
            try auth.signOut()
            DispatchQueue.main.async {
                self.currentUser = nil
                self.isUserLoggedIn = false
                // Clear any cached data in other services
                StepService.shared.resetData()
                WaterService.shared.resetData()
            }
            print("✅ User signed out successfully")
        } catch {
            print("❌ Error signing out: \(error.localizedDescription)")
        }
    }
    
    // MARK: - User Data Management
    
    private func saveUserData(uid: String, name: String, email: String, completion: @escaping (Result<String, Error>) -> Void) {
        let userData: [String: Any] = [
            "name": name,
            "email": email,
            "createdAt": Timestamp(),
            "dailyStepGoal": 10000,
            "dailyWaterGoal": 3000.0,
            "age": 25,
            "weight": 70.0,
            "height": 170.0,
            "gender": "Other"
        ]
        
        db.collection("users").document(uid).setData(userData) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                print("✅ User data saved successfully")
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
                   let stepGoal = data?["dailyStepGoal"] as? Int,
                   let waterGoal = data?["dailyWaterGoal"] as? Double,
                   let age = data?["age"] as? Int,
                   let weight = data?["weight"] as? Double {
                    
                    DispatchQueue.main.async {
                        self?.currentUser = User(
                            id: UUID(),
                            name: name,
                            age: age,
                            weight: weight,
                            dailyStepGoal: stepGoal,
                            dailyWaterGoal: waterGoal
                        )
                        print("✅ User data loaded: \(name)")
                    }
                }
            }
        }
    }
    
    func updateUserProfile(_ user: User, completion: @escaping (Result<String, Error>) -> Void) {
        guard let uid = auth.currentUser?.uid else {
            completion(.failure(NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        let userData: [String: Any] = [
            "name": user.name,
            "age": user.age,
            "weight": user.weight,
            "dailyStepGoal": user.dailyStepGoal,
            "dailyWaterGoal": user.dailyWaterGoal
        ]
        
        db.collection("users").document(uid).updateData(userData) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                print("✅ User profile updated successfully")
                completion(.success("Profile updated successfully"))
            }
        }
    }
    
    // MARK: - Helpers
    
    private func notifyServicesOfAuthChange() {
        // Load initial data for other services when user logs in
        StepService.shared.loadTodaySteps()
        WaterService.shared.loadTodayWater()
    }
    
    // MARK: - Debug & Admin Methods
    
    func clearAllAuthenticationData() {
        // Sign out current user
        try? auth.signOut()
        
        // Clear all local data
        DispatchQueue.main.async {
            self.currentUser = nil
            self.isUserLoggedIn = false
            StepService.shared.resetData()
            WaterService.shared.resetData()
        }
        
        print("✅ All authentication data cleared")
    }
    
    func deleteUserFromFirestore(email: String, completion: @escaping (Result<String, Error>) -> Void) {
        // This will delete the user's Firestore data
        // Note: You need to implement this based on how you want to find the user
        // since we only have email, not UID
        print("🗑️ Attempting to delete Firestore data for: \(email)")
        // Implementation would go here if needed
        completion(.success("Firestore cleanup attempted"))
    }
    
    var currentUserId: String? {
        return auth.currentUser?.uid
    }
    
    func printCurrentUserInfo() {
        if let user = auth.currentUser {
            print("🔐 Current User:")
            print("   UID: \(user.uid)")
            print("   Email: \(user.email ?? "No email")")
            print("   Is Verified: \(user.isEmailVerified)")
        } else {
            print("❌ No user currently signed in")
        }
    }
}
