//
//  DocksPane.swift
//  Dock Spaces
//
//  Copyright (c) 2026 Patrik Tomas Chamelo.
//  Licensed under the MIT License. See LICENSE for details.
//

import SwiftUI

struct DocksPane: View {
    let profiles: [DockProfile]
    let selectedProfile: DockProfile?
    @Binding var selectedProfileID: UUID?
    let onSwitch: (DockProfile) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            SettingsCard {
                ForEach(profiles) { profile in
                    DockProfileRow(
                        profile: profile,
                        isSelected: selectedProfile?.id == profile.id,
                        onSelect: {
                            selectedProfileID = profile.id
                        },
                        onSwitch: {
                            selectedProfileID = profile.id
                            onSwitch(profile)
                        }
                    )

                    if profile.id != profiles.last?.id {
                        Divider()
                    }
                }
            }
            .padding(.top, 8)
        }
    }
}

private struct DockProfileRow: View {
    let profile: DockProfile
    let isSelected: Bool
    let onSelect: () -> Void
    let onSwitch: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Button {
                onSelect()
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: profile.isDefault ? "dock.rectangle" : "rectangle.stack")
                        .font(.title3)
                        .frame(width: 28)
                        .foregroundStyle(profile.isActive ? .green : .blue)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(profile.name)
                            .font(.headline)
                        Text(profile.updatedAt, format: .dateTime.month().day().hour().minute())
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    if profile.isDefault {
                        Text("Default")
                            .foregroundStyle(.secondary)
                    }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if profile.isActive {
                Text("Active")
                    .fontWeight(.semibold)
                    .foregroundStyle(.green)
            } else {
                Button("Switch") {
                    onSwitch()
                }
                .buttonStyle(.glass)
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        .background(isSelected ? Color.accentColor.opacity(0.18) : Color.clear, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}
