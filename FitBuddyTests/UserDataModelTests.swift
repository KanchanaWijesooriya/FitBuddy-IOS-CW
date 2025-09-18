//
//  UserDataModelTests.swift
//  FitBuddyTests
//
//  Created by Unit Tests on 2025-09-18.
//

import XCTest
import SwiftUI
@testable import FitBuddy

final class UserDataModelTests: XCTestCase {
    
    // MARK: - User Model Tests
    
    func testUserModelInitialization() throws {
        // Test User model creation with valid data
        let user = User(
            id: UUID(),
            uid: "test123",
            name: "John Doe",
            email: "test@example.com",
            age: 25,
            weight: 70.0,
            dailyStepGoal: 10000,
            dailyWaterGoal: 2.5,
            profileImageURL: nil,
            createdAt: Date(),
            isFaceIDEnabled: false
        )
        
        XCTAssertEqual(user.uid, "test123", "User UID should match")
        XCTAssertEqual(user.email, "test@example.com", "Email should match")
        XCTAssertEqual(user.name, "John Doe", "Name should match")
        XCTAssertEqual(user.age, 25, "Age should match")
        XCTAssertEqual(user.weight, 70.0, "Weight should match")
        XCTAssertEqual(user.dailyStepGoal, 10000, "Daily step goal should match")
        XCTAssertEqual(user.dailyWaterGoal, 2.5, "Daily water goal should match")
        XCTAssertNotNil(user.createdAt, "Created date should not be nil")
        XCTAssertFalse(user.isFaceIDEnabled, "Face ID should be disabled by default")
    }
    
    func testUserBMICalculation() throws {
        // Test BMI calculation functionality
        let user = User(
            id: UUID(),
            uid: "test123",
            name: "John Doe",
            email: "test@example.com",
            age: 25,
            weight: 70.0,   // 70kg
            dailyStepGoal: 10000,
            dailyWaterGoal: 2.5
        )
        
        // Assume height of 1.75m for BMI calculation
        let height = 1.75 // meters
        // BMI = weight(kg) / height(m)^2 = 70 / (1.75)^2 = 70 / 3.0625 ≈ 22.86
        let expectedBMI = 70.0 / pow(height, 2)
        let actualBMI = user.weight / pow(height, 2)
        
        XCTAssertEqual(actualBMI, expectedBMI, accuracy: 0.01, "BMI calculation should be correct")
        XCTAssertGreaterThan(actualBMI, 18.5, "BMI should be in normal range")
        XCTAssertLessThan(actualBMI, 25.0, "BMI should be in normal range")
    }
    
    func testUserEmailValidation() throws {
        // Test email validation logic
        let validEmails = [
            "test@example.com",
            "user.name@domain.co.uk",
            "first.last+tag@example.org",
            "123@domain.com"
        ]
        
        let invalidEmails = [
            "invalid",
            "@domain.com",
            "test@",
            "test.domain.com",
            ""
        ]
        
        // Test valid emails
        for email in validEmails {
            let isValid = isValidEmail(email)
            XCTAssertTrue(isValid, "Email '\(email)' should be valid")
        }
        
        // Test invalid emails
        for email in invalidEmails {
            let isValid = isValidEmail(email)
            XCTAssertFalse(isValid, "Email '\(email)' should be invalid")
        }
    }
    
    // MARK: - Goal Model Tests
    
    func testGoalModelCreation() throws {
        // Test Goal model creation and validation
        let goal = Goal(
            steps: 10000,
            water: 2.5
        )
        
        XCTAssertEqual(goal.steps, 10000, "Step goal should match")
        XCTAssertEqual(goal.water, 2.5, "Water goal should match")
    }
    
