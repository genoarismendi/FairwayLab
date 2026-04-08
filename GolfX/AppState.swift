import Foundation
import SwiftUI
import Combine

@MainActor
final class AppState: ObservableObject {
    // Active round state
    @Published var roundDefinition: RoundDefinition?
    @Published var roundState: RoundState?

    // Last valid definition for reuse
    @Published var lastValidRoundDefinition: RoundDefinition?

    // Navigation flags
    @Published var isSetupPresented = false
    @Published var isPlayPresented = false
    @Published var isResultsPresented = false

    init() {
        self.roundDefinition = nil
        self.roundState = nil
        self.lastValidRoundDefinition = nil
    }

    func startNewRound() {
        roundDefinition = nil
        roundState = nil
        isSetupPresented = true
    }

    func continueRound() -> Bool {
        roundDefinition != nil && roundState != nil
    }

    func finalizeSetup(definition: RoundDefinition) {
        self.roundDefinition = definition
        self.lastValidRoundDefinition = definition
        self.roundState = RoundState(players: definition.players, holes: definition.holes)
        self.isSetupPresented = false
        self.isPlayPresented = true
    }

    func resetToLastValid() {
        if let last = lastValidRoundDefinition {
            finalizeSetup(definition: last)
        }
    }
    
    func showResults() {
        isPlayPresented = false
        isResultsPresented = true
    }
    
    func backToPlay() {
        isResultsPresented = false
        isPlayPresented = true
    }
    
    func endRound() {
        isPlayPresented = false
        isResultsPresented = false
    }
}
