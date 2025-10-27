import SwiftUI

struct ContentView: View {
    @EnvironmentObject var sessionController: SessionController
    
    var body: some View {
        RootView()
            .task {
                await sessionController.checkSession()
            }
    }
}

#Preview {
    ContentView()
        .environmentObject(SessionController.shared)
}
