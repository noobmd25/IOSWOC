import Foundation

struct DirectoryEntry: Identifiable, Codable, Hashable {
    let id: UUID
    let providerName: String
    let specialtyId: UUID
    let phoneNumber: String
    let residentPhone: String?
    let colorHex: String?
    
    // Joined fields
    var specialtyName: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case providerName = "provider_name"
        case specialtyId = "specialty_id"
        case phoneNumber = "phone_number"
        case residentPhone = "resident_phone"
        case colorHex = "color_hex"
        case specialtyName = "specialty_name"
    }
}
