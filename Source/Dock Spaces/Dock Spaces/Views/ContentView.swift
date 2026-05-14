//
//  ContentView.swift
//  Dock Spaces
//
//  Copyright (c) 2026 Patrik Tomas Chamelo.
//  Licensed under the MIT License. See LICENSE for details.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DockProfile.createdAt) private var profiles: [DockProfile]
    @AppStorage("menuBarOnly") private var menuBarOnly = false

    @State private var selectedSection: SidebarSection = .docks
    @State private var selectedProfileID: UUID?
    @State private var isShowingNewDockSheet = false
    @State private var errorMessage: String?

    private let fileStore = DockProfileFileStore()

    private var selectedProfile: DockProfile? {
        if let selectedProfileID,
           let profile = profiles.first(where: { $0.id == selectedProfileID }) {
            return profile
        }
        return profiles.first(where: \.isActive) ?? profiles.first
    }

    private var navigationTitle: String {
        selectedSection.title
    }

    var body: some View {
        NavigationSplitView {
            DockSpacesSidebar(selectedSection: $selectedSection)
                .navigationSplitViewColumnWidth(min: 150, ideal: 170, max: 200)
        } detail: {
            HStack(spacing: 0) {
                detailPane

                if selectedSection == .docks, let selectedProfile {
                    Divider()
                    ProfileInspectorView(
                        profile: selectedProfile,
                        fileStore: fileStore,
                        onReveal: revealSelectedDock,
                        onSaveCurrent: saveCurrentDockToSelectedProfile
                    )
                }
            }
        }
        .frame(minWidth: 820, minHeight: 520)
        .navigationTitle(navigationTitle)
        .toolbar {
            if selectedSection == .docks {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isShowingNewDockSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .help("Create New Dock")
                }
            }
        }
        .containerBackground(.thinMaterial, for: .window)
        .sheet(isPresented: $isShowingNewDockSheet) {
            NewDockSheet { name in
                createDock(named: name)
            }
        }
        .alert("Dock Spaces", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
        .task {
            ensureDefaultDockExists()
        }
        .onAppear {
            DockSpacesApplicationMode.apply(menuBarOnly: menuBarOnly, hideWindows: false)
        }
        .onChange(of: menuBarOnly) { _, newValue in
            DockSpacesApplicationMode.apply(menuBarOnly: newValue, hideWindows: newValue)
        }
    }

    private var detailPane: some View {
        ScrollView {
            Group {
                switch selectedSection {
                case .docks:
                    DocksPane(
                        profiles: profiles,
                        selectedProfile: selectedProfile,
                        selectedProfileID: $selectedProfileID,
                        onSwitch: switchToDock
                    )
                case .settings:
                    SettingsPane(menuBarOnly: $menuBarOnly)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
            .frame(maxWidth: 520, alignment: .leading)
        }
        .frame(maxWidth: .infinity)
        .background(.regularMaterial)
    }

    private func ensureDefaultDockExists() {
        do {
            if let defaultProfile = try fileStore.createDefaultProfileIfNeeded(existingProfiles: profiles) {
                modelContext.insert(defaultProfile)
                selectedProfileID = defaultProfile.id
                try modelContext.save()
            } else if selectedProfileID == nil {
                selectedProfileID = selectedProfile?.id
            }
        } catch {
            show(error)
        }
    }

    private func createDock(named name: String) {
        do {
            let profile = try fileStore.createProfile(named: name)
            modelContext.insert(profile)
            selectedProfileID = profile.id
            try modelContext.save()
        } catch {
            show(error)
        }
    }

    private func revealSelectedDock() {
        guard let selectedProfile else { return }
        fileStore.revealPlist(for: selectedProfile)
    }

    private func saveCurrentDockToSelectedProfile() {
        guard let selectedProfile else { return }
        do {
            try fileStore.saveCurrentDock(to: selectedProfile)
            try modelContext.save()
        } catch {
            show(error)
        }
    }

    private func switchToDock(_ profile: DockProfile) {
        do {
            try fileStore.switchToProfile(profile, allProfiles: profiles)
            try modelContext.save()
        } catch {
            show(error)
        }
    }

    private func show(_ error: Error) {
        if let localizedError = error as? LocalizedError,
           let description = localizedError.errorDescription {
            errorMessage = description
        } else {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    let container = try! ModelContainer(
        for: DockProfile.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let context = ModelContext(container)
    context.insert(DockProfile(name: "Default", plistFileName: "default.plist", isDefault: true, isActive: true))
    context.insert(DockProfile(name: "Gaming", plistFileName: "gaming.plist"))

    return ContentView()
        .modelContainer(container)
}
