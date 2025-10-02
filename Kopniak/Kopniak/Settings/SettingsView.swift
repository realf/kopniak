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

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack {
                Image(systemName: "gearshape.fill")
                    .font(.title2)
                    .foregroundColor(.secondary)
                Text("Mission Settings")
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            .padding(.bottom, 10)

            let minIntervalMinutes = 15
            let maxIntervalMinutes = 120
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
                                    let newInterval = Int(newValue.rounded())
                                    settingsManager.reminderIntervalMinutes = newInterval
                                    // If reminders are active, restart them with new interval
                                    if reminderManager.isActive {
                                        reminderManager.stopReminders()
                                        reminderManager.startReminders()
                                    }
                                }
                            ),
                            in: Double(
                                minIntervalMinutes
                            )...Double(maxIntervalMinutes),
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
                } header: {
                    Label("Launch Behavior", systemImage: "macwindow")
                        .font(.headline)
                }
            }
            .formStyle(.grouped)
        }
        .padding(20)
        .frame(width: 450, height: 400)
    }
}

#Preview {
    SettingsView()
        .environment(SettingsManager())
        .environment(ReminderManager())
}
