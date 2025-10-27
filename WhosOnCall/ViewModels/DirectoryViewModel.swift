import Foundation
import Combine
import Supabase
import Realtime

@MainActor
class DirectoryViewModel: ObservableObject {
    @Published var entries: [DirectoryEntry] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchQuery = ""
    
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
                    await self?.loadDirectory()
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupRealtimeSubscription() {
        realtimeChannel = client.realtimeV2.channel("directory")
        
        realtimeChannel?.onPostgresChange(
            event: .all,
            schema: "public",
            table: "directory"
        ) { [weak self] _ in
            Task { @MainActor in
                await self?.loadDirectory()
            }
        }
        
        Task {
            await realtimeChannel?.subscribe()
        }
    }
    
    func loadDirectory() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let filters = DirectoryFilters(
                searchQuery: searchQuery.isEmpty ? nil : searchQuery
            )
            entries = try await dataService.fetchDirectory(filters: filters)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func refresh() async {
        await loadDirectory()
    }
    
    deinit {
        Task {
            await realtimeChannel?.unsubscribe()
        }
    }
}
