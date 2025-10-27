import Foundation

struct Schedule: Identifiable, Codable, Hashable {
    let id: UUID
    let date: String
    let specialtyId: UUID
    let providerId: UUID
    let healthcarePlanId: UUID
    let createdAt: String?
    let updatedAt: String?
    
    // Joined fields from related tables
    var specialtyName: String?
    var providerName: String?
    var healthcarePlanName: String?
    var providerColorHex: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case date
        case specialtyId = "specialty_id"
        case providerId = "provider_id"
        case healthcarePlanId = "healthcare_plan_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case specialtyName = "specialty_name"
        case providerName = "provider_name"
        case healthcarePlanName = "healthcare_plan_name"
        case providerColorHex = "provider_color_hex"
    }
    
    // Unique key for deduplication: date + specialty + healthcare plan
    var uniqueKey: String {
        "\(date)_\(specialtyId)_\(healthcarePlanId)"
    }
}
