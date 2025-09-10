// User model for FitBuddy
import Foundation

struct User {
    var id: UUID
    var uid: String? // Firebase user ID
    var name: String
    var email: String?
    var age: Int
    var weight: Double
    var dailyStepGoal: Int
    var dailyWaterGoal: Double
    var profileImageURL: String?
    var createdAt: Date?
    var isFaceIDEnabled: Bool
    
    init(id: UUID = UUID(), uid: String? = nil, name: String, email: String? = nil, age: Int = 25, weight: Double = 70.0, dailyStepGoal: Int = 10000, dailyWaterGoal: Double = 2.5, profileImageURL: String? = nil, createdAt: Date? = Date(), isFaceIDEnabled: Bool = false) {
        self.id = id
        self.uid = uid
        self.name = name
        self.email = email
        self.age = age
        self.weight = weight
        self.dailyStepGoal = dailyStepGoal
        self.dailyWaterGoal = dailyWaterGoal
        self.profileImageURL = profileImageURL
        self.createdAt = createdAt
        self.isFaceIDEnabled = isFaceIDEnabled
    }
}
