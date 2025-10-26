//
//  DirectoryViewModel.swift
//  WhosOnCall
//
//  ViewModel for managing provider directory list
//

import Foundation
import Combine

@MainActor
class DirectoryViewModel: ObservableObject {
    @Published var entries: [DirectoryEntry] = []
    @Published var searchText = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let dataService = DataService()
    private var searchCancellable: AnyCancellable?
    
    // Debounced search
    private let searchSubject = PassthroughSubject<String, Never>()
    
    init() {
        setupSearchDebounce()
    }
    
    private func setupSearchDebounce() {
        searchCancellable = searchSubject
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                Task {
                    await self?.loadDirectory()
                }
            }
    }
    
    func onSearchTextChanged(_ text: String) {
        searchText = text
        searchSubject.send(text)
    }
    
    func loadDirectory() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let query = searchText.isEmpty ? nil : searchText
            entries = try await dataService.directory(searchQuery: query)
        } catch {
            errorMessage = "Failed to load directory: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func refresh() async {
        await loadDirectory()
    }
}
