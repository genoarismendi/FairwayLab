//
//  CaraEPerroCalculator.swift
//  GolfX
//
//  Cara 'e Perro pairwise comparison game calculator.
//
//  Core algorithm (unchanged): each player competes against every other player
//  on every hole. Points are awarded from head-to-head matchups with handicap
//  adjustments. The sum of pairwise points on any hole is always zero.
//
//  Additional bonuses applied on top of pairwise points:
//    • Zero Putts (+1 per hole where a player records 0 putts)
//    • Front Nine Winner (+1 to player with lowest net score on holes 1-9)
//    • Back Nine Winner  (+1 to player with lowest net score on holes 10-18)
//    • Snake Penalty     (player with most total putts gives 1 point to every other player)

import Foundation

struct CaraEPerroHoleResult: Codable {
    let hole: HoleDefinition
    let playerGrossScores: [UUID: Int]
    let playerHolePoints: [UUID: Int]          // Pairwise points + zero-putts bonus for this hole
    let playerCumulativePoints: [UUID: Int]    // Running total through this hole (excludes end-of-round bonuses)
    let zeroPuttsBonusPlayers: [UUID]          // Players who earned +1 zero-putts bonus on this hole
}

struct CaraEPerroResult: Codable {
    let playerCumulativePoints: [UUID: Int]    // Final total including all bonuses and penalties
    let holeResults: [CaraEPerroHoleResult]
    let playerHandicapIndices: [UUID: Int]     // Rounded handicaps used in pairwise calculation
    // Bonus / penalty breakdown (for display in results view)
    let totalPutts: [UUID: Int]
    let snakePlayerIDs: [UUID]
    let snakePenaltyByPlayer: [UUID: Int]      // Negative = paid out, positive = received
    let frontNineWinnerID: UUID?
    let backNineWinnerID: UUID?
    let zeroPuttsBonusByPlayer: [UUID: Int]    // Total zero-putts bonuses earned across the round
    let frontNineBonusByPlayer: [UUID: Int]    // 0 or 1 per player
    let backNineBonusByPlayer: [UUID: Int]     // 0 or 1 per player

    func totalPoints(for playerID: UUID) -> Int {
        playerCumulativePoints[playerID] ?? 0
    }

    func sortedPlayers(players: [Player]) -> [(Player, Int)] {
        players.map { ($0, totalPoints(for: $0.id)) }.sorted { $0.1 > $1.1 }
    }
}

struct CaraEPerroCalculator {