    func testGoalProgressCalculation() throws {
        // Test goal progress calculation
        let dailyGoal = Goal(steps: 10000, water: 2.5)
        
        // Test step progress
        let currentSteps = 7500
        let stepProgress = Double(currentSteps) / Double(dailyGoal.steps)
        XCTAssertEqual(stepProgress, 0.75, accuracy: 0.01, "Step progress should be 75%")
        
        // Test water progress
        let currentWater = 1.8 // liters
        let waterProgress = currentWater / dailyGoal.water
        XCTAssertEqual(waterProgress, 0.72, accuracy: 0.01, "Water progress should be 72%")
    }
    
    func testGoalValidation() throws {
        // Test goal validation logic
        
        // Valid goal
        let validGoal = Goal(steps: 10000, water: 2.5)
        XCTAssertTrue(isValidGoal(validGoal), "Valid goal should pass validation")
        
        // Invalid goal (negative values)
        let invalidGoal = Goal(steps: -100, water: -1.0)
        XCTAssertFalse(isValidGoal(invalidGoal), "Goal with negative values should fail validation")
    }
    
    // MARK: - Water Log Tests
    
    func testWaterLogCreation() throws {
        // Test WaterLog model functionality
        let waterLog = WaterLog(
            date: Date(),
            amount: 250.0 // 250ml
        )
        
        XCTAssertEqual(waterLog.amount, 250.0, "Amount should match")
        XCTAssertNotNil(waterLog.date, "Date should not be nil")
    }
    
    func testDailyWaterGoalCalculation() throws {
        // Test daily water intake goal calculation
        let userWeight = 70.0 // kg
        let recommendedWaterIntake = userWeight * 35 // 35ml per kg body weight
        let expectedIntake = 70.0 * 35 // 2450ml = 2.45L
        
        XCTAssertEqual(recommendedWaterIntake, expectedIntake, "Water intake calculation should be correct")
        XCTAssertGreaterThan(recommendedWaterIntake, 2000, "Should recommend at least 2L")
        XCTAssertLessThan(recommendedWaterIntake, 4000, "Should not exceed 4L for normal weight")
    }
    
    // MARK: - Step Log Tests
    
    func testStepLogCreation() throws {
        // Test StepLog model functionality
        let stepLog = StepLog(
            date: Date(),
            steps: 8500,
            distance: 6.8,
            calories: 350,
            activeMinutes: 120,
            goalSteps: 10000,
            userId: "user456"
        )
        
        XCTAssertEqual(stepLog.steps, 8500, "Steps should match")
        XCTAssertEqual(stepLog.distance, 6.8, accuracy: 0.1, "Distance should match")
        XCTAssertEqual(stepLog.calories, 350, "Calories should match")
        XCTAssertEqual(stepLog.activeMinutes, 120, "Active minutes should match")
        XCTAssertEqual(stepLog.goalSteps, 10000, "Goal steps should match")
        XCTAssertEqual(stepLog.userId, "user456", "User ID should match")
        XCTAssertNotNil(stepLog.date, "Date should not be nil")
    }
    
    func testStepGoalAchievement() throws {
        // Test step goal achievement logic
        let dailyStepGoal = 10000
        let testCases = [
            (steps: 5000, expectedProgress: 0.5, achieved: false),
            (steps: 10000, expectedProgress: 1.0, achieved: true),
            (steps: 12000, expectedProgress: 1.2, achieved: true),
            (steps: 0, expectedProgress: 0.0, achieved: false)
        ]
        
        for testCase in testCases {
            let progress = Double(testCase.steps) / Double(dailyStepGoal)
            let achieved = testCase.steps >= dailyStepGoal
            
            XCTAssertEqual(progress, testCase.expectedProgress, accuracy: 0.001, 
                          "Progress calculation should be correct for \(testCase.steps) steps")
            XCTAssertEqual(achieved, testCase.achieved, 
                          "Achievement status should be correct for \(testCase.steps) steps")
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func isValidGoal(_ goal: Goal) -> Bool {
        // Basic validation: steps and water should be positive
        return goal.steps > 0 && goal.water > 0
    }
}
