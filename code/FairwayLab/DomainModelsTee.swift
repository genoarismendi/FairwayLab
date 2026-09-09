//
//  Tee.swift
//  GolfX
//
//  Domain model for a tee/scorecard
//

import Foundation

struct Tee: Identifiable, Hashable, Codable {
    let id: UUID
    let name: String
    let courseRating: Double
    let slope: Int
    let pars: [Int]           // par for each hole, indexed 0-17
    let yardages: [Int]       // yardage for each hole, indexed 0-17
    var strokeIndices: [Int]  // stroke index for each hole, indexed 0-17
    
    init(
        id: UUID = UUID(),
        name: String,
        courseRating: Double,
        slope: Int,
        pars: [Int],
        yardages: [Int],
        strokeIndices: [Int]? = nil
    ) {
        self.id = id
        self.name = name
        self.courseRating = courseRating
        self.slope = slope
        self.pars = pars
        self.yardages = yardages
        
        // If stroke indices not provided, create sequential fallback
        if let indices = strokeIndices, indices.count == 18 {
            self.strokeIndices = indices
        } else {
            self.strokeIndices = Array(1...18)
        }
    }
    
    /// Get par for a specific hole range (1-indexed)
    func pars(for holeNumbers: [Int]) -> [Int] {
        holeNumbers.map { pars[$0 - 1] }
    }
    
    /// Get yardages for a specific hole range (1-indexed)
    func yardages(for holeNumbers: [Int]) -> [Int] {
        holeNumbers.map { yardages[$0 - 1] }
    }
    
    /// Get stroke indices for a specific hole range (1-indexed)
    func strokeIndices(for holeNumbers: [Int]) -> [Int] {
        holeNumbers.map { strokeIndices[$0 - 1] }
    }
    
    /// Check if stroke indices are valid (proper permutation of 1...18)
    var hasValidStrokeIndices: Bool {
        let expected = Set(1...18)
        let actual = Set(strokeIndices)
        return expected == actual && strokeIndices.count == 18
    }
}
