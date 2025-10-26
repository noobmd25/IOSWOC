//
//  DirectoryListView.swift
//  WhosOnCall
//
//  Displays provider directory with search and tap-to-call
//

import SwiftUI

struct DirectoryListView: View {
    @StateObject private var viewModel = DirectoryViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading && viewModel.entries.isEmpty {
                    ProgressView("Loading directory...")
                } else if let errorMessage = viewModel.errorMessage, viewModel.entries.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.orange)
                        Text(errorMessage)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                } else {
                    List(viewModel.entries) { entry in
                        DirectoryRow(entry: entry)
                    }
                    .listStyle(.insetGrouped)
                    .refreshable {
                        await viewModel.refresh()
                    }
                }
            }
            .navigationTitle("Directory")
            .searchable(text: $viewModel.searchText, prompt: "Search provider or specialty")
            .onChange(of: viewModel.searchText) { oldValue, newValue in
                viewModel.onSearchTextChanged(newValue)
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
                
                Text(entry.specialty)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Link(destination: URL(string: "tel://\(entry.phoneNumber.filter { $0.isNumber })")!) {
                HStack(spacing: 4) {
                    Image(systemName: "phone.fill")
                    Text(entry.phoneNumber)
                }
                .font(.caption)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    DirectoryListView()
}
