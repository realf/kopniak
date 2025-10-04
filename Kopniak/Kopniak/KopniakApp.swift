//
//  KopniakApp.swift
//  Sergeant Kopniak
//
//  Created by alf on 02.10.2025.
//

import SwiftUI
import AppKit

@main
struct KopniakApp: App {
    @State private var settingsManager = SettingsManager()
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

        // Restore the persisted state
        reminderManager.restorePersistedState()
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
        .defaultLaunchBehavior(settingsManager.showMainWindowOnLaunch ? .presented : .suppressed)

        // Status bar menu
        MenuBarExtra {
            StatusBarMenu()
            .environment(reminderManager)
            .environment(settingsManager)
        } label: {
            Image(systemName: reminderManager.isActive ? "chevron.up.2" : "chevron.up.dotted.2")
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
                }
        }

        // Settings
        Settings {
            SettingsView()
                .environment(reminderManager)
                .environment(settingsManager)
        }
        .defaultPosition(.center)

        // Launch at login dialog
        Window("Launch at Login", id: "launch-at-login-dialog") {
            LaunchAtLoginDialog { enable, askLater in
                if let onboardingManager {
                    onboardingManager.handleLaunchAtLoginDialogResponse(enable: enable, askLater: askLater)
                    // Close the window after response
                    dismissWindow(id: "launch-at-login-dialog")
                }
            }
        }
        .windowResizability(.contentSize)
        .defaultPosition(.center)
    }
}
