//
//  StepService.swift
//  FitBuddy
//
//  Enhanced service with HealthKit integration and workout sessions
//

import Foundation
import Firebase
import FirebaseFirestore
import Combine
import HealthKit

class StepService: ObservableObject {
    static let shared = StepService()
    
    private let db = Firestore.firestore()
    private let authService = AuthService.shared
    private let healthKitService = HealthKitService.shared
    
    @Published var todaySteps: Int = 0
    @Published var isLoading = false
    @Published var currentWorkoutSession: WorkoutSession?
    @Published var isWorkoutActive = false
    @Published var workoutElapsedTime: TimeInterval = 0
    @Published var sessionSteps: Int = 0
    @Published var distance: Double = 0.0
    @Published var calories: Int = 0
    @Published var activeMinutes: Int = 0
    
    private var cancellables = Set<AnyCancellable>()
    private var dailyResetTimer: Timer?
    private var workoutTimer: Timer?
    private var workoutStartTime: Date?
    private var pausedDuration: TimeInterval = 0
    private var lastPauseTime: Date?
    
    private init() {
        setupHealthKitSubscription()
        setupDailyReset()
        
        // Only load data if user is authenticated
        if authService.currentUserId != nil {
            loadTodayData()
            checkForActiveWorkout()
        }
    }
    
    // MARK: - HealthKit Integration
    
