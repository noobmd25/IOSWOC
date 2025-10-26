import Foundation

enum UserRole: String, Codable {
    case viewer
    case scheduler
    case admin
}

enum UserStatus: String, Codable {
    case active
    case inactive
}

struct Profile: Identifiable, Codable {
    let id: UUID
    let role: UserRole
    let status: UserStatus
    
    enum CodingKeys: String, CodingKey {
        case id
        case role
        case status
    }
}
