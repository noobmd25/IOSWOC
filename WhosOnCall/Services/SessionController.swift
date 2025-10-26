import Foundation
import Combine
import Supabase

@MainActor
class SessionController: ObservableObject {
    static let shared = SessionController()
    
    @Published var isAuthenticated = false
    @Published var currentUserId: UUID?
    
    private var cancellables = Set<AnyCancellable>()
    private let client = SupabaseClientProvider.shared.client
    
    private init() {
        observeAuthStateChanges()
    }
    
    private func observeAuthStateChanges() {
        Task {
            for await state in await client.auth.authStateChanges {
                switch state {
                case .signedIn(let session):
                    self.isAuthenticated = true
                    self.currentUserId = session.user.id
                case .signedOut:
                    self.isAuthenticated = false
                    self.currentUserId = nil
                default:
                    break
                }
            }
        }
    }
    
    func checkSession() async {
        do {
            let session = try await client.auth.session
            self.isAuthenticated = true
            self.currentUserId = session.user.id
        } catch {
            self.isAuthenticated = false
            self.currentUserId = nil
        }
    }
}
