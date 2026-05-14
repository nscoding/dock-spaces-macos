//
//  DockMenuView.swift
//  Dock Spaces
//
//  Copyright (c) 2026 Patrik Tomas Chamelo.
//  Licensed under the MIT License. See LICENSE for details.
//

import AppKit
import SwiftData
import SwiftUI

struct DockMenuView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openWindow) private var openWindow
    @Query(sort: \DockProfile.createdAt) private var profiles: [DockProfile]
    @AppStorage("menuBarOnly") private var menuBarOnly = false

    @State private var errorMessage: String?

    private let fileStore = DockProfileFileStore()

    var body: some View {
        VStack {
            ForEach(profiles) { profile in
                Button {
                    switchDock(profile)
                } label: {
                    Label(profile.name, systemImage: profile.isActive ? "checkmark.circle.fill" : "dock.rectangle")
                }
                .disabled(profile.isActive)
            }

            if profiles.isEmpty {
                Text("Open Dock Spaces to create the default dock")
            }

            Divider()

            Button {
                menuBarOnly = false
                openWindow(id: "main")
                DockSpacesApplicationMode.apply(menuBarOnly: false, hideWindows: false)
                NSApplication.shared.activate(ignoringOtherApps: true)
            } label: {
                Label("Show Window", systemImage: "macwindow")
            }

            Toggle("Menu Bar Only", isOn: $menuBarOnly)

            if let errorMessage {
                Divider()
                Text(errorMessage)
            }
        }
        .onChange(of: menuBarOnly) { _, newValue in
            DockSpacesApplicationMode.apply(menuBarOnly: newValue, hideWindows: newValue)
        }
    }

    private func switchDock(_ profile: DockProfile) {
        do {
            try fileStore.switchToProfile(profile, allProfiles: profiles)
            try modelContext.save()
            errorMessage = nil
        } catch {
            if let localizedError = error as? LocalizedError,
               let description = localizedError.errorDescription {
                errorMessage = description
            } else {
                errorMessage = error.localizedDescription
            }
        }
    }
}
