//
//  ContentView.swift
//  GolfX
//
//  Legacy file - now replaced by HomeView
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        HomeView()
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}
