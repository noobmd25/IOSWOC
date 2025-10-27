import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            ScheduleListView()
                .tabItem {
                    Label("On-Call", systemImage: "calendar")
                }
            
            DirectoryListView()
                .tabItem {
                    Label("Directory", systemImage: "person.text.rectangle")
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
}
