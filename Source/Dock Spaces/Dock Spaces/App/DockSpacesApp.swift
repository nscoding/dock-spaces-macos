//
//  DockSpacesApp.swift
//  Dock Spaces
//
//  Copyright (c) 2026 Patrik Tomas Chamelo.
//  Licensed under the MIT License. See LICENSE for details.
//

import AppKit
import SwiftData
import SwiftUI

@main
struct DockSpacesApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            DockProfile.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    init() {
        let menuBarOnly = UserDefaults.standard.bool(forKey: "menuBarOnly")
        DockSpacesApplicationMode.apply(menuBarOnly: menuBarOnly, hideWindows: false)
    }

    var body: some Scene {
        WindowGroup(id: "main") {
            ContentView()
        }
        .modelContainer(sharedModelContainer)

        MenuBarExtra("Dock Spaces", systemImage: "dock.rectangle") {
            DockMenuView()
                .modelContainer(sharedModelContainer)
        }
    }
}

enum DockSpacesApplicationMode {
    static func apply(menuBarOnly: Bool, hideWindows: Bool) {
        let application = NSApplication.shared
        application.setActivationPolicy(menuBarOnly ? .accessory : .regular)

        if hideWindows {
            application.windows.forEach { window in
                guard window.isVisible else { return }
                window.orderOut(nil)
            }
        }
    }
}
