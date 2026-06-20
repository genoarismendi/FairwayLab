//
//  RoundPlayView.swift
//  GolfX
//
//  Main score entry view during round play
//

import SwiftUI

struct RoundPlayView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss

    let definition: RoundDefinition
    @State private var localState: RoundState

    init(definition: RoundDefinition) {
        self.definition = definition
        let initialState = RoundState(players: definition.players, holes: definition.holes)
        _localState = State(initialValue: initialState)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 5) {
                    Text(definition.course.name)
                        .font(.headline)
                    Text("\(definition.tee.name) • Par \(definition.totalPar)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.secondary.opacity(0.1))

                List {
                    ForEach(Array(definition.holes.enumerated()), id: \.element.id) { holeIndex, hole in
                        Section {
                            HoleEntrySection(
                                hole: hole,
                                players: definition.players,
                                state: $localState,
                                allHoles: definition.holes
                            )
                        } header: {
                            HStack {
                                Text("Hole \(hole.actualHoleNumber)")
                                    .font(.headline)
                                Spacer()
                                Text("Par \(hole.par)  SI \(hole.strokeIndex)")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                Button(action: {
                    commitState()
                    appState.showResults()
                }) {
                    Label("Calculate Results", systemImage: "chart.bar.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
            .navigationTitle("Score Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        commitState()
                        dismiss()
                    }
                }
            }
            .onAppear {
                if let existing = appState.roundState {
                    localState = existing
                }
            }
            .onDisappear {
                commitState()
            }
        }
    }

    private func commitState() {
        appState.roundState = localState
        appState.save()
    }
}

// MARK: - Hole entry row

struct HoleEntrySection: View {
    let hole: HoleDefinition
    let players: [Player]
    @Binding var state: RoundState
    let allHoles: [HoleDefinition]

    var body: some View {
        VStack(spacing: 0) {
            // Column headers
            HStack(spacing: 4) {
                Text("Player")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Strokes")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(width: 80, alignment: .center)
                Text("Putts")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(width: 60, alignment: .center)
            }
            .padding(.horizontal, 4)
            .padding(.bottom, 4)

            ForEach(players) { player in
                PlayerPickerRow(
                    player: player,
                    hole: hole,
                    state: $state,
                    allHoles: allHoles,
                    players: players
                )
                .padding(.vertical, 2)
            }

            if hole.isPar3 {
                Divider().padding(.vertical, 4)
                VStack(alignment: .leading, spacing: 6) {
                    Text("KP Winner")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Picker("KP Winner", selection: Binding(
                        get: { state.getKPWinner(for: hole.id) },
                        set: { state.setKPWinner($0, for: hole.id) }
                    )) {
                        Text("None").tag(nil as UUID?)
                        ForEach(players) { player in
                            Text(player.name).tag(player.id as UUID?)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
        }
        .padding(.vertical, 6)
    }
}

// MARK: - Per-player row with wheel pickers

struct PlayerPickerRow: View {
    let player: Player
    let hole: HoleDefinition
    @Binding var state: RoundState
    let allHoles: [HoleDefinition]
    let players: [Player]

    // Strokes picker binding: 0 = not set ("—"), 1-15 = actual strokes
    private var strokesBinding: Binding<Int> {
        Binding(
            get: { state.getGrossScore(for: player.id, holeID: hole.id) ?? 0 },
            set: { state.setGrossScore($0 == 0 ? nil : $0, for: player.id, holeID: hole.id) }
        )
    }

    // Putts picker binding: -1 = not set ("—"), 0-8 = actual putts
    private var puttsBinding: Binding<Int> {
        Binding(
            get: { state.getPutts(for: player.id, holeID: hole.id) ?? -1 },
            set: { state.setPutts($0 == -1 ? nil : $0, for: player.id, holeID: hole.id) }
        )
    }

    var body: some View {
        HStack(spacing: 4) {
            // Player name with indicators
            HStack(spacing: 3) {
                Text(player.name)
                    .font(.subheadline)
                    .lineLimit(1)
                if isSnakeHolder {
                    Text("🐍")
                        .font(.caption)
                }
                let pig = pigStatus
                if !pig.isEmpty {
                    Text(pig)
                        .font(.caption)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Strokes wheel picker
            Picker("", selection: strokesBinding) {
                Text("—").tag(0)
                ForEach(1...15, id: \.self) { n in
                    Text("\(n)").tag(n)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 80, height: 80)
            .clipped()

            // Putts wheel picker
            Picker("", selection: puttsBinding) {
                Text("—").tag(-1)
                ForEach(0...8, id: \.self) { n in
                    Text("\(n)").tag(n)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 60, height: 80)
            .clipped()
        }
    }

    // MARK: - Snake indicator

    /// True if this player currently has the most total putts in the round.
    private var isSnakeHolder: Bool {
        let myPutts = totalPutts(for: player.id)
        guard myPutts > 0 else { return false }
        return players.allSatisfy { totalPutts(for: $0.id) <= myPutts }
    }

    private func totalPutts(for playerID: UUID) -> Int {
        allHoles.reduce(0) { $0 + (state.getPutts(for: playerID, holeID: $1.id) ?? 0) }
    }

    // MARK: - Pig indicator

    /// Returns "" / "🐷" / "🐷🐷" based on whether the player has made par
    /// on the front nine and/or back nine (only shown once that nine is fully scored).
    private var pigStatus: String {
        let frontHoles = allHoles.filter { $0.actualHoleNumber <= 9 }
        let backHoles  = allHoles.filter { $0.actualHoleNumber > 9 }

        let frontPig = noPar(player: player, on: frontHoles)
        let backPig  = noPar(player: player, on: backHoles)

        let count = [frontPig, backPig].compactMap { $0 }.filter { $0 }.count
        if count == 2 { return "🐷🐷" }
        if count == 1 { return "🐷" }
        return ""
    }

    /// Returns nil if the nine isn't fully scored yet, true if no hole was par or better, false otherwise.
    private func noPar(player: Player, on holes: [HoleDefinition]) -> Bool? {
        guard !holes.isEmpty else { return nil }
        let results: [Bool] = holes.compactMap { hole in
            guard let score = state.getGrossScore(for: player.id, holeID: hole.id), score > 0 else { return nil }
            return score <= hole.par
        }
        guard results.count == holes.count else { return nil }  // not all holes scored yet
        return !results.contains(true)
    }
}

#Preview {
    let definition = RoundDefinition(
        players: MockCourseData.samplePlayers,
        course: MockCourseData.sampleCourse1,
        tee: MockCourseData.sampleTee1,
        holes: HoleBuilder.buildHoles(from: MockCourseData.sampleTee1, isNineHole: true, isBackNine: false),
        selectedGames: [.stableford, .skins],
        handicapMode: .relativeToLowest,
        isNineHole: true,
        isBackNine: false
    )

    return RoundPlayView(definition: definition)
        .environmentObject(AppState())
}
