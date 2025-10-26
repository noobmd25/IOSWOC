//
//  DirectoryEntry.swift
//  WhosOnCall
//
//  Model representing a provider directory entry
//

import Foundation

struct DirectoryEntry: Identifiable, Codable {
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
}
