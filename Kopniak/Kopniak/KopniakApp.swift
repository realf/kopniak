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

    var body: some Scene {
        // Main app window
        Window("Sergeant Kopniak", id: "main") {
            ContentView()
                .environment(reminderManager)
        }
        .defaultSize(width: 400, height: 500)
        .windowResizability(.contentSize)
        
        // Status bar menu
        MenuBarExtra {
            StatusBarMenu()
                .environment(reminderManager)
        } label: {
            Image(systemName: reminderManager.areRemindersRunning ? "chevron.up.2" : "chevron.up.dotted.2")
                .font(.system(size: 14, weight: .medium))
        }
    }
}
