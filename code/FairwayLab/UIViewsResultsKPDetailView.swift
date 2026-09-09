//
//  KPDetailView.swift
//  GolfX
//
//  Detailed KP results view
//

import SwiftUI

struct KPDetailView: View {
    let result: KPResult
    let definition: RoundDefinition
    
    var body: some View {
        List {
            Section("Leaderboard") {
                ForEach(result.sortedPlayers(players: definition.players), id: \.0.id) { player, wins in
                    HStack {
                        Text(player.name)
                        Spacer()
                        Text("\(wins) KP wins")
                            .fontWeight(.bold)
                    }
                }
            }
            
            if result.eligibleHoles.isEmpty {
                Section {
                    Text("No par-3 holes in this round")
                        .foregroundStyle(.secondary)
                }
            } else {
                Section("Par-3 Holes") {
                    ForEach(result.eligibleHoles) { hole in
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Hole \(hole.actualHoleNumber)")
                                    .font(.headline)
                                Spacer()
                                Text("Par \(hole.par)")
                                    .foregroundStyle(.secondary)
                            }
                            
                            if let winnerID = result.holeWinners[hole.id],
                               let winner = definition.players.first(where: { $0.id == winnerID }) {
                                Text("Winner: \(winner.name)")
                                    .font(.subheadline)
                                    .foregroundStyle(.green)
                            } else {
                                Text("No winner")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("KP Results")
    }
}
