import SwiftUI

@main
struct WhosOnCallApp: App {
    @StateObject private var sessionController = SessionController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(sessionController)
        }
    }
}
