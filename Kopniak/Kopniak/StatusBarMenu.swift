//
//  StatusBarMenu.swift
//  Sergeant Kopniak
//
//  Created by alf on 02.10.2025.
//

import SwiftUI

struct StatusBarMenu: View {
    @Environment(ReminderManager.self) private var reminderManager
    @Environment(\.openWindow) private var openWindow
    
    var body: some View {
        VStack(spacing: 0) {
            Button() {
                // Activate the app and show the window
                NSApplication.shared.activate(ignoringOtherApps: true)
                openWindow(id: "main")
            } label: {
                HStack {
                    Image(systemName: "chevron.up.2")
                    Text("Mission Briefing")
                }
            }
            .keyboardShortcut("b", modifiers: .command)
            
            Divider()
            
            if reminderManager.isActive {
                Button {
                    reminderManager.stopReminders()
                } label: {
                    HStack {
                        Image(systemName: "stop.fill")
                        Text("Stand Down")
                    }
                }
                .keyboardShortcut("s", modifiers: .command)
            } else {
                Button {
                    reminderManager.startReminders()
                } label: {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Report for Duty")
                    }
                }
                .keyboardShortcut("r", modifiers: .command)
            }

            Divider()

            SettingsLink()
            
            Divider()
            
            Button("Quit Sergeant Kopniak") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q", modifiers: .command)
        }
    }
}

#Preview {
    StatusBarMenu()
        .environment(ReminderManager())
}
