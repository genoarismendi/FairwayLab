//
//  TestDataLoaderView.swift
//  FairwayLab
//
//  Developer tool to load test scorecard data
//

import SwiftUI

struct TestDataLoaderView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    
    @State private var availableTestFiles: [String] = []
    @State private var selectedFile: String?
    @State private var loadedTestData: ScorecardTestData?
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "hammer.circle.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.orange)
                    
                    Text("Test Data Loader")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Load pre-configured scorecards for testing")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top)
                
                Divider()
                
                // Available test files
                if availableTestFiles.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "doc.questionmark")
                            .font(.system(size: 50))
                            .foregroundStyle(.secondary)
                        
                        Text("No test data files found")
                            .font(.headline)
                        
                        Text("Add JSON files named 'scorecard_*.json' to your project")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(availableTestFiles, id: \.self) { filename in
                                TestFileRow(
                                    filename: filename,
                                    isSelected: selectedFile == filename,
                                    onTap: {
                                        loadTestFile(filename)
                                    }
                                )
                            }
                        }
                        .padding()
                    }
                }
                
                // Loaded data preview
                if let testData = loadedTestData {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Loaded: \(testData.name)", systemImage: "checkmark.circle.fill")
                            .font(.headline)
                            .foregroundStyle(.green)
                        
                        Text("\(testData.players.count) players • \(testData.isNineHole ? "9" : "18") holes")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Text("Games: \(testData.selectedGames.joined(separator: ", "))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                
                Spacer()
                
                // Actions
                VStack(spacing: 12) {
                    Button(action: loadIntoApp) {
                        Label("Load into App", systemImage: "arrow.down.circle.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(loadedTestData != nil ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(loadedTestData == nil)
                    
                    Button(action: { dismiss() }) {
                        Text("Cancel")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.secondary.opacity(0.2))
                            .foregroundColor(.primary)
                            .cornerRadius(10)
                    }
                }
                .padding()
            }
            .navigationTitle("Developer Tools")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Test Data Loader", isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
            .onAppear {
                availableTestFiles = TestDataLoader.listAvailableTestData()
            }
        }
    }
    
    private func loadTestFile(_ filename: String) {
        selectedFile = filename
        
        if let testData = TestDataLoader.loadTestData(filename: filename) {
            loadedTestData = testData
            alertMessage = "✅ Loaded '\(testData.name)'"
            showingAlert = true
        } else {
            loadedTestData = nil
            alertMessage = "❌ Failed to load test data"
            showingAlert = true
        }
    }
    
    private func loadIntoApp() {
        guard let testData = loadedTestData else { return }
        
        guard let (definition, state) = TestDataLoader.createRound(from: testData) else {
            alertMessage = "❌ Failed to create round from test data"
            showingAlert = true
            return
        }
        
        // Load into app state
        appState.roundDefinition = definition
        appState.roundState = state
        appState.lastValidRoundDefinition = definition
        appState.save()
        
        alertMessage = "✅ Test data loaded into app!\nYou can now view results or continue the round."
        showingAlert = true
        
        // Auto-dismiss after loading
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            dismiss()
        }
    }
}

struct TestFileRow: View {
    let filename: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var displayName: String {
        filename
            .replacingOccurrences(of: "scorecard_", with: "")
            .replacingOccurrences(of: "_", with: " ")
            .capitalized
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: "doc.text.fill")
                    .foregroundStyle(isSelected ? .blue : .secondary)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(displayName)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    Text(filename)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.blue)
                }
            }
            .padding()
            .background(isSelected ? Color.blue.opacity(0.1) : Color.secondary.opacity(0.05))
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    TestDataLoaderView()
        .environmentObject(AppState())
}
