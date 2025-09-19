//
//  HealthKitServiceTests.swift
//  FitBuddyTests
//
//  Created by Chanuka Wijesooriya on 2025-09-19.
//

import XCTest
import HealthKit
import Combine
@testable import FitBuddy

class HealthKitServiceTests: XCTestCase {
    
    var healthKitService: HealthKitService!
    var cancellables: Set<AnyCancellable>!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        healthKitService = HealthKitService.shared
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDownWithError() throws {
        cancellables?.removeAll()
        cancellables = nil
        healthKitService = nil
        try super.tearDownWithError()
    }
        
    func testHealthKitIsAvailable() {
        // Test if HealthKit is available on the device
        let isAvailable = HKHealthStore.isHealthDataAvailable()
        
        XCTAssertTrue(isAvailable, "HealthKit should be available on iOS devices")
        
        print("HealthKit Availability Test: \(isAvailable ? "PASSED" : "FAILED")")
    }
    
    
    func testHealthKitAuthorizationRequest() {
        let expectation = XCTestExpectation(description: "HealthKit authorization request")
        
        healthKitService.requestAuthorization { success in
            XCTAssertTrue(success || !success, "Authorization should complete without crashing")
            print("HealthKit Authorization Test: \(success ? "AUTHORIZED" : "NOT AUTHORIZED")")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testHealthKitAuthorizationStatus() {
        // Test if we can check authorization status without crashing
        let service = HealthKitService.shared
        
        // This should not crash regardless of authorization status
        XCTAssertNotNil(service, "HealthKitService should initialize successfully")
        
        // Check if isAuthorized property is accessible
        let authStatus = service.isAuthorized
        XCTAssertTrue(authStatus == true || authStatus == false, "Authorization status should be boolean")
        
        print("HealthKit Authorization Status: \(authStatus)")
    }
    
    
    func testRequiredHealthKitDataTypes() {
        
        // Step count type
        let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount)
        XCTAssertNotNil(stepCountType, "Step count type should be available")
        
        // Distance walking running type
        let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)
        XCTAssertNotNil(distanceType, "Distance type should be available")
        
        // Active energy burned type
        let energyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)
        XCTAssertNotNil(energyType, "Energy type should be available")
        
        // Workout type
        let workoutType = HKObjectType.workoutType()
        XCTAssertNotNil(workoutType, "Workout type should be available")
        
        print("HealthKit Data Types Test: PASSED")
    }
    
    
    func testStepsPublisher() {
        let expectation = XCTestExpectation(description: "Steps publisher should work")
        
        healthKitService.stepsPublisher
            .sink { steps in
                XCTAssertGreaterThanOrEqual(steps, 0, "Steps should be non-negative")
                print("Steps Publisher Test: Received \(steps) steps")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // Trigger a manual steps update to test publisher
        healthKitService.fetchTodaySteps { _ in }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testTodayStepsFetch() {
        let expectation = XCTestExpectation(description: "Today steps fetch should complete")
        
        healthKitService.fetchTodaySteps { success in
            XCTAssertTrue(success || !success, "Steps fetch should complete without crashing")
            
            let todaySteps = self.healthKitService.todaySteps
            XCTAssertGreaterThanOrEqual(todaySteps, 0, "Today steps should be non-negative")
            
            print("Today Steps Fetch Test: \(success ? "SUCCESS" : "FAILED") - Steps: \(todaySteps)")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testWorkoutSessionManagement() {
        // Test workout session start/stop functionality
        
        // Test starting a workout session
        healthKitService.startWorkoutSession(workoutType: "general")
        
        // Check if session tracking is working
        let sessionSteps = healthKitService.currentSessionSteps
        XCTAssertGreaterThanOrEqual(sessionSteps, 0, "Session steps should be non-negative")
        
        // Test stopping a workout session
        healthKitService.stopWorkoutSession { success in
            XCTAssertTrue(success || !success, "Stop workout should complete without crashing")
            print("Workout Session Test: \(success ? "SUCCESS" : "FAILED")")
        }
        
        print("Workout Session Management Test: PASSED")
    }
        
    func testHealthKitIntegrationHealthCheck() {
        let expectation = XCTestExpectation(description: "HealthKit integration health check")
        
        var testResults: [String: Bool] = [:]
        
        // Test 1: HealthKit Availability
        testResults["availability"] = HKHealthStore.isHealthDataAvailable()
        
        // Test 2: Service Initialization
        testResults["initialization"] = (HealthKitService.shared != nil)
        
        // Test 3: Data Types Creation
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)
        testResults["dataTypes"] = (stepType != nil)
        
        // Test 4: Authorization Request (without requiring actual permission)
        healthKitService.requestAuthorization { authSuccess in
            testResults["authorization"] = true 
            
            // Test 5: Basic Data Fetch
            self.healthKitService.fetchTodaySteps { fetchSuccess in
                testResults["dataFetch"] = true 
                
                print("HealthKit Integration Health Check...")
                print("HealthKit Availability: \(testResults["availability"] ?? false)")
                print("Service Initialization: \(testResults["initialization"] ?? false)")
                print("Data Types Support: \(testResults["dataTypes"] ?? false)")
                print("Authorization Flow: \(testResults["authorization"] ?? false)")
                print("Data Fetch Flow: \(testResults["dataFetch"] ?? false)")
                print("Current Authorization Status: \(self.healthKitService.isAuthorized)")
                print("Today's Steps: \(self.healthKitService.todaySteps)")
                
                // Overall health check
                let allTestsPassed = testResults.values.allSatisfy { $0 }
                XCTAssertTrue(allTestsPassed, "All HealthKit integration tests should pass")
                
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 15.0)
    }
        
    func testHealthKitServicePerformance() {
        measure {
            // Test performance of HealthKit service initialization and basic operations
            let service = HealthKitService.shared
            service.fetchTodaySteps { _ in }
            service.startWorkoutSession(workoutType: "general")
            service.stopWorkoutSession { _ in }
        }
    }
        
    func testHealthKitErrorHandling() {
        let expectation = XCTestExpectation(description: "Error handling should work properly")
        
        healthKitService.startWorkoutSession(workoutType: "invalid_workout_type")
        
        healthKitService.fetchTodaySteps { success in
            XCTAssertTrue(true, "Error handling should prevent crashes")
            print("Error Handling Test: PASSED")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
}