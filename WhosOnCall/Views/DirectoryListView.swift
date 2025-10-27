import SwiftUI

struct DirectoryListView: View {
    @StateObject private var viewModel = DirectoryViewModel()
    
    // Specialties that should show resident phone
    private let residentPhoneSpecialties = [
        "Internal Medicine",
        "Emergency Medicine",
        "Surgery"
    ]
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.entries.isEmpty {
                    ProgressView("Loading directory...")
                } else if viewModel.entries.isEmpty {
                    ContentUnavailableView(
                        "No Providers",
                        systemImage: "person.text.rectangle",
                        description: Text("No providers found matching your criteria.")
                    )
                } else {
                    List {
                        ForEach(viewModel.entries) { entry in
                            DirectoryRow(
                                entry: entry,
                                showResidentPhone: shouldShowResidentPhone(entry)
                            )
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Provider Directory")
            .searchable(text: $viewModel.searchQuery, prompt: "Search providers")
            .refreshable {
                await viewModel.refresh()
            }
            .task {
                await viewModel.loadDirectory()
            }
        }
    }
    
    private func shouldShowResidentPhone(_ entry: DirectoryEntry) -> Bool {
        guard let specialtyName = entry.specialtyName else { return false }
        return residentPhoneSpecialties.contains { specialty in
            specialtyName.lowercased().contains(specialty.lowercased())
        }
    }
}

struct DirectoryRow: View {
    let entry: DirectoryEntry
    let showResidentPhone: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(providerColor(hex: entry.colorHex, id: entry.id))
                .frame(width: 40, height: 40)
                .overlay(
                    Text(initials(from: entry.providerName))
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.providerName)
                    .font(.headline)
                
                if let specialty = entry.specialtyName {
                    Text(specialty)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                HStack(spacing: 16) {
                    if showResidentPhone, let residentPhone = entry.residentPhone {
                        PhoneButton(
                            label: "Resident",
                            phone: residentPhone
                        )
                    } else {
                        PhoneButton(
                            label: "Direct",
                            phone: entry.phoneNumber
                        )
                    }
                    
                    if showResidentPhone && entry.residentPhone != nil {
                        PhoneButton(
                            label: "Alt",
                            phone: entry.phoneNumber
                        )
                    }
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
    
    private func initials(from name: String) -> String {
        let components = name.split(separator: " ")
        let initials = components.prefix(2).compactMap { $0.first }.map { String($0) }
        return initials.joined().uppercased()
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

struct PhoneButton: View {
    let label: String
    let phone: String
    
    var body: some View {
        Button {
            if let url = URL(string: "tel://\(phone)") {
                UIApplication.shared.open(url)
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "phone.fill")
                    .font(.caption2)
                Text(label)
                    .font(.caption)
                Text(formatPhone(phone))
                    .font(.caption)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.blue.opacity(0.1))
            .foregroundColor(.blue)
            .cornerRadius(6)
        }
    }
    
    private func formatPhone(_ phone: String) -> String {
        let cleaned = phone.filter { $0.isNumber }
        if cleaned.count == 10 {
            let areaCode = cleaned.prefix(3)
            let prefix = cleaned.dropFirst(3).prefix(3)
            let suffix = cleaned.suffix(4)
            return "(\(areaCode)) \(prefix)-\(suffix)"
        }
        return phone
    }
}

#Preview {
    DirectoryListView()
}
