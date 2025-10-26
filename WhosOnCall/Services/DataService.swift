//
//  DataService.swift
//  WhosOnCall
//
//  Service for fetching schedules and directory data from Supabase
//

import Foundation
import Supabase

enum DataServiceError: Error {
    case invalidQuery
    case decodingError
    case networkError(Error)
}

class DataService {
    private let client = SupabaseClientProvider.shared.client
    
    // MARK: - Schedule Queries
    
    func schedules(
        searchQuery: String? = nil,
        specialty: String? = nil,
        healthcarePlan: String? = nil
    ) async throws -> [Schedule] {
        var query = client.from("schedules")
            .select()
        
        // Apply filters
        if let specialty = specialty, !specialty.isEmpty {
            query = query.eq("specialty", value: specialty)
        }
        
        if let healthcarePlan = healthcarePlan, !healthcarePlan.isEmpty {
            query = query.eq("healthcare_plan", value: healthcarePlan)
        }
        
        if let searchQuery = searchQuery, !searchQuery.isEmpty {
            query = query.ilike("provider", pattern: "%\(searchQuery)%")
        }
        
        // Transform: order and limit
        query = query.order("date", ascending: false).limit(100)
        
        do {
            let response: [Schedule] = try await query.execute().value
            return response
        } catch {
            throw DataServiceError.networkError(error)
        }
    }
    
    // MARK: - Directory Queries
    
    func directory(
        searchQuery: String? = nil
    ) async throws -> [DirectoryEntry] {
        var query = client.from("directory")
            .select()
        
        // Apply search filter
        if let searchQuery = searchQuery, !searchQuery.isEmpty {
            query = query.or("provider_name.ilike.%\(searchQuery)%,specialty.ilike.%\(searchQuery)%")
        }
        
        // Transform: order and limit
        query = query.order("provider_name", ascending: true).limit(100)
        
        do {
            let response: [DirectoryEntry] = try await query.execute().value
            return response
        } catch {
            throw DataServiceError.networkError(error)
        }
    }
}
