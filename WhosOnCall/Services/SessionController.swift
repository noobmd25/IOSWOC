//
//  SessionController.swift
//  WhosOnCall
//
//  Manages user authentication session state using Supabase auth events
//

import Foundation
import Supabase
import Combine

@MainActor
class SessionController: ObservableObject {
    static let shared = SessionController()
    
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    
    private let client = SupabaseClientProvider.shared.client
    private var authStateTask: Task<Void, Never>?
    
    private init() {
        setupAuthStateListener()
        checkCurrentSession()
    }
    
    private func setupAuthStateListener() {
        authStateTask = Task {
            for await state in client.auth.authStateChanges {
                switch state {
                case .signedIn(let session):
                    self.isAuthenticated = true
                    self.currentUser = session.user
                case .signedOut, .userDeleted:
                    self.isAuthenticated = false
                    self.currentUser = nil
                default:
                    break
                }
            }
        }
    }
    
    private func checkCurrentSession() {
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
    
    deinit {
        authStateTask?.cancel()
    }
}
