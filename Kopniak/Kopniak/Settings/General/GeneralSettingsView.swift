//
//  GeneralSettingsView.swift
//  Sergeant Kopniak
//
//  Created by alf on 05.11.2025.
//

import ComposableArchitecture
import ServiceManagement
import SwiftUI

struct GeneralSettingsView: View {
    @Bindable var store: StoreOf<GeneralSettingsFeature>

    var body: some View {
        let reminderIntervalBinding = Binding(
            get: { store.reminderInterval },
            set: { newValue in store.reminderInterval = newValue.rounded() }
        )

        let snoozeIntervalBinding = Binding(
            get: { store.snoozeInterval },
            set: { newValue in store.snoozeInterval = newValue.rounded() }
        )

        let menuIconTimeDisplayBinding = Binding(
            get: { store.menuIconTimeDisplay },
            set: { newValue in store.menuIconTimeDisplay = newValue }
        )

        HStack {
            Spacer()
            Form {
                // Reminder settings
                Section {
                    Slider(
                        value: reminderIntervalBinding,
                        in: store.reminderIntervalRange,
                        step: store.reminderIntervalStep,
                        minimumValueLabel: Text(
                            store.minReminderIntervalFormatted
                        ),
                        maximumValueLabel: Text(
                            store.maxReminderIntervalFormatted
                        ),
                        label: {
                            Text(
                                "Break Interval: \(store.reminderIntervalFormatted)"
                            )
                        }
                    )

                    Slider(
                        value: snoozeIntervalBinding,
                        in: store.snoozeIntervalRange,
                        step: store.snoozeIntervalStep,
                        minimumValueLabel: Text(
                            store.minSnoozeIntervalFormatted
                        ),
                        maximumValueLabel: Text(
                            store.maxSnoozeIntervalFormatted
                        ),
                        label: {
                            Text(
                                "Snooze Interval: \(store.snoozeIntervalFormatted)"
                            )
                        }
                    )
                } header: {
                    Text("Exercise Drill Schedule")
                }

                // Launch settings
                Section {
                    Toggle(
                        "Start Kopniak at login",
                        isOn: $store.launchAtLogin
                    )

                    Toggle(
                        "Show briefing on startup",
                        isOn: $store.showMissionBriefingAtLaunch
                    )
                } header: {
                    Text("Launch Behavior")
                }

                // Icon settings
                Section {
                    Picker(
                        selection: menuIconTimeDisplayBinding,
                        label: Text("Remaining Time Format")
                    ) {
                        ForEach(TimeDisplaySetting.allCases) { setting in
                            Text(setting.rawValue.capitalized)
                        }
                    }
                } header: {
                    Text("Menu Icon Settings")
                }
            }
            .formStyle(.grouped)
            Spacer()
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}

#Preview {
    let reminderInterval = Shared(value: 25.0 * 60)
    let snoozeInterval = Shared(value: 10.0 * 60)
    let menuIconTimeDisplay = Shared(value: TimeDisplaySetting.abbreviated)
    let store = Store(
        initialState: GeneralSettingsFeature.State(
            reminderInterval: reminderInterval,
            snoozeInterval: snoozeInterval,
            menuIconTimeDisplay: menuIconTimeDisplay
        ),
        reducer: {
            GeneralSettingsFeature()
        }
    )
    GeneralSettingsView(store: store)
}
