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
                // Reminder settings
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
                                Text("Break interval")
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
                    Toggle(
                        "Reset timer after Lock Screen",
                        isOn: $store.restartAfterScreenLock
                    )
                } header: {
                    Text("Schedule")
                }

                // Launch settings
                Section {
                    Toggle(
                        "Open Kopniak at login",
                        isOn: $store.launchAtLogin
                    )
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
    let reminderInterval = Shared(value: 25.0 * 60)
    let snoozeInterval = Shared(value: 10.0 * 60)
    let restartAfterScreenLock = Shared(value: true)
    let store = Store(
        initialState: GeneralSettingsFeature.State(
            reminderInterval: reminderInterval,
            snoozeInterval: snoozeInterval,
            restartAfterScreenLock: restartAfterScreenLock
        ),
        reducer: {
            GeneralSettingsFeature()
        }
    )
    GeneralSettingsView(store: store)
}
