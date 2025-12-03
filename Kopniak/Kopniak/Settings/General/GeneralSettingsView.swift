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

        HStack {
            Spacer()
            Form {
                Section {
                    VStack {
                        Text("\(store.reminderIntervalFormatted)")
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
                                Text("Break reminder interval")
                            }
                        )
                    }

                    VStack {
                        Text("\(store.snoozeIntervalFormatted)")
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
                                Text("Snooze duration")
                            }
                        )
                    }
                } header: {
                    Text("Break Reminders")
                }

                Section {
                    Toggle(
                        "Open Kopniak at login",
                        isOn: $store.launchAtLogin
                    )

                    Toggle(
                        "Show main window when Kopniak opens",
                        isOn: $store.showMainWindowAtLaunch
                    )

                    Picker("During the lock screen", selection: $store.lockScreenTimerBehavior) {
                        ForEach(LockScreenTimerBehavior.allCases) { option in
                            Text(option.title)
                        }
                    }
                } header: {
                    Text("App Behavior")
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
    let lockScreenTimerBehavior = Shared(value: LockScreenTimerBehavior.reset)
    let reminderInterval = Shared(value: 25.0 * 60)
    let snoozeInterval = Shared(value: 10.0 * 60)
    let showMainWindowAtLaunch = Shared(value: true)
    let store = Store(
        initialState: GeneralSettingsFeature.State(
            lockScreenTimerBehavior: lockScreenTimerBehavior,
            reminderInterval: reminderInterval,
            showMainWindowAtLaunch: showMainWindowAtLaunch,
            snoozeInterval: snoozeInterval
        ),
        reducer: {
            GeneralSettingsFeature()
        }
    )
    GeneralSettingsView(store: store)
}
