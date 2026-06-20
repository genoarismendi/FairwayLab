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
        self.roundDefinition = Self.load(RoundDefinition.self, key: .roundDefinition)
        self.roundState = Self.load(RoundState.self, key: .roundState)
        self.lastValidRoundDefinition = Self.load(RoundDefinition.self, key: .lastValidRoundDefinition)
    }

    // MARK: - Round lifecycle

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
        save()
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
        roundDefinition = nil
        roundState = nil
        save()
    }

    // MARK: - Persistence

    func save() {
        Self.persist(roundDefinition, key: .roundDefinition)
        Self.persist(roundState, key: .roundState)
        Self.persist(lastValidRoundDefinition, key: .lastValidRoundDefinition)
    }

    private enum PersistenceKey: String {
        case roundDefinition        = "fairwaylab.roundDefinition"
        case roundState             = "fairwaylab.roundState"
        case lastValidRoundDefinition = "fairwaylab.lastValidRoundDefinition"
    }

    private static func persist<T: Encodable>(_ value: T?, key: PersistenceKey) {
        if let value, let data = try? JSONEncoder().encode(value) {
            UserDefaults.standard.set(data, forKey: key.rawValue)
        } else {
            UserDefaults.standard.removeObject(forKey: key.rawValue)
        }
    }

    private static func load<T: Decodable>(_ type: T.Type, key: PersistenceKey) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key.rawValue) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
}
