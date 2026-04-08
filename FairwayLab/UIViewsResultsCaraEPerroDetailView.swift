//
//  CaraEPerroDetailView.swift
//  GolfX
//
//  Detailed Cara 'e Perro results view with hole-by-hole breakdown
//

import SwiftUI

struct CaraEPerroDetailView: View {
    let result: CaraEPerroResult
    let definition: RoundDefinition
    
    @State private var showHandicapDetails = false
    
    var body: some View {
        List {
            Section {
                Text("Pairwise comparison game. Each player competes against every other player on each hole. Lower handicap players receive stroke adjustments on harder holes.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Section("Leaderboard") {
                ForEach(result.sortedPlayers(players: definition.players), id: \.0.id) { player, points in
                    HStack {
                        Text(player.name)
                        Spacer()
                        Text(formatPoints(points))
                            .fontWeight(.bold)
                            .foregroundStyle(pointsColor(points))
                    }
                }
            }
            
            Section {
                Button(action: {
                    showHandicapDetails.toggle()
                }) {
                    HStack {
                        Text("Handicap Details")
                        Spacer()
                        Image(systemName: showHandicapDetails ? "chevron.up" : "chevron.down")
                    }
                }
                
                if showHandicapDetails {
                    ForEach(definition.players) { player in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(player.name)
                                .font(.headline)
                            Text("Handicap Index: \(result.playerHandicapIndices[player.id] ?? 0)")
                                .font(.caption)
                        }
                    }
                }
            }
            
            Section("Hole-by-Hole Results") {
                ForEach(result.holeResults, id: \.hole.id) { holeResult in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Hole \(holeResult.hole.actualHoleNumber)")
                                .font(.headline)
                            Spacer()
                            Text("Par \(holeResult.hole.par)")
                                .foregroundStyle(.secondary)
                            Text("SI: \(holeResult.hole.strokeIndex)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        ForEach(definition.players) { player in
                            HStack {
                                Text(player.name)
                                    .frame(width: 100, alignment: .leading)
                                
                                if let gross = holeResult.playerGrossScores[player.id] {
                                    Text("\(gross)")
                                        .frame(width: 30)
                                        .foregroundStyle(.secondary)
                                    
                                    Spacer()
                                    
                                    let holePoints = holeResult.playerHolePoints[player.id] ?? 0
                                    Text(formatPoints(holePoints))
                                        .fontWeight(.semibold)
                                        .foregroundStyle(pointsColor(holePoints))
                                        .frame(width: 40)
                                    
                                    let cumulative = holeResult.playerCumulativePoints[player.id] ?? 0
                                    Text("(\(formatPoints(cumulative)))")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .frame(width: 50)
                                } else {
                                    Text("-")
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .font(.subheadline)
                        }
                        
                        // Verify invariant (sum = 0)
                        let sum = holeResult.playerHolePoints.values.reduce(0, +)
                        if sum != 0 {
                            Text("⚠️ Sum error: \(sum)")
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Cara 'e Perro Results")
    }
    
    /// Format points as "+N", "-N", or "="
    private func formatPoints(_ points: Int) -> String {
        if points > 0 {
            return "+\(points)"
        } else if points < 0 {
            return "\(points)"  // Already has minus sign
        } else {
            return "="
        }
    }
    
    /// Color for points display
    private func pointsColor(_ points: Int) -> Color {
        if points > 0 {
            return .green
        } else if points < 0 {
            return .red
        } else {
            return .primary
        }
    }
}
