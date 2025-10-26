//
//  ContentView.swift
//  WhosOnCall
//
//  Universal container that injects environment objects
//

import SwiftUI

struct ContentView: View {
    @StateObject private var sessionController = SessionController.shared
    
    var body: some View {
        RootView()
            .environmentObject(sessionController)
    }
}

#Preview {
    ContentView()
}
