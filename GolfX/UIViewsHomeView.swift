//
//  HomeView.swift
//  GolfX
//
//  Home screen for the golf app
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                // App header
                VStack(spacing: 10) {
                    Image(systemName: "figure.golf")
                        .font(.system(size: 80))
                        .foregroundStyle(.green)
                    
                    Text("Golf Scorer")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                .padding(.top, 60)
                
                Spacer()
                
                // Main actions
                VStack(spacing: 20) {
                    if appState.continueRound() {
                        Button(action: {
                            appState.isPlayPresented = true
                        }) {
                            Label("Continue Round", systemImage: "play.circle.fill")
                                .font(.title2)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    }
                    
                    Button(action: {
                        appState.startNewRound()
                    }) {
                        Label("New Round", systemImage: "plus.circle.fill")
                            .font(.title2)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    
                    if appState.lastValidRoundDefinition != nil {
                        Button(action: {
                            appState.resetToLastValid()
                        }) {
                            Label("Repeat Last Setup", systemImage: "arrow.clockwise.circle.fill")
                                .font(.title2)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal, 30)
                
                Spacer()
                
                // Status indicator
                if let definition = appState.roundDefinition {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Active Round")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(definition.course.name)
                            .font(.headline)
                        Text("\(definition.players.count) players • \(definition.holeCount) holes")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal, 30)
                }
            }
            .navigationTitle("Golf Scorer")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $appState.isSetupPresented) {
                SetupWizardView()
                    .environmentObject(appState)
            }
            .sheet(isPresented: $appState.isPlayPresented) {
                if let definition = appState.roundDefinition,
                   let _ = appState.roundState {
                    RoundPlayView(definition: definition)
                        .environmentObject(appState)
                }
            }
            .sheet(isPresented: $appState.isResultsPresented) {
                if let definition = appState.roundDefinition,
                   let state = appState.roundState {
                    ResultsHubView(definition: definition, state: state)
                        .environmentObject(appState)
                }
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AppState())
}
