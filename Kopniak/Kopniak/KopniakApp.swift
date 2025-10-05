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
    @State private var settingsManager: SettingsManager
    @State private var reminderManager: ReminderManager
    @State private var onboardingManager: OnboardingManager?
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    
    private var menuBarIcon: String {
        if reminderManager.isActive {
            return "chevron.up.2"
        } else {
            return "chevron.up.dotted.2"
        }
    }

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
        .defaultLaunchBehavior(settingsManager.showMainWindowOnLaunch ? .presented : .suppressed)

        // Status bar menu
        MenuBarExtra {
            StatusBarMenu()
            .environment(reminderManager)
            .environment(settingsManager)
        } label: {
            Image(systemName: menuBarIcon)
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
            LaunchAtLoginDialog { response in
                if let onboardingManager {
                    onboardingManager.handleLaunchAtLoginDialogResponse(response)
                    // Close the window after response
                    dismissWindow(id: "launch-at-login-dialog")
                }
            }
        }
        .windowResizability(.contentSize)
        .defaultPosition(.center)
    }
}
