import Foundation
import CoreML
import SwiftUI

class WorkoutRecommendationService: ObservableObject {
    @Published var recommendations: [WorkoutRecommendation] = []
    
    struct WorkoutRecommendation: Identifiable {
        let id = UUID()
        let name: String
        let type: String
        let confidence: Double
        let imageName: String
        let accent: Color
        let level: String
        let description: String
    }
    
    init() {
        // Generate recommendations without Core ML for now
        generateRecommendations()
    }
    
    func getBestWorkoutsForUser(age: Double = 25, fitnessLevel: String = "beginner", primaryGoal: String = "general_fitness", preferredTime: String = "morning", bmiCategory: String = "normal", activityLevel: String = "medium") {
        
        // Check if we need to refresh (daily refresh)
        let lastRefreshDate = UserDefaults.standard.object(forKey: "lastRecommendationRefresh") as? Date
        let shouldRefresh = shouldRefreshRecommendations(lastRefresh: lastRefreshDate)
        
        if !shouldRefresh && !recommendations.isEmpty {
            return // Use cached recommendations
        }
        
        // For now, generate smart recommendations based on user profile
        // This can be enhanced with Core ML later when the model is properly integrated
        generateRecommendations(for: (age: age, fitnessLevel: fitnessLevel, primaryGoal: primaryGoal, preferredTime: preferredTime, bmiCategory: bmiCategory, activityLevel: activityLevel))
        
        // Update last refresh date
        UserDefaults.standard.set(Date(), forKey: "lastRecommendationRefresh")
    }
    
    private func shouldRefreshRecommendations(lastRefresh: Date?) -> Bool {
        guard let lastRefresh = lastRefresh else { return true }
        
        let calendar = Calendar.current
        let now = Date()
        
        // Check if it's a new day
        return !calendar.isDate(lastRefresh, inSameDayAs: now)
    }
    
    private func generateRecommendations(for scenario: (age: Double, fitnessLevel: String, primaryGoal: String, preferredTime: String, bmiCategory: String, activityLevel: String)? = nil) {
        
        var newRecommendations: [WorkoutRecommendation] = []
        
        if let scenario = scenario {
            // Smart logic based on user profile
            newRecommendations = generateSmartRecommendations(scenario: scenario)
        } else {
            // Default recommendations
            newRecommendations = generateDefaultRecommendations()
        }
        
        DispatchQueue.main.async {
            self.recommendations = Array(newRecommendations.prefix(3)) // Exactly 3 recommendations
        }
    }
    
    private func generateSmartRecommendations(scenario: (age: Double, fitnessLevel: String, primaryGoal: String, preferredTime: String, bmiCategory: String, activityLevel: String)) -> [WorkoutRecommendation] {
        
        var recommendations: [WorkoutRecommendation] = []
        
        // Logic based on primary goal - now generating 3 recommendations
        switch scenario.primaryGoal {
        case "weight_loss":
            recommendations.append(createWorkoutRecommendation(type: "cardio", scenario: scenario))
            recommendations.append(createWorkoutRecommendation(type: "hiit", scenario: scenario))
            recommendations.append(createWorkoutRecommendation(type: "strength", scenario: scenario))
        case "muscle_gain":
            recommendations.append(createWorkoutRecommendation(type: "strength", scenario: scenario))
            recommendations.append(createWorkoutRecommendation(type: "full_body", scenario: scenario))
            recommendations.append(createWorkoutRecommendation(type: "hiit", scenario: scenario))
        case "flexibility":
            recommendations.append(createWorkoutRecommendation(type: "yoga", scenario: scenario))
            recommendations.append(createWorkoutRecommendation(type: "cardio", scenario: scenario))
            recommendations.append(createWorkoutRecommendation(type: "full_body", scenario: scenario))
        case "endurance":
            recommendations.append(createWorkoutRecommendation(type: "cardio", scenario: scenario))
            recommendations.append(createWorkoutRecommendation(type: "hiit", scenario: scenario))
            recommendations.append(createWorkoutRecommendation(type: "full_body", scenario: scenario))
        default: // general_fitness
            recommendations.append(createWorkoutRecommendation(type: "full_body", scenario: scenario))
            recommendations.append(createWorkoutRecommendation(type: "cardio", scenario: scenario))
            recommendations.append(createWorkoutRecommendation(type: "strength", scenario: scenario))
        }
        
        return recommendations
    }
    
