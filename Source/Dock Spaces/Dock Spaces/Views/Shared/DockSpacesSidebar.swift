//
//  DockSpacesSidebar.swift
//  Dock Spaces
//
//  Copyright (c) 2026 Patrik Tomas Chamelo.
//  Licensed under the MIT License. See LICENSE for details.
//

import SwiftUI

struct DockSpacesSidebar: View {
    @Binding var selectedSection: SidebarSection

    var body: some View {
        List(selection: $selectedSection) {
            SidebarSectionRow(title: "Docks", systemImage: "dock.rectangle")
                .tag(SidebarSection.docks)

            SidebarSectionRow(title: "Settings", systemImage: "gearshape")
                .tag(SidebarSection.settings)
        }
        .listStyle(.sidebar)
        .padding(.horizontal, 6)
        .padding(.top, 8)
    }
}

private struct SidebarSectionRow: View {
    let title: String
    let systemImage: String

    var body: some View {
        Label {
            Text(title)
                .font(.callout)
        } icon: {
            Image(systemName: systemImage)
                .font(.callout)
                .symbolRenderingMode(.monochrome)
        }
        .padding(.vertical, 3)
    }
}
