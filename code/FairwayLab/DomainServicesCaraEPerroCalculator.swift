//
//  CaraEPerroCalculator.swift
//  FairwayLab
//
//  Cara 'e Perro pairwise comparison game calculator with ZERO-SUM bonuses/penalties.
//
//  Core algorithm: each player competes against every other player on every hole.
//  Points are awarded from head-to-head matchups with handicap adjustments.
//  The sum of pairwise points on any hole is always zero.
//
//  Additional bonuses/penalties (ALL ZERO-SUM, INTEGER ONLY):
//    • Zero Putts: Each 0-putt player gets 1 from each non-zero-putt player per hole
//    • Front Nine Winner: Winner gets +(N-1), losers pay -1 each
//    • Back Nine Winner: Winner gets +(N-1), losers pay -1 each  
//    • Snake Penalty (PER-NINE): Most putts on THAT nine pays 1 to each other player
//
//  All point calculations maintain strict zero-sum: sum of all points = 0.

import Foundation

struct CaraEPerroHoleResult: Codable {
    let hole: HoleDefinition
    let playerGrossScores: [UUID: Int]
    let playerHolePoints: [UUID: Int]          // Pairwise points + zero-putts bonus for this hole
    let playerCumulativePoints: [UUID: Int]    // Running total through this hole (excludes end-of-nine bonuses)
    let zeroPuttsBonusPlayers: [UUID]          // Players who earned zero-putts bonus on this hole
}

struct CaraEPerroResult: Codable {
    let playerCumulativePoints: [UUID: Int]    // Final total including all bonuses and penalties
    let holeResults: [CaraEPerroHoleResult]
    let playerHandicapIndices: [UUID: Int]     // Rounded handicaps used in pairwise calculation
    // Bonus / penalty breakdown (for display in results view)
    let totalPutts: [UUID: Int]                // Total putts across entire round (for display)
    let frontNinePutts: [UUID: Int]            // Putts on holes 1-9
    let backNinePutts: [UUID: Int]             // Putts on holes 10-18
    let frontNineSnakePlayerIDs: [UUID]        // Snake holders for front nine
    let backNineSnakePlayerIDs: [UUID]         // Snake holders for back nine
    let frontNineSnakePenaltyByPlayer: [UUID: Int]  // Front nine snake penalties
    let backNineSnakePenaltyByPlayer: [UUID: Int]   // Back nine snake penalties
    let frontNineWinnerID: UUID?
    let backNineWinnerID: UUID?
    let zeroPuttsBonusByPlayer: [UUID: Int]    // Total zero-putts bonuses earned across the round
    let frontNineBonusByPlayer: [UUID: Int]    // 0 or +(N-1) per player
    let backNineBonusByPlayer: [UUID: Int]     // 0 or +(N-1) per player

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

        // MARK: - Step 3: Sum putts per nine (used for snake penalties)
        var totalPutts: [UUID: Int] = input.players.reduce(into: [:]) { $0[$1.id] = 0 }
        var frontNinePutts: [UUID: Int] = input.players.reduce(into: [:]) { $0[$1.id] = 0 }
        var backNinePutts: [UUID: Int] = input.players.reduce(into: [:]) { $0[$1.id] = 0 }
        
        for player in input.players {
            for hole in input.holes {
                let putts = input.puttCount(playerID: player.id, holeID: hole.id) ?? 0
                totalPutts[player.id, default: 0] += putts
                
                if hole.actualHoleNumber <= 9 {
                    frontNinePutts[player.id, default: 0] += putts
                } else {
                    backNinePutts[player.id, default: 0] += putts
                }
            }
        }

        // MARK: - Step 4: Hole-by-hole pairwise points + zero-putts bonus (ZERO-SUM)
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

            // Zero-putts bonus: ZERO-SUM - each zero-putts player gets 1 from each non-zero-putts player
            var zeroPuttsBonusPlayers: [UUID] = []
            let playersWithZeroPutts = input.players.filter {
                guard let score = input.score(playerID: $0.id, holeID: hole.id), score > 0 else { return false }
                guard let p = input.puttCount(playerID: $0.id, holeID: hole.id) else { return false }
                return p == 0
            }
            
            let playersWithoutZeroPutts = input.players.filter { player in
                !playersWithZeroPutts.contains(where: { $0.id == player.id })
            }
            
            let numZeroPutts = playersWithZeroPutts.count
            let numNonZeroPutts = playersWithoutZeroPutts.count
            
