//
//  SidebarSection.swift
//  Dock Spaces
//
//  Copyright (c) 2026 Patrik Tomas Chamelo.
//  Licensed under the MIT License. See LICENSE for details.
//

import Foundation

enum SidebarSection: Hashable {
    case docks
    case settings

    var title: String {
        switch self {
        case .docks:
            "Docks"
        case .settings:
            "Settings"
        }
    }
}
