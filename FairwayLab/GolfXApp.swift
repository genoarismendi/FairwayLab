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
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            switch newPhase {
            case .background, .inactive:
                // Save when app goes to background or becomes inactive
                appState.forceSave()
            case .active:
                // App became active - data already loaded on init
                break
            @unknown default:
                break
            }
        }
    }
}
