//
//  SettingsView.swift
//  WhosOnCall
//
//  Settings screen with sign out option
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = AuthViewModel()
    @EnvironmentObject var sessionController: SessionController
    
    var body: some View {
        NavigationStack {
            List {
                Section("Account") {
                    if let user = sessionController.currentUser {
                        HStack {
                            Text("Email")
                            Spacer()
                            Text(user.email ?? "N/A")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section {
                    Button(action: {
                        Task {
                            await viewModel.signOut()
                        }
                    }) {
                        if viewModel.isLoading {
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                        } else {
                            HStack {
                                Spacer()
                                Text("Sign Out")
                                    .foregroundColor(.red)
                                Spacer()
                            }
                        }
                    }
                    .disabled(viewModel.isLoading)
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("App Name")
                        Spacer()
                        Text("WOC - Who's On Call")
                            .foregroundColor(.secondary)
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
