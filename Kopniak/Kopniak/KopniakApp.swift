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
        initialState: AppFeature.State(remindersStatus: .on)
    ) {
        AppFeature()
            ._printChanges()
    }

    @State private var settingsManager: SettingsManager
    @State private var reminderManager: ReminderManager
    @State private var onboardingManager: OnboardingManager?
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow

    init() {
        // Initialize managers with dependencies
        let settings = SettingsManager()
        let reminders = ReminderManager(settingsManager: settings)

        self._settingsManager = State(wrappedValue: settings)
        self._reminderManager = State(wrappedValue: reminders)

        // Don't restore state here - wait until OnboardingManager is ready
    }

    var body: some Scene {
        // Main app window
        Window("Sergeant Kopniak", id: "main") {
            ContentView()
                .environment(reminderManager)
                .environment(settingsManager)
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
                .task {
                    // Create OnboardingManager now that openWindow is available
                    if onboardingManager == nil {
                        onboardingManager = OnboardingManager(
                            settingsManager: settingsManager,
                            reminderManager: reminderManager,
                            openWindow: openWindow
                        )
                    }

                    // Restore the persisted state
                    reminderManager.restorePersistedState()

                    // Activate the app to bring it to front
                    NSApplication.shared.activate(ignoringOtherApps: true)
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
        .defaultPosition(.center)

        // Launch at login dialog
        Window("Launch at Login", id: "launch-at-login-dialog") {
            LaunchAtLoginDialog { response in
                if let onboardingManager {
                    onboardingManager.handleLaunchAtLoginDialogResponse(
                        response
                    )
                    // Close the window after response
                    dismissWindow(id: "launch-at-login-dialog")
                }
            }
        }
        .windowResizability(.contentSize)
        .defaultPosition(.center)
    }
}
