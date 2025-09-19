// AuthService.swift
import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import Combine
import LocalAuthentication
import Security

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
    _ = auth.addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.isUserLoggedIn = user != nil
                if let user = user {
                    self?.fetchUserData(uid: user.uid)
                    // Notify other services that user is authenticated
                    self?.notifyServicesOfAuthChange()
                } else {
                    self?.currentUser = nil
                    // Keep Face ID settings even when logged out
                    print("User logged out, Face ID setting preserved: \(UserDefaults.standard.bool(forKey: "FaceIDEnabled"))")
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
        auth.signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                completion(.failure(error))
            } else {
                // Save credentials for biometric login after successful authentication
                // Only if biometrics are available and Face ID is enabled (or first time)
                if self?.isBiometricAvailable() == true {
                    let faceIDEnabled = UserDefaults.standard.bool(forKey: "FaceIDEnabled")
                    let hasExistingCredentials = UserDefaults.standard.object(forKey: "FaceIDEnabled") != nil
                    
                    // Save if Face ID is enabled OR it's the first time (no preference set yet)
                    if faceIDEnabled || !hasExistingCredentials {
                        self?.saveBiometricCredentials(email: email, password: password)
                    }
                }
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
                // Don't delete biometric credentials on sign out - keep them for next login
            }
            print("User signed out successfully")
        } catch {
            print("❌ Error signing out: \(error.localizedDescription)")
        }
    }
    
    func deleteAccount(completion: @escaping (Result<String, Error>) -> Void) {
        guard let firebaseUser = auth.currentUser else {
            completion(.failure(NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No user is currently signed in"])))
            return
        }
        
        let uid = firebaseUser.uid
        
        // First delete user data from Firestore
        deleteUserDataFromFirestore(uid: uid) { [weak self] result in
            switch result {
            case .success:
                // Then delete the Firebase Auth user
                firebaseUser.delete { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        // Clear local data
                        DispatchQueue.main.async {
                            self?.clearAllLocalData()
                            self?.currentUser = nil
                            self?.isUserLoggedIn = false
                        }
                        completion(.success("Account deleted successfully"))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func deleteUserDataFromFirestore(uid: String, completion: @escaping (Result<String, Error>) -> Void) {
        let batch = db.batch()
        
        // Delete user document
        let userRef = db.collection("users").document(uid)
        batch.deleteDocument(userRef)
        
        // Delete user's step logs
        db.collection("stepLogs").whereField("userId", isEqualTo: uid).getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            snapshot?.documents.forEach { document in
                batch.deleteDocument(document.reference)
            }
            
            // Delete user's water logs
            self.db.collection("waterLogs").whereField("userId", isEqualTo: uid).getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                snapshot?.documents.forEach { document in
                    batch.deleteDocument(document.reference)
                }
                
                // Delete user's workout logs
                self.db.collection("workoutLogs").whereField("userId", isEqualTo: uid).getDocuments { snapshot, error in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    
                    snapshot?.documents.forEach { document in
                        batch.deleteDocument(document.reference)
                    }
                    
                    // Commit the batch delete
                    batch.commit { error in
                        if let error = error {
                            completion(.failure(error))
                        } else {
                            completion(.success("User data deleted from Firestore"))
                        }
                    }
                }
            }
        }
    }
    
    private func clearAllLocalData() {
        // Clear UserDefaults
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
        
        // Clear other services data
        StepService.shared.resetData()
        WaterService.shared.resetData()
        
        // Clear any cached images or files if needed
        clearCacheDirectory()
        
        print("✅ All local data cleared")
    }
    
    private func clearCacheDirectory() {
        if let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
            do {
                let contents = try FileManager.default.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil)
                for file in contents {
                    try FileManager.default.removeItem(at: file)
                }
                print("✅ Cache directory cleared")
            } catch {
                print("❌ Error clearing cache: \(error.localizedDescription)")
            }
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
                if let name = data?["name"] as? String {
                    let email = data?["email"] as? String
                    let stepGoal = data?["dailyStepGoal"] as? Int ?? 10000
                    let waterGoal = data?["dailyWaterGoal"] as? Double ?? 2.5
                    let age = data?["age"] as? Int ?? 25
                    let weight = data?["weight"] as? Double ?? 70.0
                    let profileImageURL = data?["profileImageURL"] as? String
                    
                    let isFaceIDEnabled = data?["isFaceIDEnabled"] as? Bool ?? false
                    
                    // Sync Face ID setting with local storage on login
                    UserDefaults.standard.set(isFaceIDEnabled, forKey: "FaceIDEnabled")
                    print("Synced Face ID setting from Firebase: \(isFaceIDEnabled)")
                    
                    DispatchQueue.main.async {
                        self?.currentUser = User(
                            id: UUID(),
                            uid: uid,
                            name: name,
                            email: email ?? self?.auth.currentUser?.email,
                            age: age,
                            weight: weight,
                            dailyStepGoal: stepGoal,
                            dailyWaterGoal: waterGoal,
                            profileImageURL: profileImageURL,
                            isFaceIDEnabled: isFaceIDEnabled
                        )
                        print("✅ User data loaded: \(name), Email: \(email ?? "N/A")")
                    }
                }
            } else {
                // If no document exists, create one with current user info
                if let currentUser = self?.auth.currentUser {
                    DispatchQueue.main.async {
                        self?.currentUser = User(
                            id: UUID(),
                            uid: uid,
                            name: currentUser.displayName ?? "User",
                            email: currentUser.email
                        )
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
            "email": user.email ?? "",
            "age": user.age,
            "weight": user.weight,
            "dailyStepGoal": user.dailyStepGoal,
            "dailyWaterGoal": user.dailyWaterGoal
        ]
        
        db.collection("users").document(uid).updateData(userData) { [weak self] error in
            if let error = error {
                completion(.failure(error))
            } else {
                // Update local currentUser object
                DispatchQueue.main.async {
                    self?.currentUser = user
                }
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
    
    // MARK: - Biometric Authentication & Keychain
    
    func saveBiometricCredentials(email: String, password: String) {
        let credentials = "\(email):\(password)".data(using: .utf8)!
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "FitBuddy.biometric",
            kSecAttrAccount as String: "user_credentials",
            kSecValueData as String: credentials,
            kSecAttrAccessControl as String: SecAccessControlCreateWithFlags(
                nil,
                kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                .biometryAny,
                nil
            )!
        ]
        
        // Delete existing item first
        SecItemDelete(query as CFDictionary)
        
        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)
        if status == errSecSuccess {
            // Enable Face ID preference
            UserDefaults.standard.set(true, forKey: "FaceIDEnabled")
            print("✅ Biometric credentials saved successfully")
        } else {
            print("❌ Failed to save biometric credentials: \(status)")
        }
    }
    
    func getBiometricCredentials(completion: @escaping (Result<(String, String), Error>) -> Void) {
        let context = LAContext()
        context.localizedReason = "Sign in to FitBuddy with Face ID"
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "FitBuddy.biometric",
            kSecAttrAccount as String: "user_credentials",
            kSecReturnData as String: true,
            kSecUseAuthenticationContext as String: context
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess {
            if let data = result as? Data,
               let credentialString = String(data: data, encoding: .utf8) {
                let components = credentialString.components(separatedBy: ":")
                if components.count == 2 {
                    completion(.success((components[0], components[1])))
                } else {
                    completion(.failure(NSError(domain: "KeychainError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid credential format"])))
                }
            } else {
                completion(.failure(NSError(domain: "KeychainError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to decode credentials"])))
            }
        } else {
            var errorMessage = "Failed to retrieve credentials"
            switch status {
            case errSecUserCanceled:
                errorMessage = "User cancelled Face ID authentication"
            case errSecAuthFailed:
                errorMessage = "Face ID authentication failed"
            case errSecItemNotFound:
                errorMessage = "No saved credentials found. Please login with email and password first."
            default:
                errorMessage = "Keychain error: \(status)"
            }
            completion(.failure(NSError(domain: "KeychainError", code: Int(status), userInfo: [NSLocalizedDescriptionKey: errorMessage])))
        }
    }
    
    func signInWithBiometrics(completion: @escaping (Result<String, Error>) -> Void) {
        print("=== Face ID Login Attempt ===")
        
        // Simple biometric authentication without complex checks
        let context = LAContext()
        var error: NSError?
        
        // Check if biometrics are available
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            print("Biometrics not available: \(error?.localizedDescription ?? "Unknown error")")
            completion(.failure(NSError(domain: "FaceIDError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Biometric authentication not available"])))
            return
        }
        
        // Perform biometric authentication
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Sign in to FitBuddy with Face ID") { success, authError in
            DispatchQueue.main.async {
                if success {
                    print("Biometric authentication successful")
                    // Try to get stored credentials
                    self.getBiometricCredentials { result in
                        switch result {
                        case .success(let (email, password)):
                            print("Retrieved credentials, signing in")
                            self.signIn(email: email, password: password, completion: completion)
                        case .failure:
                            print("No stored credentials found, checking if user already logged in")
                            // If no stored credentials but biometric auth succeeded, check if user is already logged in
                            if self.auth.currentUser != nil {
                                completion(.success("Successfully authenticated with Face ID"))
                            } else {
                                completion(.failure(NSError(domain: "FaceIDError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No stored credentials found. Please sign in with email/password first."])))
                            }
                        }
                    }
                } else {
                    print("Biometric authentication failed: \(authError?.localizedDescription ?? "Unknown error")")
                    completion(.failure(NSError(domain: "FaceIDError", code: 0, userInfo: [NSLocalizedDescriptionKey: authError?.localizedDescription ?? "Face ID authentication failed"])))
                }
            }
        }
    }
    
    private func authenticateWithBiometrics(completion: @escaping (Bool) -> Void) {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            completion(false)
            return
        }
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Authenticate to access FitBuddy") { success, error in
            DispatchQueue.main.async {
                completion(success)
            }
        }
    }
    
    func isBiometricAvailable() -> Bool {
        let context = LAContext()
        var error: NSError?
        let available = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        
        print("=== Biometric Availability Check ===")
        print("Available: \(available)")
        if let error = error {
            print("Error: \(error.localizedDescription)")
        }
        print("=====================================")
        
        return available
    }
    
    func hasSavedBiometricCredentials() -> Bool {
        // Simple check: if Face ID is enabled in settings, show the button
        let localEnabled = UserDefaults.standard.bool(forKey: "FaceIDEnabled")
        print("hasSavedBiometricCredentials check - Local enabled: \(localEnabled)")
        return localEnabled
    }
    
    func isFaceIDEnabled() -> Bool {
        // Always check UserDefaults first (local preference)
        let localEnabled = UserDefaults.standard.bool(forKey: "FaceIDEnabled")
        
        // If we have a current user, sync with Firebase
        if let firebaseEnabled = currentUser?.isFaceIDEnabled {
            // If Firebase and local don't match, update local to match Firebase
            if firebaseEnabled != localEnabled {
                UserDefaults.standard.set(firebaseEnabled, forKey: "FaceIDEnabled")
                return firebaseEnabled
            }
        }
        
        return localEnabled
    }
    
    func setFaceIDEnabled(_ enabled: Bool) {
        print("=== Setting Face ID Enabled: \(enabled) ===")
        
        // Always update local storage first
        UserDefaults.standard.set(enabled, forKey: "FaceIDEnabled")
        print("Updated UserDefaults: \(UserDefaults.standard.bool(forKey: "FaceIDEnabled"))")
        
        // Update current user model
        currentUser?.isFaceIDEnabled = enabled
        
        // Update Firebase user document
        if let uid = auth.currentUser?.uid {
            db.collection("users").document(uid).updateData([
                "isFaceIDEnabled": enabled
            ]) { error in
                if let error = error {
                    print("Error updating Face ID in Firebase: \(error.localizedDescription)")
                } else {
                    print("Face ID setting successfully saved to Firebase")
                }
            }
        } else {
            print("No current user - Face ID setting saved locally only")
        }
        
        // If disabling, remove stored credentials
        if !enabled {
            deleteBiometricCredentials()
            print("Face ID disabled - credentials removed")
        } else {
            print("Face ID enabled - settings saved")
        }
        
        print("=== Face ID Setting Complete ===")
    }
    
    func getFaceIDEnabledFromFirebase() -> Bool {
        return currentUser?.isFaceIDEnabled ?? false
    }
    
    // Method to enable Face ID from profile/settings with credentials
    func enableFaceIDFromProfile(email: String, password: String, completion: @escaping (Bool) -> Void) {
        print("=== Enabling Face ID from Profile ===")
        
        // First verify the credentials are correct by attempting authentication
        auth.signIn(withEmail: email, password: password) { [weak self] result, error in
            if error != nil {
                print("Invalid credentials provided for Face ID setup")
                completion(false)
                return
            }
            
            // Credentials are valid, save them for biometric authentication
            self?.saveBiometricCredentials(email: email, password: password)
            self?.setFaceIDEnabled(true)
            
            print("Face ID successfully enabled from profile")
            completion(true)
        }
    }
    
    // Method to toggle Face ID from profile/settings
    func toggleFaceIDFromProfile(_ enabled: Bool) {
        setFaceIDEnabled(enabled)
    }
    
    func deleteBiometricCredentials() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "FitBuddy.biometric",
            kSecAttrAccount as String: "user_credentials"
        ]
        
        SecItemDelete(query as CFDictionary)
        // Disable Face ID preference
        UserDefaults.standard.set(false, forKey: "FaceIDEnabled")
        print("✅ Biometric credentials deleted")
    }
}
