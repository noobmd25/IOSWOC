//
//  DirectoryViewModel.swift
//  WhosOnCall
//
//  ViewModel for directory list with debounced search
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
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupDebounce()
    }
    
    private func setupDebounce() {
        // Debounce search text changes
        $searchText
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] _ in
                Task {
                    await self?.loadDirectory()
                }
            }
            .store(in: &cancellables)
    }
    
    func loadDirectory() async {
        isLoading = true
        errorMessage = nil
        
        do {
            entries = try await dataService.directory(
                searchText: searchText.isEmpty ? nil : searchText
            )
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func refresh() async {
        await loadDirectory()
    }
}
