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

    // MARK: - Constants

    #if DEBUG
        private let intervalRange = 0.1...1.0
        private let intervalStep = 0.1
    #else
        private let intervalRange = 15.0...120.0
        private let intervalStep = 5.0
    #endif

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
                            in: intervalRange,
                            step: intervalStep
                        )

                        HStack {
                            Text("\(Int(intervalRange.lowerBound)) min")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(Int(intervalRange.upperBound)) min")
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
                        "Launch Kopniak at login",
                        isOn: $store.launchAtLogin
                    )

                    Toggle(
                        "Show Mission Briefing when app launches",
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
        .frame(width: 500)
        .onAppear {
            store.send(.onAppear)
        }
    }
}

#Preview {
    let reminderInterval = Shared(value: 45.0 * 60)
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
