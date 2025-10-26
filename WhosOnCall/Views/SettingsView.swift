//
//  SettingsView.swift
//  WhosOnCall
//
//  Settings screen with sign out functionality
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var sessionController: SessionController
    @State private var isSigningOut = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            List {
                // User Info Section
                Section {
                    if let user = sessionController.currentUser {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .font(.largeTitle)
                                .foregroundColor(.blue)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Signed in as:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(user.email ?? "Unknown")
                                    .font(.body)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                } header: {
                    Text("Account")
                }
                
                // About Section
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Build")
                        Spacer()
                        Text("1")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("About")
                }
                
                // Actions Section
                Section {
                    Button(role: .destructive, action: {
                        Task {
                            await signOut()
                        }
                    }) {
                        HStack {
                            if isSigningOut {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                Spacer()
                                Text("Signing Out...")
                            } else {
                                Spacer()
                                Text("Sign Out")
                                Spacer()
                            }
                        }
                    }
                    .disabled(isSigningOut)
                }
                
                // Error Message
                if let errorMessage = errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
    
    private func signOut() async {
        isSigningOut = true
        errorMessage = nil
        
        do {
            try await sessionController.signOut()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isSigningOut = false
    }
}

#Preview {
    SettingsView()
        .environmentObject(SessionController.shared)
}
