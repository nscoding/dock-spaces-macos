//
//  SettingsPane.swift
//  Dock Spaces
//
//  Copyright (c) 2026 Patrik Tomas Chamelo.
//  Licensed under the MIT License. See LICENSE for details.
//

import SwiftUI

struct SettingsPane: View {
    @Binding var menuBarOnly: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            SettingsCard {
                SettingsRow(title: "Menu Bar Only") {
                    Toggle("", isOn: $menuBarOnly)
                        .labelsHidden()
                        .toggleStyle(.switch)
                }
            }
            .padding(.top, 8)
        }
    }
}
