//
//  ScheduleListView.swift
//  WhosOnCall
//
//  Displays list of on-call schedules with search and filter
//

import SwiftUI

struct ScheduleListView: View {
    @StateObject private var viewModel = ScheduleViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading && viewModel.schedules.isEmpty {
                    ProgressView("Loading schedules...")
                } else if let errorMessage = viewModel.errorMessage, viewModel.schedules.isEmpty {
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
                    List(viewModel.schedules) { schedule in
                        ScheduleRow(schedule: schedule)
                    }
                    .listStyle(.insetGrouped)
                    .refreshable {
                        await viewModel.refresh()
                    }
                }
            }
            .navigationTitle("Schedules")
            .searchable(text: $viewModel.searchText, prompt: "Search provider")
            .onChange(of: viewModel.searchText) { oldValue, newValue in
                viewModel.onSearchTextChanged(newValue)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Section("Specialty") {
                            Button("All") {
                                viewModel.selectedSpecialty = nil
                                Task { await viewModel.loadSchedules() }
                            }
                            Button("Cardiology") {
                                viewModel.selectedSpecialty = "Cardiology"
                                Task { await viewModel.loadSchedules() }
                            }
                            Button("Emergency Medicine") {
                                viewModel.selectedSpecialty = "Emergency Medicine"
                                Task { await viewModel.loadSchedules() }
                            }
                            Button("Surgery") {
                                viewModel.selectedSpecialty = "Surgery"
                                Task { await viewModel.loadSchedules() }
                            }
                        }
                        
                        Section("Healthcare Plan") {
                            Button("All") {
                                viewModel.selectedHealthcarePlan = nil
                                Task { await viewModel.loadSchedules() }
                            }
                            Button("HMO") {
                                viewModel.selectedHealthcarePlan = "HMO"
                                Task { await viewModel.loadSchedules() }
                            }
                            Button("PPO") {
                                viewModel.selectedHealthcarePlan = "PPO"
                                Task { await viewModel.loadSchedules() }
                            }
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .task {
                await viewModel.loadSchedules()
            }
        }
    }
}

struct ScheduleRow: View {
    let schedule: Schedule
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(schedule.specialty)
                    .font(.headline)
                Spacer()
                Text(schedule.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(schedule.provider)
                .font(.subheadline)
            
            if let healthcarePlan = schedule.healthcarePlan {
                Text(healthcarePlan)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(4)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ScheduleListView()
}
