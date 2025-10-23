//
//  KopniakApp.swift
//  Sergeant Kopniak
//
//  Created by alf on 02.10.2025.
//

import AppKit
import ComposableArchitecture
import SwiftUI

@main
struct KopniakApp: App {
    private static let store = Store(
        initialState: AppFeature.State(remindersStatus: .off)
    ) {
        AppFeature()
            #if DEBUG
                ._printChanges()
            #endif
    }

    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow

    var body: some Scene {
        // Main app window
        Window("Sergeant Kopniak", id: "briefing") {
            let store = KopniakApp.store.scope(
                state: \.briefing,
                action: \.briefing
            )
            BriefingView(store: store)
        }
        .defaultSize(width: 400, height: 500)
        .defaultPosition(.center)
        .windowResizability(.contentSize)
        .defaultLaunchBehavior(.suppressed)

        // Status bar menu
        MenuBarExtra {
            AppMenuView(store: KopniakApp.store)
        } label: {
            let store = KopniakApp.store.scope(
                state: \.menuIcon,
                action: \.menuIcon
            )
            let reminderStore = KopniakApp.store.scope(
                state: \.reminder,
                action: \.reminder
            )
            AppMenuIconView(store: store, reminderStore: reminderStore)
        }

        // Settings
        Settings {
            let store = KopniakApp.store.scope(
                state: \.settings,
                action: \.settings
            )
            SettingsView(store: store)
        }
        .defaultPosition(.center)

        // Launch at login dialog
        Window("Launch at Login", id: "launchAtLogin") {
            let store = KopniakApp.store.scope(
                state: \.launchAtLogin,
                action: \.launchAtLogin
            )
            LaunchAtLoginDialog(store: store)
        }
        .windowResizability(.contentSize)
        .defaultPosition(.center)
    }
}
