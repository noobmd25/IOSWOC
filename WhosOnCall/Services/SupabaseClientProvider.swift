//
//  SupabaseClientProvider.swift
//  WhosOnCall
//
//  Singleton provider for Supabase client instance
//

import Foundation
import Supabase

class SupabaseClientProvider {
    static let shared = SupabaseClientProvider()
    
    let client: SupabaseClient
    
    private init() {
        // TODO: Replace with your actual Supabase URL and Anon Key
        // Get these from your Supabase project settings
        let supabaseURL = URL(string: "https://your-project.supabase.co")!
        let supabaseKey = "your-anon-key-here"
        
        client = SupabaseClient(
            supabaseURL: supabaseURL,
            supabaseKey: supabaseKey
        )
    }
}
