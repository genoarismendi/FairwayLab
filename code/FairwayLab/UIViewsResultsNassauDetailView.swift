//
//  NassauDetailView.swift
//  GolfX
//
//  Detailed Nassau results view
//

import SwiftUI

struct NassauDetailView: View {
    let result: NassauResult
    let definition: RoundDefinition
    
    var body: some View {
        List {
            Section("Leaderboard") {
                ForEach(result.sortedPlayers(players: definition.players), id: \.0.id) { player, points in
                    HStack {
                        Text(player.name)
                        Spacer()
                        Text("\(points) points")
                            .fontWeight(.bold)
                    }
                }
            }
            
            Section("Front Nine") {
                ForEach(definition.players) { player in
                    HStack {
                        Text(player.name)
                        Spacer()
                        Text("\(result.frontScores[player.id] ?? 0)")
                        if result.frontWinner == player.id {
                            Image(systemName: "star.fill")
                                .foregroundStyle(.yellow)
                        }
                    }
                }
            }
            
            Section("Back Nine") {
                ForEach(definition.players) { player in
                    HStack {
                        Text(player.name)
                        Spacer()
                        Text("\(result.backScores[player.id] ?? 0)")
                        if result.backWinner == player.id {
                            Image(systemName: "star.fill")
                                .foregroundStyle(.yellow)
                        }
                    }
                }
            }
            
            Section("Total") {
                ForEach(definition.players) { player in
                    HStack {
                        Text(player.name)
                        Spacer()
                        Text("\(result.totalScores[player.id] ?? 0)")
                        if result.totalWinner == player.id {
                            Image(systemName: "star.fill")
                                .foregroundStyle(.yellow)
                        }
                    }
                }
            }
        }
        .navigationTitle("Nassau Results")
    }
}
