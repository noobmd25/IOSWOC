//
//  RootView.swift
//  WhosOnCall
//
//  Root view that switches between LoginView and MainTabView based on authentication state
//

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
    }
}

#Preview {
    RootView()
        .environmentObject(SessionController.shared)
}
