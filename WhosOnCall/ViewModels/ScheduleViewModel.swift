import Foundation
import Combine
import Supabase
import Realtime

@MainActor
class ScheduleViewModel: ObservableObject {
    @Published var schedules: [Schedule] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchQuery = ""
    @Published var selectedSpecialtyId: UUID?
    @Published var selectedHealthcarePlanId: UUID?
    @Published var specialties: [Specialty] = []
    @Published var healthcarePlans: [HealthCarePlan] = []
    
    private let dataService = DataService()
    private var cancellables = Set<AnyCancellable>()
    private var realtimeChannel: RealtimeChannelV2?
    private let client = SupabaseClientProvider.shared.client
    
    init() {
        setupSearchDebounce()
        setupRealtimeSubscription()
    }
    
    private func setupSearchDebounce() {
        // Debounce search query by 300ms
        $searchQuery
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                Task {
                    await self?.loadSchedules()
                }
            }
            .store(in: &cancellables)
        
        // Reload on filter changes
        $selectedSpecialtyId
            .dropFirst()
            .sink { [weak self] _ in
                Task {
                    await self?.loadSchedules()
                }
            }
            .store(in: &cancellables)
        
        $selectedHealthcarePlanId
            .dropFirst()
            .sink { [weak self] _ in
                Task {
                    await self?.loadSchedules()
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupRealtimeSubscription() {
        realtimeChannel = client.realtimeV2.channel("schedules")
        
        realtimeChannel?.onPostgresChange(
            event: .all,
            schema: "public",
            table: "schedules"
        ) { [weak self] _ in
            Task { @MainActor in
                await self?.loadSchedules()
            }
        }
        
        Task {
            await realtimeChannel?.subscribe()
        }
    }
    
    func loadInitialData() async {
        await loadSpecialties()
        await loadHealthcarePlans()
        await loadSchedules()
    }
    
    func loadSchedules() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let filters = ScheduleFilters(
                searchQuery: searchQuery.isEmpty ? nil : searchQuery,
                specialtyId: selectedSpecialtyId,
                healthcarePlanId: selectedHealthcarePlanId
            )
            schedules = try await dataService.fetchSchedules(filters: filters)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func loadSpecialties() async {
        do {
            specialties = try await dataService.fetchSpecialties()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func loadHealthcarePlans() async {
        do {
            healthcarePlans = try await dataService.fetchHealthCarePlans()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func refresh() async {
        await loadSchedules()
    }
    
    deinit {
        Task {
            await realtimeChannel?.unsubscribe()
        }
    }
}
