//
//  DataService.swift
//  WhosOnCall
//
//  Handles Supabase queries for schedules and directory with safe builder pattern
//

import Foundation
import Supabase
import PostgREST

class DataService {
    private let client = SupabaseClientProvider.shared.client
    
    // MARK: - Schedule Queries
    
    func schedules(
        searchText: String? = nil,
        specialty: String? = nil,
        healthcarePlan: String? = nil
    ) async throws -> [Schedule] {
        var query = client.database
            .from("schedules")
            .select()
        
        // Apply filters
        if let searchText = searchText, !searchText.isEmpty {
            query = query.ilike("provider", value: "%\(searchText)%")
        }
        
        if let specialty = specialty, !specialty.isEmpty {
            query = query.eq("specialty", value: specialty)
        }
        
        if let healthcarePlan = healthcarePlan, !healthcarePlan.isEmpty {
            query = query.eq("healthcare_plan", value: healthcarePlan)
        }
        
        // Apply ordering
        query = query.order("date", ascending: false)
        
        let response: [Schedule] = try await query.execute().value
        return response
    }
    
    // MARK: - Directory Queries
    
    func directory(searchText: String? = nil) async throws -> [DirectoryEntry] {
        var query = client.database
            .from("directory")
            .select()
        
        // Apply search filter
        if let searchText = searchText, !searchText.isEmpty {
            query = query.or("provider_name.ilike.%\(searchText)%,specialty.ilike.%\(searchText)%")
        }
        
        // Apply ordering
        query = query.order("provider_name", ascending: true)
        
        let response: [DirectoryEntry] = try await query.execute().value
        return response
    }
}