            if numZeroPutts > 0 && numNonZeroPutts > 0 {
                // Each zero-putts player receives numNonZeroPutts points
                for player in playersWithZeroPutts {
                    holePoints[player.id, default: 0] += numNonZeroPutts
                    zeroPuttsBonusByPlayer[player.id, default: 0] += numNonZeroPutts
                    zeroPuttsBonusPlayers.append(player.id)
                }
                
                // Each non-zero-putts player pays numZeroPutts points
                for player in playersWithoutZeroPutts {
                    holePoints[player.id, default: 0] -= numZeroPutts
                }
            }

            // Update running cumulative (does NOT yet include end-of-nine bonuses)
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

        // MARK: - Step 5: Front nine / back nine winner bonus (ZERO-SUM)
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

        // MARK: - Step 6: Snake penalty (ZERO-SUM, PER-NINE)
        // Front nine snake (based only on holes 1-9 putts)
        let (frontNineSnakeIDs, frontNineSnakePenalty) = computeSnakePenalty(
            putts: frontNinePutts,
            players: input.players
        )
        
        // Back nine snake (based only on holes 10-18 putts)
        let (backNineSnakeIDs, backNineSnakePenalty) = computeSnakePenalty(
            putts: backNinePutts,
            players: input.players
        )
        
        // Apply front nine snake penalty
        for (playerID, penalty) in frontNineSnakePenalty {
            cumulativePoints[playerID, default: 0] += penalty
        }
        
        // Apply back nine snake penalty
        for (playerID, penalty) in backNineSnakePenalty {
            cumulativePoints[playerID, default: 0] += penalty
        }

        return CaraEPerroResult(
            playerCumulativePoints: cumulativePoints,
            holeResults: holeResults,
            playerHandicapIndices: handicapIndices,
            totalPutts: totalPutts,
            frontNinePutts: frontNinePutts,
            backNinePutts: backNinePutts,
            frontNineSnakePlayerIDs: frontNineSnakeIDs,
            backNineSnakePlayerIDs: backNineSnakeIDs,
            frontNineSnakePenaltyByPlayer: frontNineSnakePenalty,
            backNineSnakePenaltyByPlayer: backNineSnakePenalty,
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

    // MARK: - Nine-hole net score winner (ZERO-SUM)

    /// Returns (winnerID, bonusByPlayer) where winner receives +(N-1) and each loser pays -1.
    /// No bonus if tied or holes are empty.
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

        // ZERO-SUM: Winner gets +(N-1), each non-winner pays -1
        let numPlayers = input.players.count
        var bonusByPlayer: [UUID: Int] = [:]
        
        bonusByPlayer[winnerID] = numPlayers - 1  // Winner gets from all others
        
        for player in input.players where player.id != winnerID {
            bonusByPlayer[player.id] = -1  // Each loser pays 1
        }

        return (winnerID, bonusByPlayer)
    }
    
    // MARK: - Snake penalty (ZERO-SUM, PER-NINE)
    
    /// Computes snake penalty for a single nine based on putts from that nine only.
    /// Returns (snakePlayerIDs, penaltyByPlayer) where snakes pay -(N-numSnakes) and others receive +numSnakes.
    private static func computeSnakePenalty(
        putts: [UUID: Int],
        players: [Player]
    ) -> (snakePlayerIDs: [UUID], penaltyByPlayer: [UUID: Int]) {
        let maxPutts = putts.values.max() ?? 0
        
        guard maxPutts > 0 else {
            return ([], [:])  // No putts recorded, no penalty
        }
        
        let snakePlayers = players.filter { putts[$0.id] == maxPutts }
        let nonSnakePlayers = players.filter { putts[$0.id] != maxPutts }
        
        let numSnakes = snakePlayers.count
        let numNonSnakes = nonSnakePlayers.count
        
        guard numNonSnakes > 0 else {
            return ([], [:])  // All tied for most putts, no penalty
        }
        
        var penaltyByPlayer: [UUID: Int] = [:]
        
        // Each snake pays numNonSnakes (one to each non-snake)
        for snake in snakePlayers {
            penaltyByPlayer[snake.id] = -numNonSnakes
        }
        
        // Each non-snake receives numSnakes (one from each snake)
        for nonSnake in nonSnakePlayers {
            penaltyByPlayer[nonSnake.id] = numSnakes
        }
        
        return (snakePlayers.map { $0.id }, penaltyByPlayer)
    }

    private static func pairKey(_ a: UUID, _ b: UUID) -> String {
        "\(a.uuidString)-\(b.uuidString)"
    }
}