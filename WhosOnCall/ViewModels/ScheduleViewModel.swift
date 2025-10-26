//
//  ScheduleViewModel.swift
//  WhosOnCall
//
//  ViewModel for managing schedule list and filtering
//

import Foundation
import Combine

@MainActor
class ScheduleViewModel: ObservableObject {
    @Published var schedules: [Schedule] = []
    @Published var searchText = ""
    @Published var selectedSpecialty: String?
    @Published var selectedHealthcarePlan: String?
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
                    await self?.loadSchedules()
                }
            }
    }
    
    func onSearchTextChanged(_ text: String) {
        searchText = text
        searchSubject.send(text)
    }
    
    func loadSchedules() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let query = searchText.isEmpty ? nil : searchText
            schedules = try await dataService.schedules(
                searchQuery: query,
                specialty: selectedSpecialty,
                healthcarePlan: selectedHealthcarePlan
            )
        } catch {
            errorMessage = "Failed to load schedules: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func refresh() async {
        await loadSchedules()
    }
}
