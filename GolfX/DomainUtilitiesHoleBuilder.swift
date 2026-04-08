//
//  HoleBuilder.swift
//  GolfX
//
//  Helper to build HoleDefinition instances from a Tee
//

import Foundation

struct HoleBuilder {
    
    /// Build holes for a round based on tee and selection
    static func buildHoles(
        from tee: Tee,
        isNineHole: Bool,
        isBackNine: Bool
    ) -> [HoleDefinition] {
        // Safety check: ensure we have valid 18-hole data
        guard tee.pars.count >= 18,
              tee.yardages.count >= 18,
              tee.strokeIndices.count >= 18 else {
            print("⚠️ HoleBuilder: Invalid tee data - pars: \(tee.pars.count), yardages: \(tee.yardages.count), strokeIndices: \(tee.strokeIndices.count)")
            return []
        }
        
        let holeNumbers: [Int]
        
        if isNineHole {
            holeNumbers = isBackNine ? Array(10...18) : Array(1...9)
        } else {
            holeNumbers = Array(1...18)
        }
        
        var holes = holeNumbers.enumerated().map { index, holeNumber in
            let arrayIndex = holeNumber - 1  // Convert to 0-based
            
            return HoleDefinition(
                actualHoleNumber: holeNumber,
                displayOrder: index + 1,
                par: tee.pars[arrayIndex],
                strokeIndex: tee.strokeIndices[arrayIndex],
                yardage: tee.yardages[arrayIndex]
            )
        }
        
        // For 9-hole rounds, renormalize stroke indices to 1-9
        if isNineHole {
            holes = renormalizeStrokeIndicesForNineHoles(holes)
        }
        
        return holes
    }
    
    /// Renormalize stroke indices for 9-hole rounds to be 1-9 based on relative difficulty
    private static func renormalizeStrokeIndicesForNineHoles(_ holes: [HoleDefinition]) -> [HoleDefinition] {
        // Sort holes by their original stroke index (lower = harder)
        let sortedByDifficulty = holes.enumerated().sorted { $0.element.strokeIndex < $1.element.strokeIndex }
        
        // Assign new indices 1-9 based on difficulty ranking
        var updatedHoles = holes
        for (newIndex, (originalIndex, _)) in sortedByDifficulty.enumerated() {
            updatedHoles[originalIndex].strokeIndex = newIndex + 1
        }
        
        return updatedHoles
    }
    
    /// Validate stroke indices for a set of holes
    static func validateStrokeIndices(_ holes: [HoleDefinition]) -> Bool {
        guard !holes.isEmpty else { return true }  // Empty is considered valid
        guard holes.count > 0 else { return true } // Extra safety check
        
        let indices = holes.map { $0.strokeIndex }
        
        // For validation, we need 1...count range
        // If count is 0, this would crash, but we guarded above
        let expectedSet = Set(1...holes.count)
        let actualSet = Set(indices)
        
        return expectedSet == actualSet && indices.count == holes.count
    }
    
    /// Auto-fix stroke indices if they're invalid (sets to sequential)
    static func normalizeStrokeIndices(_ holes: [HoleDefinition]) -> [HoleDefinition] {
        return holes.enumerated().map { index, hole in
            var mutableHole = hole
            mutableHole.strokeIndex = index + 1
            return mutableHole
        }
    }
}
