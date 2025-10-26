import Foundation
import Supabase

class SupabaseClientProvider {
    static let shared = SupabaseClientProvider()
    
    // MARK: - Configuration
    // TODO: Replace with your Supabase project URL and anon key
    private let supabaseURL = URL(string: "https://YOUR_PROJECT_ID.supabase.co")!
    private let supabaseAnonKey = "YOUR_SUPABASE_ANON_KEY"
    
    private(set) var client: SupabaseClient!
    
    private init() {
        client = SupabaseClient(
            supabaseURL: supabaseURL,
            supabaseKey: supabaseAnonKey
        )
    }
}
