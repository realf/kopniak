//
//  SettingsView.swift
//  Sergeant Kopniak
//
//  Created by alf on 02.10.2025.
//

import ComposableArchitecture
import ServiceManagement
import SwiftUI

struct SettingsView: View {
    @Bindable var store: StoreOf<SettingsFeature>

    var body: some View {
        VStack(spacing: 20.0) {
            Image(systemName: "gear")
                .imageScale(.large)
                .foregroundStyle(.brown)
                .font(.largeTitle)

            // Title
            Text("MISSION SETTINGS")
                .font(.title2)
                .fontWeight(.bold)

            Form {
                // Reminder Interval Section
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Break Interval:")
                            Spacer()
                            Text(
                                "\(Int((store.reminderInterval / 60.0).rounded())) minutes"
                            )
                            .foregroundColor(.secondary)
                        }

                        Slider(
                            value: Binding(
                                get: {
                                    Double(store.reminderInterval / 60.0)
                                },
                                set: { newValue in
                                    store.reminderInterval =
                                        (newValue * 60.0).rounded()
                                }
                            ),
                            in: store.intervalRange,
                            step: store.intervalStep
                        )

                        HStack {
                            Text("\(Int(store.intervalRange.lowerBound)) min")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(Int(store.intervalRange.upperBound)) min")
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
                    Toggle(
                        "Start Kopniak at login",
                        isOn: $store.launchAtLogin
                    )

                    Toggle(
                        "Show briefing on startup",
                        isOn: $store.showMissionBriefingAtLaunch
                    )
                } header: {
                    Label("Launch Behavior", systemImage: "macwindow")
                        .font(.headline)
                }
            }
            .formStyle(.grouped)
        }
        .padding()
        .frame(width: 500, height: 420)
        .onAppear {
            store.send(.onAppear)
        }
    }
}

#Preview {
    let reminderInterval = Shared(value: 25.0 * 60)
    let store = Store(
        initialState: SettingsFeature.State(
            reminderInterval: reminderInterval
        ),
        reducer: {
            SettingsFeature()
        }
    )
    SettingsView(store: store)
}
