//
//  MainTabView.swift
//  WhosOnCall
//
//  Main tab view container for authenticated users
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
                    Label("Directory", systemImage: "person.2.fill")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(SessionController.shared)
}
