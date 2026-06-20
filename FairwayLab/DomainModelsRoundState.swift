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
}
