//
//  AuthViewModel.swift
//  WhosOnCall
//
//  ViewModel for handling authentication logic
//

import Foundation
import Supabase
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let client = SupabaseClientProvider.shared.client
    
    func signIn() async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter both email and password"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await client.auth.signIn(email: email, password: password)
            // Session controller will automatically update authentication state
        } catch {
            errorMessage = "Sign in failed: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func signOut() async {
        isLoading = true
        
        do {
            try await client.auth.signOut()
        } catch {
            errorMessage = "Sign out failed: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}
