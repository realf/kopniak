//
//  SettingsView.swift
//  Sergeant Kopniak
//
//  Created by alf on 02.10.2025.
//

import AppKit
import SwiftUI

struct SettingsView: View {
    @Environment(SettingsManager.self) private var settingsManager
    @Environment(ReminderManager.self) private var reminderManager

    // MARK: - Constants

    private let minIntervalMinutes = 15
    private let maxIntervalMinutes = 120

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack {
                Image(systemName: "gear")
                    .font(.title2)
                    .foregroundColor(.secondary)
                Text("Mission Settings")
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            .padding(.bottom, 10)

            Form {
                // Reminder Interval Section
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Reminder Interval:")
                            Spacer()
                            Text(
                                "\(settingsManager.reminderIntervalMinutes) minutes"
                            )
                            .foregroundColor(.secondary)
                        }

                        Slider(
                            value: Binding(
                                get: { Double(settingsManager.reminderIntervalMinutes) },
                                set: { newValue in
                                    settingsManager.reminderIntervalMinutes = Int(newValue.rounded())
                                    // If reminders are active, restart them with new interval
                                    if reminderManager.isActive {
                                        reminderManager.stopReminders()
                                        reminderManager.startReminders()
                                    }
                                }
                            ),
                            in: Double(minIntervalMinutes)...Double(maxIntervalMinutes),
                            step: 5
                        )

                        HStack {
                            Text("\(minIntervalMinutes) min")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(maxIntervalMinutes) min")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Label("Exercise Drill Schedule", systemImage: "clock")
                        .font(.headline)
                }

                // Launch Behavior Section
                Section {
                    @Bindable var settingsManager = settingsManager
                    Toggle(
                        "Show main window when app launches",
                        isOn: $settingsManager.showMainWindowOnLaunch
                    )

                    Toggle(
                        "Launch Sergeant Kopniak at login",
                        isOn: $settingsManager.launchAtLogin
                    )
                } header: {
                    Label("Launch Behavior", systemImage: "macwindow")
                        .font(.headline)
                }
            }
            .formStyle(.grouped)
        }
        .padding(20)
        .frame(width: 450, height: 450)
    }
}

#Preview {
    let settingsManager = SettingsManager()
    SettingsView()
        .environment(settingsManager)
        .environment(ReminderManager(settingsManager: settingsManager))
}