    private func generateDefaultRecommendations() -> [WorkoutRecommendation] {
        return [
            WorkoutRecommendation(
                name: "Morning Cardio",
                type: "cardio",
                confidence: 0.85,
                imageName: "jumping-jacks",
                accent: .workoutLightBlue,
                level: "Beginner",
                description: "Perfect start to your day with energizing cardio"
            ),
            WorkoutRecommendation(
                name: "Strength Builder",
                type: "strength",
                confidence: 0.78,
                imageName: "squats",
                accent: .workoutDarkBlue,
                level: "Intermediate",
                description: "Build lean muscle with targeted exercises"
            ),
            WorkoutRecommendation(
                name: "Yoga Flow",
                type: "yoga",
                confidence: 0.82,
                imageName: "lunge",
                accent: .workoutHydrationTeal,
                level: "Beginner",
                description: "Mindful movement and flexibility training"
            )
        ]
    }
    
    private func createWorkoutRecommendation(type: String, scenario: (age: Double, fitnessLevel: String, primaryGoal: String, preferredTime: String, bmiCategory: String, activityLevel: String)) -> WorkoutRecommendation {
        
        let confidence = Double.random(in: 0.75...0.95) // Simulated confidence
        
        switch type {
        case "cardio":
            return WorkoutRecommendation(
                name: "Cardio Blast",
                type: "cardio",
                confidence: confidence,
                imageName: "jumping-jacks",
                accent: .workoutLightBlue,
                level: mapFitnessLevel(scenario.fitnessLevel),
                description: "Heart-pumping cardio for \(scenario.primaryGoal.replacingOccurrences(of: "_", with: " "))"
            )
        case "strength":
            return WorkoutRecommendation(
                name: "Strength Training",
                type: "strength",
                confidence: confidence,
                imageName: "squats",
                accent: .workoutDarkBlue,
                level: mapFitnessLevel(scenario.fitnessLevel),
                description: "Build muscle with targeted strength exercises"
            )
        case "hiit":
            return WorkoutRecommendation(
                name: "HIIT Workout",
                type: "hiit",
                confidence: confidence,
                imageName: "abs-placeholder",
                accent: .workoutWaterBlue,
                level: mapFitnessLevel(scenario.fitnessLevel),
                description: "High-intensity interval training"
            )
        case "yoga":
            return WorkoutRecommendation(
                name: "Yoga Flow",
                type: "yoga",
                confidence: confidence,
                imageName: "lunge",
                accent: .workoutHydrationTeal,
                level: mapFitnessLevel(scenario.fitnessLevel),
                description: "Mindful movement and flexibility"
            )
        case "full_body":
            return WorkoutRecommendation(
                name: "Full Body Workout",
                type: "full_body",
                confidence: confidence,
                imageName: "abs-placeholder",
                accent: .workoutLightBlue,
                level: mapFitnessLevel(scenario.fitnessLevel),
                description: "Complete body conditioning routine"
            )
        default:
            return WorkoutRecommendation(
                name: "General Fitness",
                type: "general",
                confidence: confidence,
                imageName: "jumping-jacks",
                accent: .workoutWaterBlue,
                level: mapFitnessLevel(scenario.fitnessLevel),
                description: "Balanced fitness routine"
            )
        }
    }
    
    private func mapFitnessLevel(_ level: String) -> String {
        switch level {
        case "beginner": return "Beginner"
        case "intermediate": return "Intermediate"
        case "advanced": return "Advanced"
        default: return "Beginner"
        }
    }
}

// MARK: - Color Extensions for Workout Recommendations (with unique names)
extension Color {
    static let workoutLightBlue = Color(red: 0.4, green: 0.7, blue: 1.0)
    static let workoutDarkBlue = Color(red: 0.2, green: 0.4, blue: 0.8)
    static let workoutWaterBlue = Color(red: 0.3, green: 0.6, blue: 0.9)
    static let workoutHydrationTeal = Color(red: 0.2, green: 0.8, blue: 0.7)
}