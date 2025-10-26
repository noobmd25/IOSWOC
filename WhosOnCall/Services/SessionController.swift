//
//  SessionController.swift
//  WhosOnCall
//
//  Manages authentication session state using Supabase auth events
//

import Foundation
import Supabase
import Combine

@MainActor
class SessionController: ObservableObject {
    static let shared = SessionController()
    
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    
    private var cancellables = Set<AnyCancellable>()
    private let client = SupabaseClientProvider.shared.client
    
    private init() {
        setupAuthListener()
        checkInitialSession()
    }
    
    private func setupAuthListener() {
        // Listen to auth state changes
        Task {
            for await state in client.auth.authStateChanges {
                switch state {
                case .signedIn(let session):
                    self.isAuthenticated = true
                    self.currentUser = session.user
                case .signedOut:
                    self.isAuthenticated = false
                    self.currentUser = nil
                default:
                    break
                }
            }
        }
    }
    
    private func checkInitialSession() {
        Task {
            do {
                let session = try await client.auth.session
                self.isAuthenticated = true
                self.currentUser = session.user
            } catch {
                self.isAuthenticated = false
                self.currentUser = nil
            }
        }
    }
    
    func signOut() async throws {
        try await client.auth.signOut()
    }
}