    static func calculate(input: CalculationInput, tee: Tee) -> CaraEPerroResult {

        // MARK: - Step 1: Round handicaps to nearest integer (used for all pairwise logic)
        let handicapIndices = input.players.reduce(into: [UUID: Int]()) {
            $0[$1.id] = Int(round($1.handicap))
        }

        // MARK: - Step 2: Precompute handicap deltas for every unique pair
        let handicapDeltas = computeHandicapDeltas(players: input.players, handicapIndices: handicapIndices)

        // MARK: - Step 3: Sum total putts per player (used for snake at end)
        var totalPutts: [UUID: Int] = input.players.reduce(into: [:]) { $0[$1.id] = 0 }
        for player in input.players {
            for hole in input.holes {
                totalPutts[player.id, default: 0] += input.puttCount(playerID: player.id, holeID: hole.id) ?? 0
            }
        }

        // MARK: - Step 4: Hole-by-hole pairwise points + zero-putts bonus
        var holeResults: [CaraEPerroHoleResult] = []
        var cumulativePoints: [UUID: Int] = input.players.reduce(into: [:]) { $0[$1.id] = 0 }
        var zeroPuttsBonusByPlayer: [UUID: Int] = input.players.reduce(into: [:]) { $0[$1.id] = 0 }

        for hole in input.holes.sorted(by: { $0.displayOrder < $1.displayOrder }) {
            var holePoints = calculatePairwisePoints(
                hole: hole,
                players: input.players,
                input: input,
                handicapIndices: handicapIndices,
                handicapDeltas: handicapDeltas
            )

            // Zero-putts bonus: +1 for any player who holed out with 0 putts
            var zeroPuttsBonusPlayers: [UUID] = []
            for player in input.players {
                guard let score = input.score(playerID: player.id, holeID: hole.id), score > 0 else { continue }
                guard let p = input.puttCount(playerID: player.id, holeID: hole.id), p == 0 else { continue }
                holePoints[player.id, default: 0] += 1
                zeroPuttsBonusByPlayer[player.id, default: 0] += 1
                zeroPuttsBonusPlayers.append(player.id)
            }

            // Update running cumulative (does NOT yet include end-of-round bonuses)
            for playerID in holePoints.keys {
                cumulativePoints[playerID, default: 0] += holePoints[playerID] ?? 0
            }

            var grossScores: [UUID: Int] = [:]
            for player in input.players {
                if let s = input.score(playerID: player.id, holeID: hole.id), s > 0 {
                    grossScores[player.id] = s
                }
            }

            holeResults.append(CaraEPerroHoleResult(
                hole: hole,
                playerGrossScores: grossScores,
                playerHolePoints: holePoints,
                playerCumulativePoints: cumulativePoints,
                zeroPuttsBonusPlayers: zeroPuttsBonusPlayers
            ))
        }

        // MARK: - Step 5: Front nine / back nine winner bonus
        let frontNineHoles = input.holes.filter { $0.actualHoleNumber <= 9 }
        let backNineHoles  = input.holes.filter { $0.actualHoleNumber > 9 }

        let (frontWinnerID, frontNineBonusByPlayer) = computeNineWinnerBonus(
            input: input, tee: tee, nineHoles: frontNineHoles
        )
        let (backWinnerID, backNineBonusByPlayer) = computeNineWinnerBonus(
            input: input, tee: tee, nineHoles: backNineHoles
        )

        for (playerID, bonus) in frontNineBonusByPlayer {
            cumulativePoints[playerID, default: 0] += bonus
        }
        for (playerID, bonus) in backNineBonusByPlayer {
            cumulativePoints[playerID, default: 0] += bonus
        }

        // MARK: - Step 6: Snake penalty
        // Player(s) with the most total putts give 1 point to every other player.
        let maxPutts = totalPutts.values.max() ?? 0
        let snakePlayerIDs: [UUID]
        var snakePenaltyByPlayer: [UUID: Int] = input.players.reduce(into: [:]) { $0[$1.id] = 0 }

        if maxPutts > 0 {
            snakePlayerIDs = input.players
                .filter { totalPutts[$0.id] == maxPutts }
                .map { $0.id }

            for snakeID in snakePlayerIDs {
                for player in input.players where player.id != snakeID {
                    snakePenaltyByPlayer[snakeID, default: 0] -= 1
                    snakePenaltyByPlayer[player.id, default: 0] += 1
                    cumulativePoints[snakeID, default: 0] -= 1
                    cumulativePoints[player.id, default: 0] += 1
                }
            }
        } else {
            snakePlayerIDs = []
        }

        return CaraEPerroResult(
            playerCumulativePoints: cumulativePoints,
            holeResults: holeResults,
            playerHandicapIndices: handicapIndices,
            totalPutts: totalPutts,
            snakePlayerIDs: snakePlayerIDs,
            snakePenaltyByPlayer: snakePenaltyByPlayer,
            frontNineWinnerID: frontWinnerID,
            backNineWinnerID: backWinnerID,
            zeroPuttsBonusByPlayer: zeroPuttsBonusByPlayer,
            frontNineBonusByPlayer: frontNineBonusByPlayer,
            backNineBonusByPlayer: backNineBonusByPlayer
        )
    }

    // MARK: - Pairwise handicap delta table

