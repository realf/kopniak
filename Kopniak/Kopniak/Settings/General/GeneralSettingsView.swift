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

                    Toggle(
                        "Show menu bar icon",
                        isOn: $store.showMenuBarIcon
                    )

                    Toggle(
                        "Show main window when Kopniak opens",
                        isOn: $store.showMainWindowAtLaunch
                    )
                } header: {
                    Text("Launch Behavior")
                }

                // Icon settings
                Section {
                    Picker(
                        selection: menuIconTimeDisplayBinding,
                        label: Text("Time format")
                    ) {
                        ForEach(TimeDisplaySetting.allCases) { setting in
                            switch setting {
                            case .short:
                                Text("Short")
                            case .positional:
                                Text("Positional")
                            case .none:
                                Text("None")
                            }
                        }
                    }
                } header: {
                    Text("Menu Icon")
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
    let menuIconTimeDisplay = Shared(value: TimeDisplaySetting.short)
    let restartAfterScreenLock = Shared(value: true)
    let store = Store(
        initialState: GeneralSettingsFeature.State(
            reminderInterval: reminderInterval,
            snoozeInterval: snoozeInterval,
            menuIconTimeDisplay: menuIconTimeDisplay,
            restartAfterScreenLock: restartAfterScreenLock,
            showMainWindowAtLaunch: Shared(value: true),
            showMenuBarIcon: Shared(value: false)
        ),
        reducer: {
            GeneralSettingsFeature()
        }
    )
    GeneralSettingsView(store: store)
}
