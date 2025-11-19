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
        // Launch at login dialog
        Window("Open Kopniak automatically?", id: "launchAtLogin") {
            let store = KopniakApp.store.scope(
                state: \.launchAtLogin,
                action: \.launchAtLogin
            )
            LaunchAtLoginView(store: store)
        }
        .windowResizability(.contentSize)
        .defaultPosition(.center)
        .restorationBehavior(.disabled)
        .commandsRemoved()
        .defaultLaunchBehavior(.suppressed)

        // Add this window, so that the app does not close when there are no other windows
        Window("Empty", id: "lastWindow") {
            EmptyView()
        }
        .defaultLaunchBehavior(.suppressed)
        .restorationBehavior(.disabled)

        // Settings
        Settings {
            let store = KopniakApp.store.scope(
                state: \.settings,
                action: \.settings
            )
            SettingsView(store: store)
        }
        .defaultLaunchBehavior(.suppressed)
        .windowResizability(.contentSize)
        .defaultPosition(.center)
        .onChange(of: Self.store.openWindow) { _, windowID in
            if let windowID {
                switch windowID.destination {
                case .launchAtLogin:
                    openWindow(id: "launchAtLogin")
                case .menu:
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        statusItemController.showMenu()
                    }
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
                case .launchAtLogin:
                    dismissWindow(id: "launchAtLogin")
                case .menu:
                    DispatchQueue.main.async {
                        statusItemController.hideMenu()
                    }
                case .reminder:
                    reminderController.hideReminder()
                case .settings:
                    break
                }
            }
        }
    }
}