    private static func computeHandicapDeltas(
        players: [Player],
        handicapIndices: [UUID: Int]
    ) -> [String: Int] {
        var deltas: [String: Int] = [:]
        for i in 0..<players.count {
            for j in (i+1)..<players.count {
                let p1 = players[i], p2 = players[j]
                let delta = abs((handicapIndices[p1.id] ?? 0) - (handicapIndices[p2.id] ?? 0))
                deltas[pairKey(p1.id, p2.id)] = delta
                deltas[pairKey(p2.id, p1.id)] = delta
            }
        }
        return deltas
    }

    // MARK: - Core pairwise comparison for one hole

    private static func calculatePairwisePoints(
        hole: HoleDefinition,
        players: [Player],
        input: CalculationInput,
        handicapIndices: [UUID: Int],
        handicapDeltas: [String: Int]
    ) -> [UUID: Int] {
        var points: [UUID: Int] = players.reduce(into: [:]) { $0[$1.id] = 0 }
        let strokeIndex = hole.strokeIndex

        for i in 0..<players.count {
            for j in (i+1)..<players.count {
                let p1 = players[i], p2 = players[j]

                guard let s1 = input.score(playerID: p1.id, holeID: hole.id), s1 > 0,
                      let s2 = input.score(playerID: p2.id, holeID: hole.id), s2 > 0 else { continue }

                let hcp1 = handicapIndices[p1.id] ?? 0
                let hcp2 = handicapIndices[p2.id] ?? 0
                let delta = handicapDeltas[pairKey(p1.id, p2.id)] ?? 0

                var adj1 = s1, adj2 = s2

                // The player with the LOWER handicap (better player) receives +1 stroke
                // when delta >= strokeIndex. This levels the matchup.
                if delta >= strokeIndex {
                    if hcp1 < hcp2 { adj1 += 1 }
                    else if hcp2 < hcp1 { adj2 += 1 }
                }

                if adj1 < adj2 {
                    points[p1.id, default: 0] += 1
                    points[p2.id, default: 0] -= 1
                } else if adj1 > adj2 {
                    points[p1.id, default: 0] -= 1
                    points[p2.id, default: 0] += 1
                }
                // Tie: no points
            }
        }
        return points
    }

    // MARK: - Nine-hole net score winner

    /// Returns (winnerID, bonusByPlayer) where winnerID is the player with the
    /// lowest net score on the provided holes. No bonus if tied or holes are empty.
    private static func computeNineWinnerBonus(
        input: CalculationInput,
        tee: Tee,
        nineHoles: [HoleDefinition]
    ) -> (winnerID: UUID?, bonusByPlayer: [UUID: Int]) {
        guard !nineHoles.isEmpty else { return (nil, [:]) }

        let fullPar = input.holes.map { $0.par }.reduce(0, +)
        let playingHandicaps = HandicapCalculator.calculatePlayingHandicaps(
            players: input.players,
            slope: tee.slope,
            courseRating: tee.courseRating,
            par: fullPar,
            mode: input.handicapMode
        )

        var netScores: [UUID: Int] = [:]
        for player in input.players {
            let strokesPerHole = HandicapCalculator.strokesPerHole(
                playingHandicap: playingHandicaps[player.id] ?? 0,
                holes: input.holes
            )
            var total = 0
            var allScored = true
            for hole in nineHoles {
                guard let gross = input.score(playerID: player.id, holeID: hole.id), gross > 0 else {
                    allScored = false; break
                }
                total += gross - (strokesPerHole[hole.id] ?? 0)
            }
            if allScored { netScores[player.id] = total }
        }

        guard let minScore = netScores.values.min() else { return (nil, [:]) }
        let winners = netScores.filter { $0.value == minScore }
        guard winners.count == 1, let winnerID = winners.first?.key else { return (nil, [:]) }

        return (winnerID, [winnerID: 1])
    }

    private static func pairKey(_ a: UUID, _ b: UUID) -> String {
        "\(a.uuidString)-\(b.uuidString)"
    }
}
