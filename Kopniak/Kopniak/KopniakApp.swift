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
    
    init() {
        // Initialize reminder manager with settings manager dependency
        let settings = SettingsManager()
        let reminders = ReminderManager(settingsManager: settings)
        
        self._settingsManager = State(wrappedValue: settings)
        self._reminderManager = State(wrappedValue: reminders)
    }

    var body: some Scene {
        // Main app window
        Window("Sergeant Kopniak", id: "main") {
            ContentView()
                .environment(reminderManager)
                .environment(settingsManager)
        }
        .defaultSize(width: 400, height: 500)
        .windowResizability(.contentSize)
        .defaultLaunchBehavior(settingsManager.showMainWindowOnLaunch ? .presented : .suppressed)

        // Status bar menu
        MenuBarExtra {
            StatusBarMenu()
                .environment(reminderManager)
                .environment(settingsManager)
        } label: {
            Image(systemName: reminderManager.isActive ? "chevron.up.2" : "chevron.up.dotted.2")
        }

        // Settings
        Settings {
            SettingsView()
                .environment(reminderManager)
                .environment(settingsManager)
        }
    }
}
