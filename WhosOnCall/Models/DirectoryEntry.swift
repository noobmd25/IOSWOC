//
//  DirectoryEntry.swift
//  WhosOnCall
//
//  Model representing a provider directory entry
//

import Foundation

struct DirectoryEntry: Identifiable, Codable, Equatable {
    let id: UUID
    let providerName: String
    let specialty: String
    let phoneNumber: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case providerName = "provider_name"
        case specialty
        case phoneNumber = "phone_number"
    }
    
    init(id: UUID = UUID(), providerName: String, specialty: String, phoneNumber: String) {
        self.id = id
        self.providerName = providerName
        self.specialty = specialty
        self.phoneNumber = phoneNumber
    }
    
    var phoneURL: URL? {
        let cleaned = phoneNumber.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        return URL(string: "tel://\(cleaned)")
    }
}
