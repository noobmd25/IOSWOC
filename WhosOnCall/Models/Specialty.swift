import Foundation

struct Specialty: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let slug: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case slug
    }
}
