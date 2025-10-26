//
//  AuthViewModel.swift
//  WhosOnCall
//
//  ViewModel for authentication operations
//

import Foundation
import Supabase

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
            // Session controller will automatically update auth state
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func signUp() async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter both email and password"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await client.auth.signUp(email: email, password: password)
            // Session controller will automatically update auth state
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
