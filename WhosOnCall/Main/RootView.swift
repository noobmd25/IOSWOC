import SwiftUI

struct RootView: View {
    @EnvironmentObject var sessionController: SessionController
    
    var body: some View {
        Group {
            if sessionController.isAuthenticated {
                MainTabView()
            } else {
                LoginView()
            }
        }
        .animation(.default, value: sessionController.isAuthenticated)
    }
}

#Preview {
    RootView()
        .environmentObject(SessionController.shared)
}
