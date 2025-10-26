import SwiftUI

struct ScheduleListView: View {
    @StateObject private var viewModel = ScheduleViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.schedules.isEmpty {
                    ProgressView("Loading schedules...")
                } else if viewModel.schedules.isEmpty {
                    ContentUnavailableView(
                        "No Schedules",
                        systemImage: "calendar.badge.exclamationmark",
                        description: Text("No schedules found matching your criteria.")
                    )
                } else {
                    List {
                        ForEach(viewModel.schedules) { schedule in
                            ScheduleRow(schedule: schedule)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("On-Call Schedule")
            .searchable(text: $viewModel.searchQuery, prompt: "Search schedules")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Picker("Specialty", selection: $viewModel.selectedSpecialtyId) {
                            Text("All Specialties").tag(nil as UUID?)
                            ForEach(viewModel.specialties) { specialty in
                                Text(specialty.name).tag(specialty.id as UUID?)
                            }
                        }
                        
                        Picker("Healthcare Plan", selection: $viewModel.selectedHealthcarePlanId) {
                            Text("All Plans").tag(nil as UUID?)
                            ForEach(viewModel.healthcarePlans) { plan in
                                Text(plan.name).tag(plan.id as UUID?)
                            }
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .refreshable {
                await viewModel.refresh()
            }
            .task {
                await viewModel.loadInitialData()
            }
        }
    }
}

struct ScheduleRow: View {
    let schedule: Schedule
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(formatDate(schedule.date))
                    .font(.headline)
                Spacer()
                if let planName = schedule.healthcarePlanName,
                   schedule.specialtyName?.contains("Internal Medicine") == true {
                    Text(planName)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.2))
                        .foregroundColor(.blue)
                        .cornerRadius(8)
                }
            }
            
            HStack(spacing: 12) {
                Circle()
                    .fill(providerColor(hex: schedule.providerColorHex, id: schedule.providerId))
                    .frame(width: 12, height: 12)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(schedule.providerName ?? "Unknown Provider")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    HStack {
                        if let specialty = schedule.specialtyName {
                            Text(specialty)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        if let plan = schedule.healthcarePlanName {
                            Text("•")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(plan)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        guard let date = formatter.date(from: dateString) else {
            return dateString
        }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        return displayFormatter.string(from: date)
    }
    
    private func providerColor(hex: String?, id: UUID) -> Color {
        if let hex = hex, let color = Color(hex: hex) {
            return color
        }
        // Deterministic color from provider ID
        return deterministicColor(from: id)
    }
    
    private func deterministicColor(from uuid: UUID) -> Color {
        let hash = uuid.hashValue
        let hue = Double(abs(hash) % 360) / 360.0
        return Color(hue: hue, saturation: 0.6, brightness: 0.8)
    }
}

// MARK: - Color Extension
extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    ScheduleListView()
}
