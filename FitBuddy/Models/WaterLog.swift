// WaterLog model for FitBuddy
import Foundation

struct WaterLog: Codable {
    var date: Date
    var amount: Double // in ml
    
    enum CodingKeys: String, CodingKey {
        case date
        case amount
    }
}
