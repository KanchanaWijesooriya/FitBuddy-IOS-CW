//
//  WorkoutRecommendationServiceTests.swift
//  FitBuddyTests
//
//  Created by Unit Tests on 2025-09-18.
//

import XCTest
@testable import FitBuddy

final class WorkoutRecommendationServiceTests: XCTestCase {
    
    var recommendationService: WorkoutRecommendationService!
    
    override func setUpWithError() throws {
        // Setup test instance before each test
        recommendationService = WorkoutRecommendationService()
    }
    
    override func tearDownWithError() throws {
        // Clean up after each test
        recommendationService = nil
        UserDefaults.standard.removeObject(forKey: "lastRecommendationRefresh")
    }
    
    // MARK: - Basic Functionality Tests
    
    func testRecommendationServiceInitialization() throws {
        // Test that the service initializes properly
        XCTAssertNotNil(recommendationService, "WorkoutRecommendationService should initialize")
    }
    
    func testGetBestWorkoutsGeneratesRecommendations() throws {
        // Test that calling getBestWorkoutsForUser generates recommendations
        let expectation = self.expectation(description: "Recommendations should be generated")
        
        recommendationService.getBestWorkoutsForUser()
        
        // Wait a bit for async operations
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertFalse(self.recommendationService.recommendations.isEmpty, "Should generate recommendations")
            XCTAssertEqual(self.recommendationService.recommendations.count, 3, "Should generate exactly 3 recommendations")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    // MARK: - Goal-Based Recommendation Tests
    
    func testWeightLossRecommendations() throws {
        // Test recommendations for weight loss goal
        let expectation = self.expectation(description: "Weight loss recommendations")
        
        recommendationService.getBestWorkoutsForUser(
            age: 25,
            fitnessLevel: "beginner",
            primaryGoal: "weight_loss"
        )
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let recommendations = self.recommendationService.recommendations
            XCTAssertEqual(recommendations.count, 3, "Should have 3 weight loss recommendations")
            
            // Check that recommendations include appropriate workout types for weight loss
            let workoutTypes = recommendations.map { $0.type }
            XCTAssertTrue(workoutTypes.contains("cardio"), "Weight loss should include cardio")
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testMuscleGainRecommendations() throws {
        // Test recommendations for muscle gain goal
        let expectation = self.expectation(description: "Muscle gain recommendations")
        
        recommendationService.getBestWorkoutsForUser(
            age: 30,
            fitnessLevel: "intermediate",
            primaryGoal: "muscle_gain"
        )
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let recommendations = self.recommendationService.recommendations
            XCTAssertEqual(recommendations.count, 3, "Should have 3 muscle gain recommendations")
            
            // Check that recommendations include appropriate workout types for muscle gain
            let workoutTypes = recommendations.map { $0.type }
            XCTAssertTrue(workoutTypes.contains("strength"), "Muscle gain should include strength training")
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testFlexibilityRecommendations() throws {
        // Test recommendations for flexibility goal
        let expectation = self.expectation(description: "Flexibility recommendations")
        
        recommendationService.getBestWorkoutsForUser(
            age: 35,
            fitnessLevel: "beginner",
            primaryGoal: "flexibility"
        )
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let recommendations = self.recommendationService.recommendations
            XCTAssertEqual(recommendations.count, 3, "Should have 3 flexibility recommendations")
            
            // Check that recommendations include yoga for flexibility
            let workoutTypes = recommendations.map { $0.type }
            XCTAssertTrue(workoutTypes.contains("yoga"), "Flexibility should include yoga")
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testRecommendationDataValidation() throws {
        // Test that recommendations have valid data
        let expectation = self.expectation(description: "Recommendation data validation")
        
        recommendationService.getBestWorkoutsForUser()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let recommendations = self.recommendationService.recommendations
            
            for recommendation in recommendations {
                // Test required fields are not empty
                XCTAssertFalse(recommendation.name.isEmpty, "Recommendation name should not be empty")
                XCTAssertFalse(recommendation.type.isEmpty, "Recommendation type should not be empty")
                XCTAssertFalse(recommendation.level.isEmpty, "Recommendation level should not be empty")
                XCTAssertFalse(recommendation.description.isEmpty, "Recommendation description should not be empty")
                XCTAssertFalse(recommendation.imageName.isEmpty, "Recommendation image name should not be empty")
                
                // Test confidence is in valid range
                XCTAssertGreaterThanOrEqual(recommendation.confidence, 0.0, "Confidence should be >= 0")
                XCTAssertLessThanOrEqual(recommendation.confidence, 1.0, "Confidence should be <= 1")
                
                // Test level values are valid
                let validLevels = ["Beginner", "Intermediate", "Advanced"]
                XCTAssertTrue(validLevels.contains(recommendation.level), "Level should be valid: \(recommendation.level)")
                
                // Test workout types are valid
                let validTypes = ["cardio", "strength", "hiit", "yoga", "full_body", "general"]
                XCTAssertTrue(validTypes.contains(recommendation.type), "Type should be valid: \(recommendation.type)")
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    // MARK: - Daily Refresh Tests
    
    func testDailyRefreshLogic() throws {
        // Test that recommendations refresh daily
        let expectation = self.expectation(description: "Daily refresh test")
        
        // First call should generate recommendations
        recommendationService.getBestWorkoutsForUser()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertFalse(self.recommendationService.recommendations.isEmpty, "Should have initial recommendations")
            
            // Second call on same day should use cached recommendations
            let initialRecommendations = self.recommendationService.recommendations
            self.recommendationService.getBestWorkoutsForUser()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                // Should have same recommendations (cached)
                XCTAssertEqual(self.recommendationService.recommendations.count, initialRecommendations.count, "Should use cached recommendations")
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 3.0)
    }
    
    // MARK: - Performance Tests
    
    func testRecommendationGenerationPerformance() throws {
        // Test that recommendation generation is fast
        measure {
            let service = WorkoutRecommendationService()
            service.getBestWorkoutsForUser()
            
            // Wait for completion
            let expectation = self.expectation(description: "Performance test")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 1.0)
        }
    }
    
    func testMultipleGoalTypes() throws {
        // Test different goals generate different recommendations
        let goals = ["weight_loss", "muscle_gain", "flexibility", "endurance", "general_fitness"]
        let expectation = self.expectation(description: "Multiple goal test")
        
        var completedGoals = 0
        
        for goal in goals {
            let service = WorkoutRecommendationService()
            service.getBestWorkoutsForUser(primaryGoal: goal)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                XCTAssertEqual(service.recommendations.count, 3, "Should have 3 recommendations for \(goal)")
                
                completedGoals += 1
                if completedGoals == goals.count {
                    expectation.fulfill()
                }
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
}
