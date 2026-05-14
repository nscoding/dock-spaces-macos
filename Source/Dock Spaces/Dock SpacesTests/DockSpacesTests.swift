//
//  DockSpacesTests.swift
//  Dock SpacesTests
//
//  Copyright (c) 2026 Patrik Tomas Chamelo.
//  Licensed under the MIT License. See LICENSE for details.
//

import XCTest
@testable import Dock_Spaces

final class DockSpacesTests: XCTestCase {
    func testSafeFileComponentKeepsReadableName() {
        XCTAssertEqual(DockProfileFileStore.safeFileComponent(from: "Gaming Dock"), "gaming-dock")
        XCTAssertEqual(DockProfileFileStore.safeFileComponent(from: "Work/Focus: Left"), "work-focus-left")
    }

    func testSafeFileComponentFallsBackForEmptyName() {
        XCTAssertEqual(DockProfileFileStore.safeFileComponent(from: "   "), "dock")
        XCTAssertEqual(DockProfileFileStore.safeFileComponent(from: "///"), "dock")
    }

    func testProfileURLUsesStoredFileName() {
        let profile = DockProfile(name: "Gaming", plistFileName: "gaming.plist")
        let url = DockProfileFileStore().profileURL(for: profile)

        XCTAssertEqual(url.lastPathComponent, "gaming.plist")
    }
}
