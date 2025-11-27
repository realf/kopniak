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
            Tab(
                "Advanced",
                systemImage: "slider.horizontal.3",
                value: SettingsTab.advanced
            ) {
                AdvancedSettingsView(
                    store: store.scope(
                        state: \.advanced,
                        action: \.advanced
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
    let menuIconTimeDisplay = Shared(value: TimeDisplaySetting.short)
    let reminderStyle = Shared(value: ReminderStyle.simple)
    let restartAfterScreenLock = Shared(value: true)
    let reminderSound = Shared(value: Optional<String>.none)
    let soundVolume = Shared(value: 1.0)
    let store = Store(
        initialState: SettingsFeature.State(
            reminderInterval: reminderInterval,
            snoozeInterval: snoozeInterval,
            menuIconTimeDisplay: menuIconTimeDisplay,
            reminderStyle: reminderStyle,
            restartAfterScreenLock: restartAfterScreenLock,
            reminderSound: reminderSound,
            soundVolume: soundVolume,
            showMainWindowAtLaunch: Shared(value: true),
            showMenuBarIcon: Shared(value: false)
        ),
        reducer: {
            SettingsFeature()
        }
    )
    SettingsView(store: store)
}
