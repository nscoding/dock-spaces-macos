//
//  Item.swift
//  Dock Spaces
//
//  Copyright (c) 2026 Patrik Tomas Chamelo.
//  Licensed under the MIT License. See LICENSE for details.
//

import AppKit
import Darwin
import Foundation
import SwiftData

@Model
final class DockProfile {
    @Attribute(.unique) var id: UUID
    var name: String
    var plistFileName: String
    var isDefault: Bool
    var isActive: Bool
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        plistFileName: String,
        isDefault: Bool = false,
        isActive: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.plistFileName = plistFileName
        self.isDefault = isDefault
        self.isActive = isActive
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

enum DockProfileError: LocalizedError {
    case dockPlistMissing(URL)
    case profilePlistMissing(URL)
    case invalidProfileName
    case commandFailed(String, Int32)

    var errorDescription: String? {
        switch self {
        case .dockPlistMissing(let url):
            "The current Dock plist could not be found at \(url.path)."
        case .profilePlistMissing(let url):
            "The saved Dock plist could not be found at \(url.path)."
        case .invalidProfileName:
            "Enter a name for the Dock."
        case .commandFailed(let command, let status):
            "The command `\(command)` failed with exit code \(status)."
        }
    }
}

struct DockProfileFileStore {
    static let liveDockPlistURL = realHomeDirectoryURL()
        .appendingPathComponent("Library/Preferences/com.apple.dock.plist")

    static var profilesDirectoryURL: URL {
        let applicationSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        return applicationSupport.appendingPathComponent("Dock Spaces/Docks", isDirectory: true)
    }

    func ensureProfilesDirectory() throws {
        try FileManager.default.createDirectory(
            at: Self.profilesDirectoryURL,
            withIntermediateDirectories: true
        )
    }

    func profileURL(for profile: DockProfile) -> URL {
        Self.profilesDirectoryURL.appendingPathComponent(profile.plistFileName)
    }

    func createDefaultProfileIfNeeded(existingProfiles: [DockProfile]) throws -> DockProfile? {
        guard existingProfiles.isEmpty else { return nil }
        return try createProfile(named: "Default", isDefault: true, isActive: true)
    }

    func createProfile(named rawName: String, isDefault: Bool = false, isActive: Bool = false) throws -> DockProfile {
        let trimmedName = rawName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { throw DockProfileError.invalidProfileName }

        try ensureLiveDockPlistExists()
        try ensureProfilesDirectory()

        let fileName = "\(Self.safeFileComponent(from: trimmedName))-\(UUID().uuidString).plist"
        let destinationURL = Self.profilesDirectoryURL.appendingPathComponent(fileName)
        try exportDockPreferences(to: destinationURL)

        return DockProfile(
            name: trimmedName,
            plistFileName: fileName,
            isDefault: isDefault,
            isActive: isActive
        )
    }

    func saveCurrentDock(to profile: DockProfile) throws {
        try ensureLiveDockPlistExists()
        try ensureProfilesDirectory()

        let destinationURL = profileURL(for: profile)
        if FileManager.default.fileExists(atPath: destinationURL.path) {
            try FileManager.default.removeItem(at: destinationURL)
        }

        try exportDockPreferences(to: destinationURL)
        profile.updatedAt = Date()
    }

    func switchToProfile(_ profile: DockProfile, allProfiles: [DockProfile]) throws {
        let sourceURL = profileURL(for: profile)
        guard FileManager.default.fileExists(atPath: sourceURL.path) else {
            throw DockProfileError.profilePlistMissing(sourceURL)
        }

        if let activeProfile = allProfiles.first(where: { $0.isActive && $0.id != profile.id }) {
            try saveCurrentDock(to: activeProfile)
        }

        let liveURL = Self.liveDockPlistURL
        let backupURL = liveURL.deletingLastPathComponent()
            .appendingPathComponent("com.apple.dock.plist.dock-spaces-backup")

        if FileManager.default.fileExists(atPath: backupURL.path) {
            try FileManager.default.removeItem(at: backupURL)
        }

        if FileManager.default.fileExists(atPath: liveURL.path) {
            try FileManager.default.moveItem(at: liveURL, to: backupURL)
        }

        do {
            try importDockPreferences(from: sourceURL)
        } catch {
            if FileManager.default.fileExists(atPath: backupURL.path) {
                try? FileManager.default.moveItem(at: backupURL, to: liveURL)
            }
            throw error
        }

        for dockProfile in allProfiles {
            dockProfile.isActive = dockProfile.id == profile.id
        }
        profile.updatedAt = Date()
        restartDockPreferences()
    }

    func revealPlist(for profile: DockProfile) {
        NSWorkspace.shared.activateFileViewerSelecting([profileURL(for: profile)])
    }

    private func ensureLiveDockPlistExists() throws {
        guard FileManager.default.fileExists(atPath: Self.liveDockPlistURL.path) else {
            throw DockProfileError.dockPlistMissing(Self.liveDockPlistURL)
        }
    }

    private func exportDockPreferences(to destinationURL: URL) throws {
        try runCommand("/usr/bin/defaults", arguments: ["export", "com.apple.dock", destinationURL.path])
    }

    private func importDockPreferences(from sourceURL: URL) throws {
        try runCommand("/usr/bin/defaults", arguments: ["import", "com.apple.dock", sourceURL.path])
    }

    private func restartDockPreferences() {
        try? runCommand("/usr/bin/killall", arguments: ["cfprefsd"])
        try? runCommand("/usr/bin/killall", arguments: ["Dock"])
    }

    private func runCommand(_ executablePath: String, arguments: [String]) throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executablePath)
        process.arguments = arguments
        try process.run()
        process.waitUntilExit()

        guard process.terminationStatus == 0 else {
            throw DockProfileError.commandFailed(([executablePath] + arguments).joined(separator: " "), process.terminationStatus)
        }
    }

    static func safeFileComponent(from string: String) -> String {
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-_"))
        let components = string.unicodeScalars.map { scalar in
            allowed.contains(scalar) ? String(scalar) : "-"
        }
        let collapsed = components.joined()
            .split(separator: "-", omittingEmptySubsequences: true)
            .joined(separator: "-")
            .lowercased()
        return collapsed.isEmpty ? "dock" : collapsed
    }

    static func realHomeDirectoryURL() -> URL {
        if let passwordEntry = getpwuid(getuid()),
           let homeDirectory = passwordEntry.pointee.pw_dir {
            return URL(fileURLWithPath: String(cString: homeDirectory), isDirectory: true)
        }

        return URL(fileURLWithPath: NSHomeDirectory(), isDirectory: true)
    }
}
