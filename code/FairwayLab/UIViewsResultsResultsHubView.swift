//
//  ResultsHubView.swift
//  GolfX
//
//  Main results hub showing all game results
//

import SwiftUI

struct ResultsHubView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    
    let definition: RoundDefinition
    let state: RoundState
    
    @StateObject private var viewModel: ResultsViewModel
    
    init(definition: RoundDefinition, state: RoundState) {
        self.definition = definition
        self.state = state
        _viewModel = StateObject(wrappedValue: ResultsViewModel(definition: definition, state: state))
    }
    
    var body: some View {
        NavigationStack {
            List {
                // Stableford
                if definition.selectedGames.contains(.stableford),
                   let result = viewModel.stablefordResult {
                    Section("Stableford") {
                        ForEach(result.sortedPlayers(players: definition.players), id: \.0.id) { player, points in
                            HStack {
                                Text(player.name)
                                Spacer()
                                Text("\(points) pts")
                                    .fontWeight(.bold)
                            }
                        }
                    }
                }
                
                // Skins
                if definition.selectedGames.contains(.skins),
                   let result = viewModel.skinsResult {
                    Section("Skins") {
                        ForEach(result.sortedPlayers(players: definition.players), id: \.0.id) { player, skins in
                            HStack {
                                Text(player.name)
                                Spacer()
                                Text("\(skins) skins")
                                    .fontWeight(.bold)
                            }
                        }
                    }
                }
                
                // Nassau
                if definition.selectedGames.contains(.nassau),
                   let result = viewModel.nassauResult {
                    NavigationLink {
                        NassauDetailView(result: result, definition: definition)
                    } label: {
                        VStack(alignment: .leading) {
                            Text("Nassau")
                                .font(.headline)
                            ForEach(result.sortedPlayers(players: definition.players).prefix(3), id: \.0.id) { player, points in
                                Text("\(player.name): \(points) pts")
                                    .font(.subheadline)
                            }
                        }
                    }
                }
                
                // KP
                if definition.selectedGames.contains(.kp),
                   let result = viewModel.kpResult {
                    NavigationLink {
                        KPDetailView(result: result, definition: definition)
                    } label: {
                        VStack(alignment: .leading) {
                            Text("KP (Closest to Pin)")
                                .font(.headline)
                            ForEach(result.sortedPlayers(players: definition.players).prefix(3), id: \.0.id) { player, wins in
                                Text("\(player.name): \(wins) wins")
                                    .font(.subheadline)
                            }
                        }
                    }
                }
                
                // Cara 'e Perro
                if definition.selectedGames.contains(.caraEPerro),
                   let result = viewModel.caraEPerroResult {
                    NavigationLink {
                        CaraEPerroDetailView(result: result, definition: definition)
                    } label: {
                        VStack(alignment: .leading) {
                            Text("Cara 'e Perro")
                                .font(.headline)
                            ForEach(result.sortedPlayers(players: definition.players).prefix(3), id: \.0.id) { player, holes in
                                Text("\(player.name): \(holes) holes")
                                    .font(.subheadline)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Results")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Back to Round") {
                        appState.backToPlay()
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("End Round") {
                        appState.endRound()
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    let definition = RoundDefinition(
        players: MockCourseData.samplePlayers,
        course: MockCourseData.sampleCourse1,
        tee: MockCourseData.sampleTee1,
        holes: HoleBuilder.buildHoles(from: MockCourseData.sampleTee1, isNineHole: false, isBackNine: false),
        selectedGames: [.stableford, .skins, .kp],
        handicapMode: .relativeToLowest,
        isNineHole: false,
        isBackNine: false
    )
    let state = RoundState(players: definition.players, holes: definition.holes)
    
    return ResultsHubView(definition: definition, state: state)
        .environmentObject(AppState())
}
