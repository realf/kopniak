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
//                ._printChanges()
            #endif
    }

    private static let reminderController = ReminderController(
        store: store.scope(state: \.reminder, action: \.reminder)
    )

    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow

    var body: some Scene {
        // Main app window
        Window("Kopniak", id: "briefing") {
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
            AppMenuView(
                store: KopniakApp.store.scope(
                    state: \.appMenu,
                    action: \.appMenu
                )
            )
        } label: {
            let store = KopniakApp.store.scope(
                state: \.menuIcon,
                action: \.menuIcon
            )
            AppMenuIconView(
                store: store,
                reminderController: KopniakApp.reminderController
            )
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
            LaunchAtLoginView(store: store)
        }
        .windowResizability(.contentSize)
        .defaultPosition(.center)
    }
}
