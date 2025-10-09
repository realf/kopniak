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
    @Environment(\.openSettings) private var openSettings

    var body: some View {
        VStack(spacing: 0) {
            Button {
                // Activate the app and show the window
                openWindow(id: "main")
                NSApp.activate(ignoringOtherApps: true)
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
                
                if reminderManager.canPause {
                    Button {
                        reminderManager.pauseReminders()
                    } label: {
                        HStack {
                            Image(systemName: "pause.fill")
                            Text("At Ease")
                        }
                    }
                    .keyboardShortcut("p", modifiers: .command)
                }
            } else if reminderManager.canResume {
                Button {
                    reminderManager.resumeReminders()
                } label: {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Resume Duty")
                    }
                }
                .keyboardShortcut("r", modifiers: .command)
                
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

            Button {
                openSettings()
                NSApp.activate(ignoringOtherApps: true)
            } label: {
                HStack {
                    Image(systemName: "gear")
                    Text("Settings...")
                }
            }
            .keyboardShortcut(",", modifiers: .command)

            Divider()
            
            Button("Quit Sergeant Kopniak") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q", modifiers: .command)
        }
    }
}

#Preview {
    let settingsManager = SettingsManager()
    StatusBarMenu()
        .environment(ReminderManager(settingsManager: settingsManager))
}
