//
//  HandicapCalculator.swift
//  GolfX
//
//  Service for calculating course handicaps and stroke allocation
//

import Foundation

struct HandicapCalculator {
    
    /// Calculate course handicap for a player
    /// Formula: handicapIndex * slope / 113 + (courseRating - par)
    static func calculateCourseHandicap(
        handicapIndex: Double,
        slope: Int,
        courseRating: Double,
        par: Int
    ) -> Int {
        let raw = handicapIndex * Double(slope) / 113.0 + (courseRating - Double(par))
        return Int(raw.rounded())
    }
    
    /// Calculate playing handicaps for all players based on mode
    static func calculatePlayingHandicaps(
        players: [Player],
        slope: Int,
        courseRating: Double,
        par: Int,
        mode: HandicapMode
    ) -> [UUID: Int] {
        var result: [UUID: Int] = [:]
        
        // First calculate course handicaps for all
        let courseHandicaps = players.reduce(into: [UUID: Int]()) { dict, player in
            dict[player.id] = calculateCourseHandicap(
                handicapIndex: player.handicap,
                slope: slope,
                courseRating: courseRating,
                par: par
            )
        }
        
        switch mode {
        case .absolute:
            // Each player gets their full course handicap
            return courseHandicaps
            
        case .relativeToLowest:
            // Find lowest course handicap
            guard let lowestHandicap = courseHandicaps.values.min() else {
                return result
            }
            
            // Each player gets difference from lowest
            for player in players {
                let courseHandicap = courseHandicaps[player.id] ?? 0
                result[player.id] = courseHandicap - lowestHandicap
            }
            return result
        }
    }
    
    /// Calculate strokes received on a specific hole
    static func strokesOnHole(
        playingHandicap: Int,
        strokeIndex: Int,
        totalHoles: Int
    ) -> Int {
        guard totalHoles > 0 else { return 0 }
        
        // How many full rounds through all holes?
        let fullRounds = playingHandicap / totalHoles
        
        // How many remaining strokes?
        let remainder = playingHandicap % totalHoles
        
        // Player gets strokes if this hole's index is within remainder
        let getsExtraStroke = strokeIndex <= remainder ? 1 : 0
        
        return fullRounds + getsExtraStroke
    }
    
    /// Calculate strokes for all holes for a player
    static func strokesPerHole(
        playingHandicap: Int,
        holes: [HoleDefinition]
    ) -> [UUID: Int] {
        var result: [UUID: Int] = [:]
        
        for hole in holes {
            let strokes = strokesOnHole(
                playingHandicap: playingHandicap,
                strokeIndex: hole.strokeIndex,
                totalHoles: holes.count
            )
            result[hole.id] = strokes
        }
        
        return result
    }
}
