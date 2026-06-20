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
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(appState)
        }
    }
}
