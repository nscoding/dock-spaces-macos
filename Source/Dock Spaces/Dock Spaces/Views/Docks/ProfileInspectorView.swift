//
//  ProfileInspectorView.swift
//  Dock Spaces
//
//  Copyright (c) 2026 Patrik Tomas Chamelo.
//  Licensed under the MIT License. See LICENSE for details.
//

import SwiftUI

struct ProfileInspectorView: View {
    let profile: DockProfile
    let fileStore: DockProfileFileStore
    let onReveal: () -> Void
    let onSaveCurrent: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 6) {
                Image(systemName: profile.isDefault ? "dock.rectangle" : "rectangle.stack")
                    .font(.system(size: 34))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(profile.isActive ? .green : .blue)

                Text(profile.name)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .lineLimit(2)

                Text(profile.isActive ? "Active dock" : "Saved dock")
                    .foregroundStyle(.secondary)
            }

            SettingsGroup(title: "Profile File") {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Plist")
                        .font(.headline)
                    Text(fileStore.profileURL(for: profile).path)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .textSelection(.enabled)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            SettingsGroup(title: "Actions") {
                VStack(spacing: 10) {
                    Button("Reveal in Finder") {
                        onReveal()
                    }
                    .buttonStyle(.glass)
                    .frame(maxWidth: .infinity)

                    Button("Save Current Dock") {
                        onSaveCurrent()
                    }
                    .buttonStyle(.glass)
                    .frame(maxWidth: .infinity)
                }
            }

            Spacer()
        }
        .padding(16)
        .frame(width: 240)
        .background(.ultraThinMaterial)
    }
}
