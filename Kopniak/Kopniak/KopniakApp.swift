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
    }

    private let reminderController = ReminderController(
        store: store.scope(state: \.reminder, action: \.reminder)
    )

    private let statusItemController: StatusItemController = {
        let controller = StatusItemController(
            iconStore: store.scope(state: \.menuIcon, action: \.menuIcon),
            menuStore: store.scope(state: \.appMenu, action: \.appMenu)
        )
        controller.activateStatusItem()
        DispatchQueue.main.async {
            store.send(.statusItemDidActivate)
        }

        return controller
    }()

    @Environment(\.dismissWindow) private var dismissWindow
    @Environment(\.openSettings) private var openSettings
    @Environment(\.openWindow) private var openWindow

    var body: some Scene {
        // Main app window
        Window("Kopniak Briefing", id: "briefing") {
            let store = KopniakApp.store.scope(
                state: \.briefing,
                action: \.briefing
            )
            BriefingView(store: store)
        }
        .defaultSize(width: 400, height: 500)
        .defaultPosition(.center)
        .windowResizability(.contentSize)
        .restorationBehavior(.disabled)
        .commandsRemoved()
        .defaultLaunchBehavior(.suppressed)
        .onChange(of: Self.store.openWindow) { _, windowID in
            if let windowID {
                switch windowID.destination {
                case .briefing:
                    openWindow(id: "briefing")
                case .launchAtLogin:
                    openWindow(id: "launchAtLogin")
                case .reminder:
                    reminderController.showReminder(title: "Kopniak Command")
                case .settings:
                    openSettings()
                }
            }
        }
        .onChange(of: Self.store.dismissWindow) { _, windowID in
            if let windowID {
                switch windowID.destination {
                case .briefing:
                    dismissWindow(id: "briefing")
                case .launchAtLogin:
                    dismissWindow(id: "launchAtLogin")
                case .reminder:
                    reminderController.hideReminder()
                case .settings:
                    break
                }
            }
        }

        // Settings
        Settings {
            let store = KopniakApp.store.scope(
                state: \.settings,
                action: \.settings
            )
            SettingsView(store: store)
        }
        .windowResizability(.contentSize)
        .defaultPosition(.center)

        // Launch at login dialog
        Window("Launch Kopniak at Login?", id: "launchAtLogin") {
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
