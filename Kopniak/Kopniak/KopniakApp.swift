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
    @State private var reminderManager = ReminderManager()
    @State private var settingsManager = SettingsManager()
    
    init() {
        // Connect the managers
        reminderManager.settingsManager = settingsManager
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

        // Settings window
        Window("Settings", id: "settings") {
            SettingsView()
                .environment(reminderManager)
                .environment(settingsManager)
        }
        .windowResizability(.contentSize)
        .defaultPosition(.center)
        
        // Status bar menu
        MenuBarExtra {
            StatusBarMenu()
                .environment(reminderManager)
                .environment(settingsManager)
        } label: {
            Image(systemName: reminderManager.isActive ? "chevron.up.2" : "chevron.up.dotted.2")
                .font(.system(size: 14, weight: .medium))
        }
    }
}
