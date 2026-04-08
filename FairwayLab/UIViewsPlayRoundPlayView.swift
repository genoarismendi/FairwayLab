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
    @FocusState private var focusedField: String?
    
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
                
                // Score entry
                ScrollViewReader { proxy in
                    List {
                        ForEach(Array(definition.holes.enumerated()), id: \.element.id) { holeIndex, hole in
                            Section {
                                HoleEntrySection(
                                    hole: hole,
                                    holeIndex: holeIndex,
                                    totalHoles: definition.holes.count,
                                    players: definition.players,
                                    state: $localState,
                                    focusedField: $focusedField,
                                    allHoles: definition.holes
                                )
                            } header: {
                                HStack {
                                    Text("Hole \(hole.actualHoleNumber)")
                                        .font(.headline)
                                    Spacer()
                                    Text("Par \(hole.par)")
                                        .font(.subheadline)
                                }
                            }
                            .id("hole-\(hole.id)")
                        }
                    }
                    .onChange(of: focusedField) { _, newValue in
                        // Auto-scroll to keep focused field visible
                        if let fieldId = newValue {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    proxy.scrollTo(fieldId, anchor: .center)
                                }
                            }
                        }
                    }
                }
                
                // Calculate button
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
    }
}

struct HoleEntrySection: View {
    let hole: HoleDefinition
    let holeIndex: Int
    let totalHoles: Int
    let players: [Player]
    @Binding var state: RoundState
    var focusedField: FocusState<String?>.Binding
    let allHoles: [HoleDefinition]
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(Array(players.enumerated()), id: \.element.id) { playerIndex, player in
                HStack {
                    Text(player.name)
                        .frame(width: 100, alignment: .leading)
                    
                    Spacer()
                    
                    // Strokes
                    TextField("Strokes", value: Binding(
                        get: { state.getGrossScore(for: player.id, holeID: hole.id) },
                        set: { state.setGrossScore($0, for: player.id, holeID: hole.id) }
                    ), format: .number)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 60)
                    .multilineTextAlignment(.center)
                    .focused(focusedField, equals: "strokes-\(hole.id)-\(player.id)")
                    .id("strokes-\(hole.id)-\(player.id)")
                    .submitLabel(.next)
                    .onSubmit {
                        // Tab key pressed - move to putts
                        DispatchQueue.main.async {
                            focusedField.wrappedValue = "putts-\(hole.id)-\(player.id)"
                        }
                    }
                    
                    // Putts
                    TextField("Putts", value: Binding(
                        get: { state.getPutts(for: player.id, holeID: hole.id) },
                        set: { state.setPutts($0, for: player.id, holeID: hole.id) }
                    ), format: .number)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 60)
                    .multilineTextAlignment(.center)
                    .focused(focusedField, equals: "putts-\(hole.id)-\(player.id)")
                    .id("putts-\(hole.id)-\(player.id)")
                    .submitLabel(.next)
                    .onSubmit {
                        // Tab key pressed - move to next player or hole
                        DispatchQueue.main.async {
                            moveToNextField(fromPlayerIndex: playerIndex)
                        }
                    }
                }
            }
            
            if hole.isPar3 {
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
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
        .padding(.vertical, 8)
    }
    
    private func moveToNextField(fromPlayerIndex: Int) {
        if fromPlayerIndex < players.count - 1 {
            // Move to next player's strokes
            let nextPlayer = players[fromPlayerIndex + 1]
            focusedField.wrappedValue = "strokes-\(hole.id)-\(nextPlayer.id)"
        } else if holeIndex < totalHoles - 1 {
            // Move to next hole, first player
            let nextHole = allHoles[holeIndex + 1]
            let firstPlayer = players[0]
            focusedField.wrappedValue = "strokes-\(nextHole.id)-\(firstPlayer.id)"
        } else {
            // Last field - unfocus
            focusedField.wrappedValue = nil
        }
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
