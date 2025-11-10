//
//  SettingsView.swift
//  Sergeant Kopniak
//
//  Created by alf on 02.10.2025.
//

import ComposableArchitecture
import SwiftUI

struct SettingsView: View {
    @Bindable var store: StoreOf<SettingsFeature>

    var body: some View {
        TabView(
            selection: Binding(
                get: { store.selectedTab },
                set: { store.send(.selectTab($0)) }
            )
        ) {
            Tab("General", systemImage: "gearshape", value: SettingsTab.general)
            {
                GeneralSettingsView(
                    store: store.scope(
                        state: \.generalSettings,
                        action: \.generalSettings
                    )
                )
            }
            Tab("About", systemImage: "info.circle", value: SettingsTab.about) {
                AboutView(
                    store: store.scope(
                        state: \.about,
                        action: \.about
                    )
                )
                .padding()
            }
        }
        .frame(width: 700)
        .frame(minHeight: 500)
    }
}

#Preview {
    let reminderInterval = Shared(value: 25.0 * 60)
    let snoozeInterval = Shared(value: 10.0 * 60)
    let menuIconTimeDisplay = Shared(value: TimeDisplaySetting.abbreviated)
    let store = Store(
        initialState: SettingsFeature.State(
            reminderInterval: reminderInterval,
            snoozeInterval: snoozeInterval,
            menuIconTimeDisplay: menuIconTimeDisplay
        ),
        reducer: {
            SettingsFeature()
        }
    )
    SettingsView(store: store)
}
