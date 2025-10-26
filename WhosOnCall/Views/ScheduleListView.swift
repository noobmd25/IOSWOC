//
//  ScheduleListView.swift
//  WhosOnCall
//
//  List view for on-call schedules with search and filters
//

import SwiftUI

struct ScheduleListView: View {
    @StateObject private var viewModel = ScheduleViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                // Filters Section
                Section {
                    // Specialty Filter
                    HStack {
                        Text("Specialty")
                            .foregroundColor(.secondary)
                        Spacer()
                        Menu {
                            Button("All") {
                                viewModel.selectedSpecialty = nil
                            }
                            Button("Cardiology") {
                                viewModel.selectedSpecialty = "Cardiology"
                            }
                            Button("Emergency Medicine") {
                                viewModel.selectedSpecialty = "Emergency Medicine"
                            }
                            Button("Orthopedics") {
                                viewModel.selectedSpecialty = "Orthopedics"
                            }
                            Button("Neurology") {
                                viewModel.selectedSpecialty = "Neurology"
                            }
                        } label: {
                            HStack {
                                Text(viewModel.selectedSpecialty ?? "All")
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                            }
                            .foregroundColor(.blue)
                        }
                    }
                    
                    // Healthcare Plan Filter
                    HStack {
                        Text("Healthcare Plan")
                            .foregroundColor(.secondary)
                        Spacer()
                        Menu {
                            Button("All") {
                                viewModel.selectedHealthcarePlan = nil
                            }
                            Button("Medicare") {
                                viewModel.selectedHealthcarePlan = "Medicare"
                            }
                            Button("Medicaid") {
                                viewModel.selectedHealthcarePlan = "Medicaid"
                            }
                            Button("Private") {
                                viewModel.selectedHealthcarePlan = "Private"
                            }
                        } label: {
                            HStack {
                                Text(viewModel.selectedHealthcarePlan ?? "All")
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                            }
                            .foregroundColor(.blue)
                        }
                    }
                } header: {
                    Text("Filters")
                }
                
                // Schedules Section
                Section {
                    if viewModel.isLoading && viewModel.schedules.isEmpty {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    } else if viewModel.schedules.isEmpty {
                        Text("No schedules found")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        ForEach(viewModel.schedules) { schedule in
                            ScheduleRow(schedule: schedule)
                        }
                    }
                } header: {
                    Text("On-Call Schedule")
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
            .navigationTitle("Schedules")
            .searchable(text: $viewModel.searchText, prompt: "Search provider")
            .refreshable {
                await viewModel.refresh()
            }
            .task {
                await viewModel.loadSchedules()
            }
        }
    }
}

struct ScheduleRow: View {
    let schedule: Schedule
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(schedule.provider)
                    .font(.headline)
                Spacer()
                Text(dateFormatter.string(from: schedule.date))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Label(schedule.specialty, systemImage: "stethoscope")
                    .font(.subheadline)
                    .foregroundColor(.blue)
                Spacer()
                Label(schedule.healthcarePlan, systemImage: "heart.text.square")
                    .font(.caption)
                    .foregroundColor(.green)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ScheduleListView()
}
