//
//  GolfXApp.swift
//  GolfX
//
//  Created by g on 14-03-26.
//

import SwiftUI

@main
struct GolfXApp: App {
    @StateObject private var appState = AppState()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(appState)
                .onChange(of: scenePhase) { _, newPhase in
                    if newPhase == .background {
                        appState.save()
                    }
                }
        }
    }
}
