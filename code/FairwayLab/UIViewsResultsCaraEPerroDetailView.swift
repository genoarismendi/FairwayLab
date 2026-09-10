//
//  CaraEPerroDetailView.swift
//  FairwayLab
//
//  Detailed Cara 'e Perro results view with hole-by-hole breakdown
//  and bonus/penalty summary.
//

import SwiftUI

struct CaraEPerroDetailView: View {
    let result: CaraEPerroResult
    let definition: RoundDefinition

    @State private var showHandicapDetails = false
    
    // Computed property: all snake players (front nine + back nine)
    private var allSnakePlayers: Set<UUID> {
        Set(result.frontNineSnakePlayerIDs + result.backNineSnakePlayerIDs)
    }

    var body: some View {
        List {
            Section {
                Text("Pairwise comparison game. Each player competes against every other player on each hole. Additional points for zero putts, nine-hole winners, and snake penalties.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // MARK: - Leaderboard
            Section("Leaderboard") {
                ForEach(result.sortedPlayers(players: definition.players), id: \.0.id) { player, points in
                    HStack {
                        Text(player.name)
                        if allSnakePlayers.contains(player.id) {
                            Text("🐍")
                        }
                        Spacer()
                        Text(formatPoints(points))
                            .fontWeight(.bold)
                            .foregroundStyle(pointsColor(points))
                    }
                }
            }

            // MARK: - Bonuses & Penalties
            Section("Bonuses & Penalties") {
                // Zero putts bonuses
                let zeroBonusPlayers = definition.players.filter {
                    (result.zeroPuttsBonusByPlayer[$0.id] ?? 0) > 0
                }
                if !zeroBonusPlayers.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Zero Putts Bonus")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        ForEach(zeroBonusPlayers) { player in
                            let count = result.zeroPuttsBonusByPlayer[player.id] ?? 0
                            HStack {
                                Text(player.name)
                                Spacer()
                                Text("+\(count) pt\(count == 1 ? "" : "s")")
                                    .foregroundStyle(.green)
                            }
                            .font(.subheadline)
                        }
                    }
                }

                // Front nine winner
                if let winnerID = result.frontNineWinnerID,
                   let winner = definition.players.first(where: { $0.id == winnerID }) {
                    let bonus = result.frontNineBonusByPlayer[winnerID] ?? 0
                    HStack {
                        Text("Front Nine Winner")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Spacer()
                        Text("\(winner.name) +\(bonus)")
                            .foregroundStyle(.green)
                            .font(.subheadline)
                    }
                }

                // Back nine winner
                if let winnerID = result.backNineWinnerID,
                   let winner = definition.players.first(where: { $0.id == winnerID }) {
                    let bonus = result.backNineBonusByPlayer[winnerID] ?? 0
                    HStack {
                        Text("Back Nine Winner")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Spacer()
                        Text("\(winner.name) +\(bonus)")
                            .foregroundStyle(.green)
                            .font(.subheadline)
                    }
                }

                // Front Nine Snake
                if !result.frontNineSnakePlayerIDs.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Front Nine Snake 🐍")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        ForEach(definition.players) { player in
                            let penalty = result.frontNineSnakePenaltyByPlayer[player.id] ?? 0
                            let putts = result.frontNinePutts[player.id] ?? 0
                            let isSnake = result.frontNineSnakePlayerIDs.contains(player.id)
                            if penalty != 0 {
                                HStack {
                                    Text(player.name)
                                    if isSnake { Text("🐍") }
                                    Text("(\(putts) putts)")
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                    Text(formatPoints(penalty))
                                        .foregroundStyle(pointsColor(penalty))
                                }
                                .font(.subheadline)
                            }
                        }
                    }
                }
                
                // Back Nine Snake
                if !result.backNineSnakePlayerIDs.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Back Nine Snake 🐍")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        ForEach(definition.players) { player in
                            let penalty = result.backNineSnakePenaltyByPlayer[player.id] ?? 0
                            let putts = result.backNinePutts[player.id] ?? 0
                            let isSnake = result.backNineSnakePlayerIDs.contains(player.id)
                            if penalty != 0 {
                                HStack {
                                    Text(player.name)
                                    if isSnake { Text("🐍") }
                                    Text("(\(putts) putts)")
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                    Text(formatPoints(penalty))
                                        .foregroundStyle(pointsColor(penalty))
                                }
                                .font(.subheadline)
                            }
                        }
                    }
                }

                if result.frontNineSnakePlayerIDs.isEmpty
                    && result.backNineSnakePlayerIDs.isEmpty
                    && result.frontNineWinnerID == nil
                    && result.backNineWinnerID == nil
                    && zeroBonusPlayers.isEmpty {
                    Text("No bonuses or penalties recorded.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            // MARK: - Handicap details
            Section {
                Button {
                    showHandicapDetails.toggle()
                } label: {
                    HStack {
                        Text("Handicap Details")
                        Spacer()
                        Image(systemName: showHandicapDetails ? "chevron.up" : "chevron.down")
                    }
                }

                if showHandicapDetails {
                    ForEach(definition.players) { player in
                        HStack {
                            Text(player.name)
                                .font(.subheadline)
                            Spacer()
                            Text("HCP \(result.playerHandicapIndices[player.id] ?? 0)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            // MARK: - Hole-by-hole
            Section("Hole-by-Hole Results") {
                ForEach(result.holeResults, id: \.hole.id) { holeResult in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Hole \(holeResult.hole.actualHoleNumber)")
                                .font(.headline)
                            Spacer()
                            Text("Par \(holeResult.hole.par)")
                                .foregroundStyle(.secondary)
                            Text("SI \(holeResult.hole.strokeIndex)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        ForEach(definition.players) { player in
                            HStack {
                                Text(player.name)
                                    .frame(width: 90, alignment: .leading)

                                if holeResult.zeroPuttsBonusPlayers.contains(player.id) {
                                    Text("0 putts")
                                        .font(.caption2)
                                        .foregroundStyle(.green)
                                        .padding(.horizontal, 4)
                                        .background(Color.green.opacity(0.15))
                                        .cornerRadius(4)
                                }

                                if let gross = holeResult.playerGrossScores[player.id] {
                                    Text("\(gross)")
                                        .frame(width: 24)
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                    let pts = holeResult.playerHolePoints[player.id] ?? 0
                                    Text(formatPoints(pts))
                                        .fontWeight(.semibold)
                                        .foregroundStyle(pointsColor(pts))
                                        .frame(width: 36)
                                    let cum = holeResult.playerCumulativePoints[player.id] ?? 0
                                    Text("(\(formatPoints(cum)))")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .frame(width: 48)
                                } else {
                                    Spacer()
                                    Text("—")
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .font(.subheadline)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Cara 'e Perro Results")
    }

    private func formatPoints(_ points: Int) -> String {
        if points > 0 { return "+\(points)" }
        if points < 0 { return "\(points)" }
        return "="
    }

    private func pointsColor(_ points: Int) -> Color {
        if points > 0 { return .green }
        if points < 0 { return .red }
        return .primary
    }
}