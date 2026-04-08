//
//  StrokeIndexEditorView.swift
//  GolfX
//
//  Manual stroke index editor for fixing invalid data
//

import SwiftUI

struct StrokeIndexEditorView: View {
    @ObservedObject var viewModel: SetupWizardViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var editedHoles: [HoleDefinition]
    @State private var validationError: String?
    
    init(viewModel: SetupWizardViewModel) {
        self.viewModel = viewModel
        self._editedHoles = State(initialValue: viewModel.holes)
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("Edit the stroke index (SI) for each hole. Stroke index should be unique numbers from 1 to \(viewModel.holes.count), where 1 is the hardest hole.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                if let error = validationError {
                    Section {
                        Label(error, systemImage: "exclamationmark.triangle.fill")
                            .foregroundStyle(.red)
                    }
                }
                
                Section("Holes") {
                    ForEach(editedHoles) { hole in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Hole \(hole.actualHoleNumber)")
                                    .font(.headline)
                                HStack(spacing: 12) {
                                    Text("Par \(hole.par)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Text("\(hole.yardage) yds")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            HStack(spacing: 8) {
                                Text("SI:")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                
                                Stepper(
                                    value: Binding(
                                        get: { hole.strokeIndex },
                                        set: { newValue in
                                            updateStrokeIndex(for: hole.id, to: newValue)
                                        }
                                    ),
                                    in: 1...viewModel.holes.count
                                ) {
                                    Text("\(hole.strokeIndex)")
                                        .font(.headline)
                                        .frame(minWidth: 30)
                                        .multilineTextAlignment(.trailing)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                Section {
                    Button("Reset to Sequential (1, 2, 3...)") {
                        resetToSequential()
                    }
                    .foregroundStyle(.orange)
                }
            }
            .navigationTitle("Edit Stroke Index")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func updateStrokeIndex(for holeID: UUID, to newValue: Int) {
        if let index = editedHoles.firstIndex(where: { $0.id == holeID }) {
            editedHoles[index].strokeIndex = newValue
        }
        validateStrokeIndices()
    }
    
    private func validateStrokeIndices() {
        let indices = editedHoles.map { $0.strokeIndex }
        let expectedSet = Set(1...editedHoles.count)
        let actualSet = Set(indices)
        
        if actualSet.count != indices.count {
            validationError = "Duplicate stroke indices found. Each hole must have a unique value."
        } else if expectedSet != actualSet {
            let missing = expectedSet.subtracting(actualSet).sorted()
            let extra = actualSet.subtracting(expectedSet).sorted()
            
            if !missing.isEmpty {
                validationError = "Missing stroke indices: \(missing.map(String.init).joined(separator: ", "))"
            } else if !extra.isEmpty {
                validationError = "Invalid stroke indices (must be 1-\(editedHoles.count)): \(extra.map(String.init).joined(separator: ", "))"
            }
        } else {
            validationError = nil
        }
    }
    
    private func resetToSequential() {
        editedHoles = editedHoles.enumerated().map { index, hole in
            var mutableHole = hole
            mutableHole.strokeIndex = index + 1
            return mutableHole
        }
        validateStrokeIndices()
    }
    
    private func saveChanges() {
        validateStrokeIndices()
        
        if validationError == nil {
            // Update the view model with edited holes
            for hole in editedHoles {
                viewModel.updateStrokeIndex(for: hole.id, newIndex: hole.strokeIndex)
            }
            dismiss()
        }
    }
}

#Preview {
    let viewModel = SetupWizardViewModel()
    viewModel.holes = [
        HoleDefinition(actualHoleNumber: 1, displayOrder: 1, par: 4, strokeIndex: 5, yardage: 400),
        HoleDefinition(actualHoleNumber: 2, displayOrder: 2, par: 3, strokeIndex: 5, yardage: 180),
        HoleDefinition(actualHoleNumber: 3, displayOrder: 3, par: 5, strokeIndex: 3, yardage: 520)
    ]
    
    return StrokeIndexEditorView(viewModel: viewModel)
}