    private func setupHealthKitSubscription() {
        healthKitService.stepsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] steps in
                self?.updateStepsFromHealthKit(steps)
            }
            .store(in: &cancellables)
    }
    
    private func updateStepsFromHealthKit(_ steps: Int) {
        let previousSteps = todaySteps
        todaySteps = steps
        
        // Check for step goal achievements
        checkStepGoalAchievements(previous: previousSteps, current: steps)
        
        // Update session steps if workout is active
        if let session = currentWorkoutSession, session.isActive {
            let sessionSteps = max(0, steps - session.startSteps)
            self.sessionSteps = sessionSteps
            
            // Update current session
            currentWorkoutSession?.totalSteps = sessionSteps
            currentWorkoutSession?.lastUpdated = Date()
        }
        
        // Auto-save every 100 steps
        if steps % 100 == 0 {
            saveTodaySteps()
        }
    }
    
    private func checkStepGoalAchievements(previous: Int, current: Int) {
        let notificationService = NotificationService.shared
        let challengeService = ChallengeService.shared
        let dailyGoal = 10000 // 10,000 steps daily goal
        
        // Check challenge progress
        challengeService.checkStepChallenges(currentSteps: current)
        
        // Check if daily goal was completed
        if previous < dailyGoal && current >= dailyGoal {
            notificationService.notifyDailyGoalCompleted(goalType: "steps", value: "10,000 steps")
        }
        // Check if reached halfway point
        else if previous < (dailyGoal / 2) && current >= (dailyGoal / 2) {
            notificationService.notifyHalfwayGoal(goalType: "steps", progress: "50%")
        }
    }
    
    func requestHealthKitPermission(completion: @escaping (Bool) -> Void) {
        healthKitService.requestAuthorization { [weak self] success in
            if success {
                self?.loadTodayData()
            }
            completion(success)
        }
    }
    
    // MARK: - Daily Reset Logic
    
    private func setupDailyReset() {
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date())!
        let startOfTomorrow = calendar.startOfDay(for: tomorrow)
        
        dailyResetTimer = Timer(fireAt: startOfTomorrow, interval: 24 * 60 * 60, target: self, selector: #selector(performDailyReset), userInfo: nil, repeats: true)
        
        if let timer = dailyResetTimer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }
    
    @objc private func performDailyReset() {
        // Save final data for the day
        saveTodaySteps()
        
        // Reset counters for new day
        DispatchQueue.main.async {
            self.todaySteps = 0
            self.distance = 0.0
            self.calories = 0
            self.activeMinutes = 0
            self.sessionSteps = 0
            
            // End any active workout session
            if self.isWorkoutActive {
                self.stopWorkoutSession { _ in }
            }
        }
        
        // Load new day's data
        loadTodayData()
    }
    
    // MARK: - Data Management
    
    func resetData() {
        DispatchQueue.main.async {
            self.todaySteps = 0
            self.distance = 0.0
            self.calories = 0
            self.activeMinutes = 0
            self.sessionSteps = 0
            self.isLoading = false
            self.currentWorkoutSession = nil
            self.isWorkoutActive = false
            self.workoutElapsedTime = 0
            self.pausedDuration = 0
        }
    }
    
    func loadTodayData() {
        guard authService.currentUserId != nil else { return }
        
        // Load steps from HealthKit
        healthKitService.loadTodaySteps()
        
        // Load additional metrics
        healthKitService.getDistance(for: Date()) { [weak self] distance in
            self?.distance = distance
        }
        
        healthKitService.getCalories(for: Date()) { [weak self] calories in
            self?.calories = calories
        }
        
        // Load step log from Firebase
        loadTodayStepLog()
    }
    
    // MARK: - Step Management
    
    private func saveTodaySteps() {
        guard let userId = authService.currentUserId else { return }
        
        let stepLog = StepLog(
            date: Date(),
            steps: todaySteps,
            distance: distance,
            calories: calories,
            activeMinutes: activeMinutes,
            userId: userId
        )
        
        saveStepLog(stepLog) { result in
            switch result {
            case .success:
                print("✅ Daily steps saved: \(self.todaySteps)")
            case .failure(let error):
                print("❌ Error saving daily steps: \(error)")
            }
        }
    }
    
    func saveStepLog(_ stepLog: StepLog, completion: @escaping (Result<String, Error>) -> Void) {
        guard let userId = authService.currentUserId else {
            completion(.failure(NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: stepLog.date)
        
        do {
            let data = try Firestore.Encoder().encode(stepLog)
            
            db.collection("users").document(userId).collection("steps").document(dateString).setData(data, merge: true) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success("Steps saved successfully"))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    private func loadTodayStepLog() {
        guard let userId = authService.currentUserId else { return }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: Date())
        
        db.collection("users").document(userId).collection("steps").document(dateString).getDocument { [weak self] snapshot, error in
            if let data = snapshot?.data() {
                do {
                    let stepLog = try Firestore.Decoder().decode(StepLog.self, from: data)
                    DispatchQueue.main.async {
                        // Use HealthKit data for steps, Firebase for other metrics
                        self?.distance = stepLog.distance
                        self?.calories = stepLog.calories
                        self?.activeMinutes = stepLog.activeMinutes
                    }
                } catch {
                    print("Error decoding step log: \(error)")
                }
            }
        }
    }
    
    // MARK: - Workout Session Management
    
    func startWorkoutSession(completion: @escaping (Bool) -> Void) {
        guard let userId = authService.currentUserId else {
            completion(false)
            return
        }
        
        // Request HealthKit permission if not already granted
        guard healthKitService.isAuthorized else {
            requestHealthKitPermission { [weak self] success in
                if success {
                    self?.startWorkoutSession(completion: completion)
                } else {
                    completion(false)
                }
            }
            return
        }
        
        // Start HealthKit workout session
        healthKitService.startWorkoutSession { [weak self] success in
            guard success else {
                completion(false)
                return
            }
            
            DispatchQueue.main.async {
                // Create new workout session
                let session = WorkoutSession(userId: userId, startSteps: self?.todaySteps ?? 0)
                self?.currentWorkoutSession = session
                self?.isWorkoutActive = true
                self?.workoutStartTime = Date()
                self?.workoutElapsedTime = 0
                self?.pausedDuration = 0
                self?.sessionSteps = 0
                
                // Start workout timer
                self?.startWorkoutTimer()
                
                // Save initial session to Firebase
                self?.saveWorkoutSession(session) { result in
                    switch result {
                    case .success:
                        print("✅ Workout session started")
                    case .failure(let error):
                        print("❌ Error starting workout session: \(error)")
                    }
                }
                
                completion(true)
            }
        }
    }
    
    func pauseWorkoutSession() {
        guard var session = currentWorkoutSession, session.status == .active else { return }
        
        healthKitService.pauseWorkoutSession()
        
        session.status = .paused
        session.lastUpdated = Date()
        currentWorkoutSession = session
        
        lastPauseTime = Date()
        stopWorkoutTimer()
        
        saveWorkoutSession(session) { _ in }
    }
    
    func resumeWorkoutSession() {
        guard var session = currentWorkoutSession, session.status == .paused else { return }
        
        healthKitService.resumeWorkoutSession()
        
        // Add paused time to total paused duration
        if let pauseTime = lastPauseTime {
            pausedDuration += Date().timeIntervalSince(pauseTime)
            session.pausedDuration = pausedDuration
        }
        
        session.status = .active
        session.lastUpdated = Date()
        currentWorkoutSession = session
        
        lastPauseTime = nil
        startWorkoutTimer()
        
        saveWorkoutSession(session) { _ in }
    }
    
    func stopWorkoutSession(completion: @escaping (Bool) -> Void) {
        guard var session = currentWorkoutSession else {
            completion(false)
            return
        }
        
        healthKitService.stopWorkoutSession { [weak self] success in
            DispatchQueue.main.async {
                // Finalize session
                session.endTime = Date()
                session.endSteps = self?.todaySteps ?? session.startSteps
                session.totalSteps = max(0, session.endSteps - session.startSteps)
                session.distance = self?.distance ?? 0.0
                session.calories = self?.calories ?? 0
                session.status = .completed
                session.lastUpdated = Date()
                
                // Add any remaining paused time
                if let pauseTime = self?.lastPauseTime {
                    self?.pausedDuration += Date().timeIntervalSince(pauseTime)
                    session.pausedDuration = self?.pausedDuration ?? 0
                }
                
                // Update active minutes
                let sessionDuration = Int(session.duration / 60)
                self?.activeMinutes += sessionDuration
                
                // Save final session
                self?.saveWorkoutSession(session) { result in
                    switch result {
                    case .success:
                        print("✅ Workout session completed: \(session.totalSteps) steps")
                        
                        // Show workout completion notification
                        let durationText = self?.formatDuration(session.duration) ?? "0m"
                        let workoutName = session.sessionType.rawValue.capitalized
                        let calories = session.calories
                        
                        NotificationService.shared.notifyWorkoutCompleted(
                            workoutName: workoutName,
                            duration: durationText,
                            calories: calories
                        )
                        
                    case .failure(let error):
                        print("❌ Error saving workout session: \(error)")
                    }
                }
                
                // Save updated daily totals
                self?.saveTodaySteps()
                
                // Reset workout state
                self?.currentWorkoutSession = nil
                self?.isWorkoutActive = false
                self?.workoutElapsedTime = 0
                self?.sessionSteps = 0
                self?.pausedDuration = 0
                self?.workoutStartTime = nil
                self?.lastPauseTime = nil
                self?.stopWorkoutTimer()
                
                completion(success)
            }
        }
    }
    
    private func startWorkoutTimer() {
        workoutTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self,
                  let startTime = self.workoutStartTime else { return }
            
            self.workoutElapsedTime = Date().timeIntervalSince(startTime) - self.pausedDuration
        }
    }
    
    private func stopWorkoutTimer() {
        workoutTimer?.invalidate()
        workoutTimer = nil
    }
    
    private func saveWorkoutSession(_ session: WorkoutSession, completion: @escaping (Result<String, Error>) -> Void) {
        guard let userId = authService.currentUserId else {
            completion(.failure(NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        do {
            let data = try Firestore.Encoder().encode(session)
            
            let sessionId = session.id ?? UUID().uuidString
            db.collection("users").document(userId).collection("workoutSessions").document(sessionId).setData(data, merge: true) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success("Session saved successfully"))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    private func checkForActiveWorkout() {
        guard let userId = authService.currentUserId else { return }
        
        db.collection("users").document(userId).collection("workoutSessions")
            .whereField("status", in: [WorkoutStatus.active.rawValue, WorkoutStatus.paused.rawValue])
            .limit(to: 1)
            .getDocuments { [weak self] snapshot, error in
                if let document = snapshot?.documents.first {
                    do {
                        let session = try Firestore.Decoder().decode(WorkoutSession.self, from: document.data())
                        DispatchQueue.main.async {
                            self?.currentWorkoutSession = session
                            self?.isWorkoutActive = session.isActive
                            
                            if session.status == .active {
                                self?.workoutStartTime = session.startTime
                                self?.pausedDuration = session.pausedDuration
                                self?.startWorkoutTimer()
                            }
                        }
                    } catch {
                        print("Error decoding active workout session: \(error)")
                    }
                }
            }
    }
    
    // MARK: - Legacy Methods (for backward compatibility)
    
    func saveSteps(steps: Int, date: Date = Date(), completion: @escaping (Result<String, Error>) -> Void) {
        let stepLog = StepLog(date: date, steps: steps, userId: authService.currentUserId ?? "")
        saveStepLog(stepLog, completion: completion)
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
                completion(.success(0))
            }
        }
    }
    
    func loadTodaySteps() {
        loadTodayData()
    }
    
    // MARK: - Helper Functions
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        
        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }
    
    deinit {
        dailyResetTimer?.invalidate()
        workoutTimer?.invalidate()
    }
}
