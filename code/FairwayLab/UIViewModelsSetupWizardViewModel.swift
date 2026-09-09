//
//  SetupWizardViewModel.swift
//  GolfX
//
//  View model for the setup wizard
//

import Foundation
import SwiftUI
import Combine

@MainActor
class SetupWizardViewModel: ObservableObject {
    // Navigation
    @Published var currentStep: SetupStep = .players
    
    // Players
    @Published var players: [Player] = []
    
    // Round details
    @Published var selectedCourse: Course?
    @Published var selectedTee: Tee?
    @Published var isNineHole = false
    @Published var isBackNine = false
    @Published var holes: [HoleDefinition] = []
    
    // Games
    @Published var selectedGames: Set<GameType> = [.stableford, .skins]
    @Published var handicapMode: HandicapMode = .relativeToLowest
    
    init() {
        self.players = [
            Player(name: "Player 1", handicap: 10),
            Player(name: "Player 2", handicap: 15)
        ]
    }
    
    // MARK: - Validation
    
    var playersAreValid: Bool {
        players.count >= 2 && players.allSatisfy { $0.isValid }
    }
    
    var roundDetailsAreValid: Bool {
        selectedCourse != nil && selectedTee != nil && !holes.isEmpty
    }
    
    var strokeIndexIsValid: Bool {
        HoleBuilder.validateStrokeIndices(holes)
    }
    
    var canStart: Bool {
        playersAreValid && roundDetailsAreValid && strokeIndexValid
    }
    
    var strokeIndexValid: Bool {
        let needsValid = selectedGames.contains { $0.requiresValidStrokeIndex }
        return !needsValid || strokeIndexIsValid
    }
    
    var validationErrors: [String] {
        var errors: [String] = []
        
        if !playersAreValid {
            errors.append("Players: Need at least 2 valid players")
        }
        if !roundDetailsAreValid {
            errors.append("Round: Must select course and tee")
        }
        if !strokeIndexValid {
            errors.append("Stroke Index: Invalid for selected games")
        }
        
        return errors
    }
    
    // MARK: - Actions
    
    func addPlayer() {
        let number = players.count + 1
        players.append(Player(name: "Player \(number)", handicap: 18))
    }
    
    func removePlayer(at index: Int) {
        guard players.count > 2 else { return }
        players.remove(at: index)
    }
    
    func updatePlayer(_ player: Player) {
        if let index = players.firstIndex(where: { $0.id == player.id }) {
            players[index] = player
        }
    }
    
    func selectCourse(_ course: Course) {
        selectedCourse = course
        if let firstTee = course.tees.first {
            selectTee(firstTee)
        }
    }
    
    func selectTee(_ tee: Tee) {
        selectedTee = tee
        rebuildHoles()
    }
    
    func updateHoleSelection(nineHole: Bool, backNine: Bool) {
        isNineHole = nineHole
        isBackNine = backNine
        rebuildHoles()
    }
    
    private func rebuildHoles() {
        guard let tee = selectedTee else { return }
        holes = HoleBuilder.buildHoles(from: tee, isNineHole: isNineHole, isBackNine: isBackNine)
    }
    
    func updateStrokeIndex(for holeID: UUID, newIndex: Int) {
        if let index = holes.firstIndex(where: { $0.id == holeID }) {
            holes[index].strokeIndex = newIndex
        }
    }
    
    func normalizeStrokeIndices() {
        holes = HoleBuilder.normalizeStrokeIndices(holes)
    }
    
    func toggleGame(_ game: GameType) {
        if selectedGames.contains(game) {
            selectedGames.remove(game)
        } else {
            selectedGames.insert(game)
        }
    }
    
    // MARK: - Build Result
    
    func buildRoundDefinition() -> RoundDefinition {
        RoundDefinition(
            players: players,
            course: selectedCourse!,
            tee: selectedTee!,
            holes: holes,
            selectedGames: selectedGames,
            handicapMode: handicapMode,
            isNineHole: isNineHole,
            isBackNine: isBackNine
        )
    }
}
