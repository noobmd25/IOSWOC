import SwiftUI

struct SettingsView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @EnvironmentObject var sessionController: SessionController
    
    var body: some View {
        NavigationStack {
            List {
                Section("Account") {
                    if let userId = sessionController.currentUserId {
                        LabeledContent("User ID", value: userId.uuidString)
                            .font(.caption)
                    }
                }
                
                Section("App Information") {
                    LabeledContent("Version", value: "1.0.0")
                    LabeledContent("Build", value: "1")
                }
                
                Section {
                    Button(role: .destructive) {
                        Task {
                            await authViewModel.signOut()
                        }
                    } label: {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Sign Out")
                        }
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(SessionController.shared)
}
