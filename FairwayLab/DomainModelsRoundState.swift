//
//  RoundState.swift
//  GolfX
//
//  Mutable live state during round play
//

import Foundation

struct RoundState: Codable {
    private var grossScores: [UUID: [UUID: Int]]  // playerID -> holeID -> strokes
    private var putts: [UUID: [UUID: Int]]        // playerID -> holeID -> putts
    private var kpWinners: [UUID: UUID?]          // holeID -> playerID?
    
    let players: [Player]
    let holes: [HoleDefinition]
    
    init(players: [Player], holes: [HoleDefinition]) {
        self.players = players
        self.holes = holes
        self.grossScores = [:]
        self.putts = [:]
        self.kpWinners = [:]
    }
    
    // MARK: - Gross Score Access
    
    mutating func setGrossScore(_ score: Int?, for playerID: UUID, holeID: UUID) {
        if grossScores[playerID] == nil {
            grossScores[playerID] = [:]
        }
        grossScores[playerID]?[holeID] = score
    }
    
    func getGrossScore(for playerID: UUID, holeID: UUID) -> Int? {
        grossScores[playerID]?[holeID]
    }
    
    // MARK: - Putts Access
    
    mutating func setPutts(_ puttCount: Int?, for playerID: UUID, holeID: UUID) {
        if putts[playerID] == nil {
            putts[playerID] = [:]
        }
        putts[playerID]?[holeID] = puttCount
    }
    
    func getPutts(for playerID: UUID, holeID: UUID) -> Int? {
        putts[playerID]?[holeID]
    }
    
    // MARK: - KP Access
    
    mutating func setKPWinner(_ playerID: UUID?, for holeID: UUID) {
        kpWinners[holeID] = playerID
    }
    
    func getKPWinner(for holeID: UUID) -> UUID? {
        kpWinners[holeID] ?? nil
    }
    
    // MARK: - Convenience
    
    func allScoresForPlayer(_ playerID: UUID) -> [UUID: Int] {
        grossScores[playerID] ?? [:]
    }
    
    func par3Holes() -> [HoleDefinition] {
        holes.filter { $0.isPar3 }
    }
    
    // MARK: - Snake & Pig Calculations
    
    /// Get total putts for a player across all holes
    func getTotalPutts(for playerID: UUID) -> Int {
        putts[playerID]?.values.reduce(0, +) ?? 0
    }
    
    /// Get the player currently holding the snake (most putts)
    func getCurrentSnakeHolder() -> UUID? {
        var puttTotals: [UUID: Int] = [:]
        
        for player in players {
            puttTotals[player.id] = getTotalPutts(for: player.id)
        }
        
        guard let maxPutts = puttTotals.values.max(), maxPutts > 0 else { return nil }
        
        // Return player with most putts (nil if tie)
        let playersWithMax = puttTotals.filter { $0.value == maxPutts }
        return playersWithMax.count == 1 ? playersWithMax.first?.key : nil
    }
    
    /// Check if player made par on any hole in a specific nine
    func madeParOnNine(playerID: UUID, isBackNine: Bool) -> Bool {
        let nineHoles = isBackNine ? holes.filter { $0.actualHoleNumber >= 10 } : holes.filter { $0.actualHoleNumber <= 9 }
        
        for hole in nineHoles {
            if let score = getGrossScore(for: playerID, holeID: hole.id) {
                if score <= hole.par {
                    return true
                }
            }
        }
        
        return false
    }
}
