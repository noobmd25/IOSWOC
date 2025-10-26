//
//  Schedule.swift
//  WhosOnCall
//
//  Model representing an on-call schedule entry
//

import Foundation

struct Schedule: Identifiable, Codable, Equatable {
    let id: UUID
    let date: Date
    let specialty: String
    let provider: String
    let healthcarePlan: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case date
        case specialty
        case provider
        case healthcarePlan = "healthcare_plan"
    }
    
    init(id: UUID = UUID(), date: Date, specialty: String, provider: String, healthcarePlan: String) {
        self.id = id
        self.date = date
        self.specialty = specialty
        self.provider = provider
        self.healthcarePlan = healthcarePlan
    }
}
