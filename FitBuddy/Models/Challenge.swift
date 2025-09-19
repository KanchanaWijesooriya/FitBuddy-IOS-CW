// Challenge model

import Foundation
struct Challenge {
    var id: UUID
    var name: String
    var type: String // steps, water, consistency
    var goal: Int
    var isJoined: Bool
}
