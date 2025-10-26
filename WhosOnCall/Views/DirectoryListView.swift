//
//  DirectoryListView.swift
//  WhosOnCall
//
//  List view for provider directory with search and tap-to-call
//

import SwiftUI

struct DirectoryListView: View {
    @StateObject private var viewModel = DirectoryViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                if viewModel.isLoading && viewModel.entries.isEmpty {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                } else if viewModel.entries.isEmpty {
                    Text("No providers found")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    ForEach(viewModel.entries) { entry in
                        DirectoryRow(entry: entry)
                    }
                }
                
                // Error Message
                if let errorMessage = viewModel.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("Directory")
            .searchable(text: $viewModel.searchText, prompt: "Search provider or specialty")
            .refreshable {
                await viewModel.refresh()
            }
            .task {
                await viewModel.loadDirectory()
            }
        }
    }
}

struct DirectoryRow: View {
    let entry: DirectoryEntry
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(entry.providerName)
                    .font(.headline)
                
                Label(entry.specialty, systemImage: "stethoscope")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
            
            Spacer()
            
            if let phoneURL = entry.phoneURL {
                Link(destination: phoneURL) {
                    HStack(spacing: 4) {
                        Image(systemName: "phone.fill")
                        Text(entry.phoneNumber)
                    }
                    .font(.subheadline)
                    .foregroundColor(.green)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(8)
                }
            } else {
                Text(entry.phoneNumber)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    DirectoryListView()
}
