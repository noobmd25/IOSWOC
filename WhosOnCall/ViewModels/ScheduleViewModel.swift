//
//  ScheduleViewModel.swift
//  WhosOnCall
//
//  ViewModel for schedule list with search, filters, and refresh
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
                    await self?.loadSchedules()
                }
            }
            .store(in: &cancellables)
        
        // Reload when filters change
        Publishers.CombineLatest($selectedSpecialty, $selectedHealthcarePlan)
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] _, _ in
                Task {
                    await self?.loadSchedules()
                }
            }
            .store(in: &cancellables)
    }
    
    func loadSchedules() async {
        isLoading = true
        errorMessage = nil
        
        do {
            schedules = try await dataService.schedules(
                searchText: searchText.isEmpty ? nil : searchText,
                specialty: selectedSpecialty,
                healthcarePlan: selectedHealthcarePlan
            )
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func refresh() async {
        await loadSchedules()
    }
}
