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
        let binding = Binding(
            get: { Double(store.reminderInterval / 60.0) },
            set: { newValue in
                store.reminderInterval = (newValue * 60.0)
                    .rounded()
            }
        )
        HStack {
            Spacer()
            Form {
                // Reminder settings
                Section {
                    Slider(
                        value: binding,
                        in: store.intervalRange,
                        step: store.intervalStep,
                        minimumValueLabel: Text(
                            "\(Int(store.intervalRange.lowerBound)) min"
                        ),
                        maximumValueLabel: Text(
                            "\(Int(store.intervalRange.upperBound)) min"
                        ),
                        label: {
                            Text(
                                "Break Interval: \(Int((store.reminderInterval / 60.0).rounded())) minutes"
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
    let store = Store(
        initialState: GeneralSettingsFeature.State(
            reminderInterval: reminderInterval
        ),
        reducer: {
            GeneralSettingsFeature()
        }
    )
    GeneralSettingsView(store: store)
}
