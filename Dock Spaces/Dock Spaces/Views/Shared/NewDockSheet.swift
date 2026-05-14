//
//  NewDockSheet.swift
//  Dock Spaces
//
//  Copyright (c) 2026 Patrik Tomas Chamelo.
//  Licensed under the MIT License. See LICENSE for details.
//

import SwiftUI

struct NewDockSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""

    let onCreate: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("New Dock")
                .font(.title2)
                .fontWeight(.semibold)

            TextField("Name", text: $name)
                .textFieldStyle(.roundedBorder)
                .onSubmit(create)

            HStack {
                Spacer()
                Button("Cancel") {
                    dismiss()
                }
                Button {
                    create()
                } label: {
                    Text("Create")
                }
                .buttonStyle(.glassProminent)
                .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(20)
        .frame(width: 360)
    }

    private func create() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        onCreate(trimmedName)
        dismiss()
    }
}
