//
//  MainTabView.swift
//  WhosOnCall
//
//  Main tab navigation containing Schedules, Directory, and Settings
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            ScheduleListView()
                .tabItem {
                    Label("Schedules", systemImage: "calendar")
                }
            
            DirectoryListView()
                .tabItem {
                    Label("Directory", systemImage: "person.3.fill")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(SessionController.shared)
}
