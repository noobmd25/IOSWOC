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
    
    // IMPORTANT: Replace these with your actual Supabase project credentials
    // Get these from your Supabase project settings at https://app.supabase.com
    private let supabaseURL = URL(string: "YOUR_SUPABASE_URL")!
    private let supabaseKey = "YOUR_SUPABASE_ANON_KEY"
    
    let client: SupabaseClient
    
    private init() {
        client = SupabaseClient(
            supabaseURL: supabaseURL,
            supabaseKey: supabaseKey
        )
    }
}
