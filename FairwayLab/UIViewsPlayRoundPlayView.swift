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
        appState.forceSave()  // Explicitly save after committing scores
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
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(player.name)
                            .font(.headline)
                        
                        // Show snake emoji if player currently has most putts
                        if state.getCurrentSnakeHolder() == player.id {
                            Text("🐍")
                                .font(.title3)
                        }
                        
                        // Show pig emojis based on par performance
                        if !state.madeParOnNine(playerID: player.id, isBackNine: false) {
                            Text("🐷")
                                .font(.title3)
                        }
                        if !state.madeParOnNine(playerID: player.id, isBackNine: true) && allHoles.contains(where: { $0.actualHoleNumber >= 10 }) {
                            Text("🐷")
                                .font(.title3)
                        }
                    }
                    
                    HStack(spacing: 15) {
                        // Strokes Picker
                        VStack(spacing: 4) {
                            Text("Strokes")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            Picker("Strokes", selection: Binding(
                                get: { state.getGrossScore(for: player.id, holeID: hole.id) ?? 0 },
                                set: { newValue in
                                    state.setGrossScore(newValue == 0 ? nil : newValue, for: player.id, holeID: hole.id)
                                }
                            )) {
                                Text("-").tag(0)
                                ForEach(1...15, id: \.self) { stroke in
                                    Text("\(stroke)").tag(stroke)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(width: 80, height: 100)
                            .clipped()
                        }
                        
                        // Putts Picker
                        VStack(spacing: 4) {
                            Text("Putts")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            Picker("Putts", selection: Binding(
                                get: { state.getPutts(for: player.id, holeID: hole.id) ?? 0 },
                                set: { newValue in
                                    state.setPutts(newValue == 0 ? nil : newValue, for: player.id, holeID: hole.id)
                                }
                            )) {
                                Text("-").tag(0)
                                ForEach(0...8, id: \.self) { putt in
                                    Text("\(putt)").tag(putt)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(width: 60, height: 100)
                            .clipped()
                        }
                    }
                    .padding(.vertical, 4)
                }
                .padding(.vertical, 8)
                
                if playerIndex < players.count - 1 {
                    Divider()
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
