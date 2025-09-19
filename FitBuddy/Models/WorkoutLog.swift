// WorkoutLog model

import Foundation

struct WorkoutLog: Codable {
    var id: UUID
    var workoutType: String
    var duration: Int // in minutes
    var caloriesBurned: Int
    var date: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case workoutType = "type"
        case duration
        case caloriesBurned
        case date
    }
    
    init(id: UUID = UUID(), workoutType: String, duration: Int, caloriesBurned: Int, date: Date = Date()) {
        self.id = id
        self.workoutType = workoutType
        self.duration = duration
        self.caloriesBurned = caloriesBurned
        self.date = date
    }
}
