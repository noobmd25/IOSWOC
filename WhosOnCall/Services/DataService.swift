import Foundation
import Supabase
import Realtime

struct ScheduleFilters {
    var searchQuery: String?
    var specialtyId: UUID?
    var healthcarePlanId: UUID?
}

struct DirectoryFilters {
    var searchQuery: String?
}

@MainActor
class DataService: ObservableObject {
    private let client = SupabaseClientProvider.shared.client
    
    // MARK: - Schedules
    func fetchSchedules(filters: ScheduleFilters) async throws -> [Schedule] {
        var query = client.database
            .from("schedules")
            .select("""
                id,
                date,
                specialty_id,
                provider_id,
                healthcare_plan_id,
                created_at,
                updated_at,
                specialties:specialty_id(name),
                directory:provider_id(provider_name, color_hex),
                healthcare_plans:healthcare_plan_id(name)
            """)
        
        // Apply filters
        if let specialtyId = filters.specialtyId {
            query = query.eq("specialty_id", value: specialtyId.uuidString)
        }
        
        if let planId = filters.healthcarePlanId {
            query = query.eq("healthcare_plan_id", value: planId.uuidString)
        }
        
        // Apply search (handled client-side for joined fields)
        query = query.order("date", ascending: true)
        
        let response: [ScheduleResponse] = try await query.execute().value
        
        // Map to Schedule model and apply search filter
        var schedules = response.map { resp in
            Schedule(
                id: resp.id,
                date: resp.date,
                specialtyId: resp.specialtyId,
                providerId: resp.providerId,
                healthcarePlanId: resp.healthcarePlanId,
                createdAt: resp.createdAt,
                updatedAt: resp.updatedAt,
                specialtyName: resp.specialties?.name,
                providerName: resp.directory?.providerName,
                healthcarePlanName: resp.healthcarePlans?.name,
                providerColorHex: resp.directory?.colorHex
            )
        }
        
        // Apply search filter client-side
        if let searchQuery = filters.searchQuery, !searchQuery.isEmpty {
            let lowercasedQuery = searchQuery.lowercased()
            schedules = schedules.filter { schedule in
                (schedule.providerName?.lowercased().contains(lowercasedQuery) ?? false) ||
                (schedule.specialtyName?.lowercased().contains(lowercasedQuery) ?? false) ||
                (schedule.healthcarePlanName?.lowercased().contains(lowercasedQuery) ?? false)
            }
        }
        
        // Defensive deduplication by uniqueKey
        var seen = Set<String>()
        schedules = schedules.filter { schedule in
            seen.insert(schedule.uniqueKey).inserted
        }
        
        return schedules
    }
    
    // MARK: - Directory
    func fetchDirectory(filters: DirectoryFilters) async throws -> [DirectoryEntry] {
        var query = client.database
            .from("directory")
            .select("""
                id,
                provider_name,
                specialty_id,
                phone_number,
                resident_phone,
                color_hex,
                specialties:specialty_id(name)
            """)
        
        query = query.order("provider_name", ascending: true)
        
        let response: [DirectoryResponse] = try await query.execute().value
        
        // Map to DirectoryEntry model
        var entries = response.map { resp in
            DirectoryEntry(
                id: resp.id,
                providerName: resp.providerName,
                specialtyId: resp.specialtyId,
                phoneNumber: resp.phoneNumber,
                residentPhone: resp.residentPhone,
                colorHex: resp.colorHex,
                specialtyName: resp.specialties?.name
            )
        }
        
        // Apply search filter client-side
        if let searchQuery = filters.searchQuery, !searchQuery.isEmpty {
            let lowercasedQuery = searchQuery.lowercased()
            entries = entries.filter { entry in
                entry.providerName.lowercased().contains(lowercasedQuery) ||
                (entry.specialtyName?.lowercased().contains(lowercasedQuery) ?? false)
            }
        }
        
        return entries
    }
    
    // MARK: - Lookup Data
    func fetchSpecialties() async throws -> [Specialty] {
        let response: [Specialty] = try await client.database
            .from("specialties")
            .select()
            .order("name", ascending: true)
            .execute()
            .value
        return response
    }
    
    func fetchHealthCarePlans() async throws -> [HealthCarePlan] {
        let response: [HealthCarePlan] = try await client.database
            .from("healthcare_plans")
            .select()
            .order("name", ascending: true)
            .execute()
            .value
        return response
    }
}

// MARK: - Response Models (for decoding joined queries)
private struct ScheduleResponse: Decodable {
    let id: UUID
    let date: String
    let specialtyId: UUID
    let providerId: UUID
    let healthcarePlanId: UUID
    let createdAt: String?
    let updatedAt: String?
    let specialties: SpecialtyName?
    let directory: DirectoryName?
    let healthcarePlans: PlanName?
    
    struct SpecialtyName: Decodable {
        let name: String
    }
    
    struct DirectoryName: Decodable {
        let providerName: String
        let colorHex: String?
        
        enum CodingKeys: String, CodingKey {
            case providerName = "provider_name"
            case colorHex = "color_hex"
        }
    }
    
    struct PlanName: Decodable {
        let name: String
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case date
        case specialtyId = "specialty_id"
        case providerId = "provider_id"
        case healthcarePlanId = "healthcare_plan_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case specialties
        case directory
        case healthcarePlans = "healthcare_plans"
    }
}

private struct DirectoryResponse: Decodable {
    let id: UUID
    let providerName: String
    let specialtyId: UUID
    let phoneNumber: String
    let residentPhone: String?
    let colorHex: String?
    let specialties: SpecialtyName?
    
    struct SpecialtyName: Decodable {
        let name: String
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case providerName = "provider_name"
        case specialtyId = "specialty_id"
        case phoneNumber = "phone_number"
        case residentPhone = "resident_phone"
        case colorHex = "color_hex"
        case specialties
    }
}
