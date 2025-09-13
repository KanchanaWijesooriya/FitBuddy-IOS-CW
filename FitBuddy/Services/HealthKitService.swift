//
//  HealthKitService.swift
//  FitBuddy
//
//  Created by Assistant on 2025-09-13.
//

import Foundation
import HealthKit
import Combine

class HealthKitService: NSObject, ObservableObject {
    static let shared = HealthKitService()
    
    private let healthStore = HKHealthStore()
    private var stepCountQuery: HKQuery?
    private var isWorkoutActive = false
    private var workoutStartDate: Date?
    private var workoutStartSteps: Int = 0
    
    @Published var isAuthorized = false
    @Published var todaySteps: Int = 0
    @Published var currentSessionSteps: Int = 0
    @Published var sessionStartSteps: Int = 0
    
    // Publishers for real-time updates
    private let stepsSubject = PassthroughSubject<Int, Never>()
    var stepsPublisher: AnyPublisher<Int, Never> {
        stepsSubject.eraseToAnyPublisher()
    }
    
    override private init() {
        super.init()
        checkAuthorizationStatus()
        
        // Also test actual data access as a backup check
        testHealthKitAccess { [weak self] hasAccess in
            if hasAccess {
                self?.isAuthorized = true
            }
        }
    }
    
    // MARK: - Authorization
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false)
            return
        }
        
        // Check if we've already requested authorization recently
        let hasStoredAuth = UserDefaults.standard.bool(forKey: "HealthKitAuthorized")
        if hasStoredAuth {
            print("✅ Using stored HealthKit authorization")
            DispatchQueue.main.async {
                self.isAuthorized = true
                completion(true)
                self.loadTodaySteps()
                self.startObservingSteps()
            }
            return
        }
        
        let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let distanceWalkingType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
        let activeEnergyBurnedType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        let workoutType = HKWorkoutType.workoutType()
        
        let typesToRead: Set<HKObjectType> = [
            stepCountType,
            distanceWalkingType,
            activeEnergyBurnedType,
            workoutType
        ]
        
        let typesToWrite: Set<HKSampleType> = [
            stepCountType,
            distanceWalkingType,
            activeEnergyBurnedType,
            workoutType
        ]
        
        print("🔄 Requesting HealthKit authorization...")
        healthStore.requestAuthorization(toShare: typesToWrite, read: typesToRead) { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    // Store that we've successfully authorized HealthKit
                    UserDefaults.standard.set(true, forKey: "HealthKitAuthorized")
                    print("✅ HealthKit authorization successful")
                } else {
                    print("❌ HealthKit authorization failed: \(error?.localizedDescription ?? "Unknown error")")
                }
                
                self?.isAuthorized = success
                completion(success)
                
                if success {
                    self?.loadTodaySteps()
                    self?.startObservingSteps()
                }
            }
        }
    }
    
    // For testing - reset authorization
    func resetAuthorization() {
        UserDefaults.standard.removeObject(forKey: "HealthKitAuthorized")
        isAuthorized = false
        print("🔄 HealthKit authorization reset")
    }
    
    func testHealthKitAccess(completion: @escaping (Bool) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false)
            return
        }
        
        let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepCountType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            DispatchQueue.main.async {
                let canReadData = (error == nil && result != nil)
                completion(canReadData)
                
                if canReadData {
                    UserDefaults.standard.set(true, forKey: "HealthKitAuthorized")
                    print("✅ HealthKit data access confirmed")
                } else {
                    print("❌ HealthKit data access failed: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    private func checkAuthorizationStatus() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        
        let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let readAuthStatus = healthStore.authorizationStatus(for: stepCountType)
        
        // For HealthKit, we can only reliably check read permissions
        // Write permissions are always .notDetermined for privacy reasons
        // So we check if read access is granted OR if the user has previously authorized
        let hasReadAccess = readAuthStatus == .sharingAuthorized
        
        // Check if we've stored authorization state previously
        let hasStoredAuth = UserDefaults.standard.bool(forKey: "HealthKitAuthorized")
        
        DispatchQueue.main.async {
            self.isAuthorized = hasReadAccess || hasStoredAuth
            
            print("📊 HealthKit Auth Status:")
            print("  Read Access: \(readAuthStatus.rawValue)")
            print("  Stored Auth: \(hasStoredAuth)")
            print("  Final Authorized: \(self.isAuthorized)")
            
            if self.isAuthorized {
                self.loadTodaySteps()
                self.startObservingSteps()
            }
        }
    }
    
    // MARK: - Step Tracking
    
    func loadTodaySteps() {
        let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
        
        let query = HKStatisticsQuery(
            quantityType: stepCountType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { [weak self] _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                DispatchQueue.main.async {
                    self?.todaySteps = 0
                }
                return
            }
            
            let steps = Int(sum.doubleValue(for: HKUnit.count()))
            DispatchQueue.main.async {
                self?.todaySteps = steps
                self?.stepsSubject.send(steps)
            }
        }
        
        healthStore.execute(query)
    }
    
    private func startObservingSteps() {
        let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        
        let query = HKObserverQuery(sampleType: stepCountType, predicate: nil) { [weak self] _, _, error in
            if error == nil {
                self?.loadTodaySteps()
            }
        }
        
        stepCountQuery = query
        healthStore.execute(query)
        healthStore.enableBackgroundDelivery(for: stepCountType, frequency: .immediate) { _, _ in }
    }
    
    // MARK: - Workout Session Management
    
    func startWorkoutSession(completion: @escaping (Bool) -> Void) {
        guard isAuthorized else {
            completion(false)
            return
        }
        
        // Record current step count as session start
        sessionStartSteps = todaySteps
        currentSessionSteps = 0
        workoutStartDate = Date()
        workoutStartSteps = todaySteps
        isWorkoutActive = true
        
        DispatchQueue.main.async {
            completion(true)
            print("✅ Workout session started (iOS mode)")
        }
        
        // Start monitoring session steps
        startSessionStepMonitoring()
    }
    
    func pauseWorkoutSession() {
        isWorkoutActive = false
        stopSessionStepMonitoring()
        print("⏸️ Workout session paused")
    }
    
    func resumeWorkoutSession() {
        isWorkoutActive = true
        startSessionStepMonitoring()
        print("▶️ Workout session resumed")
    }
    
    func stopWorkoutSession(completion: @escaping (Bool) -> Void) {
        guard isWorkoutActive else {
            completion(false)
            return
        }
        
        stopSessionStepMonitoring()
        
        // Calculate workout duration and steps
        let endDate = Date()
        let duration = workoutStartDate.map { endDate.timeIntervalSince($0) } ?? 0
        let totalSteps = todaySteps - workoutStartSteps
        
        isWorkoutActive = false
        
        // Create and save workout to HealthKit
        let workout = HKWorkout(
            activityType: .walking,
            start: workoutStartDate ?? Date(),
            end: endDate,
            duration: duration,
            totalEnergyBurned: nil,
            totalDistance: nil,
            metadata: [
                HKMetadataKeyWorkoutBrandName: "FitBuddy"
            ]
        )
        
        healthStore.save(workout) { [weak self] success, error in
            DispatchQueue.main.async {
                self?.workoutStartDate = nil
                self?.workoutStartSteps = 0
                completion(success && error == nil)
                
                if success {
                    print("✅ Workout saved successfully")
                } else {
                    print("❌ Failed to save workout: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
    }
    
    private func startSessionStepMonitoring() {
        // Monitor steps during workout session
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] timer in
            guard let self = self, self.isWorkoutActive else {
                timer.invalidate()
                return
            }
            
            let sessionSteps = self.todaySteps - self.sessionStartSteps
            if sessionSteps >= 0 {
                self.currentSessionSteps = sessionSteps
            }
        }
    }
    
    private func stopSessionStepMonitoring() {
        // Timer will be invalidated automatically when workout session is nil
    }
    
    // MARK: - Additional Metrics
    
    func getDistance(for date: Date, completion: @escaping (Double) -> Void) {
        let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
        
        let query = HKStatisticsQuery(
            quantityType: distanceType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                DispatchQueue.main.async {
                    completion(0.0)
                }
                return
            }
            
            let distance = sum.doubleValue(for: HKUnit.meterUnit(with: .kilo))
            DispatchQueue.main.async {
                completion(distance)
            }
        }
        
        healthStore.execute(query)
    }
    
    func getCalories(for date: Date, completion: @escaping (Int) -> Void) {
        let caloriesType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
        
        let query = HKStatisticsQuery(
            quantityType: caloriesType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                DispatchQueue.main.async {
                    completion(0)
                }
                return
            }
            
            let calories = Int(sum.doubleValue(for: HKUnit.kilocalorie()))
            DispatchQueue.main.async {
                completion(calories)
            }
        }
        
        healthStore.execute(query)
    }
    
    deinit {
        if let query = stepCountQuery {
            healthStore.stop(query)
        }
    }
}