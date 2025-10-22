//
//  SettingsView.swift
//  Sergeant Kopniak
//
//  Created by alf on 02.10.2025.
//

import ComposableArchitecture
import ServiceManagement
import SwiftUI

@Reducer
struct SettingsFeature {
    @Dependency(\.smAppService) var smAppService

    @ObservableState
    struct State {
        var launchAtLogin: Bool = false
        @Shared var reminderInterval: TimeInterval
        @Shared var showMissionBriefingAtLaunch: Bool
    }

    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case delegate(Delegate)
        case onAppear
        case updateLaunchAtLogin(Bool)

        enum Delegate {
            case reminderIntervalChanged
        }
    }

    var body: some Reducer<State, Action> {
        BindingReducer()
            .onChange(of: \.reminderInterval) { _, _ in
                Reduce { state, action in
                    .run { send in
                        await send(.delegate(.reminderIntervalChanged))
                    }
                }
            }
            .onChange(of: \.launchAtLogin) { _, enabled in
                Reduce { state, action in
                    .run { send in
                        await updateLaunchAtLogin(enabled: enabled, send: send)
                    }
                }
            }

        Reduce { state, action in
            switch action {
            case .binding, .delegate:
                return .none

            case .onAppear:
                // Initialize launch at login state from system
                state.launchAtLogin = smAppService.isEnabled()
                return .none
                
            case .updateLaunchAtLogin(let enabled):
                state.launchAtLogin = enabled
                return .none
            }
        }
    }

    // MARK: - Launch at Login Implementation
    private nonisolated func updateLaunchAtLogin(
        enabled: Bool,
        send: Send<Action>
    ) async {
        do {
            if enabled {
                try await smAppService.register()
            } else {
                try await smAppService.unregister()
            }

            // Update cached state after successful operation
            await send(.updateLaunchAtLogin(enabled))
        } catch {
            NSLog(
                "Failed to \(enabled ? "enable" : "disable") launch at login: \(error)"
            )

            // Revert cached state on failure and refresh UI
            let isEnabled = await smAppService.isEnabled()
            await send(.updateLaunchAtLogin(isEnabled))
        }
    }
}

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
                        "Launch Sergeant Kopniak at login",
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

// MARK: - SMAppService dependency.
nonisolated struct SMAppServiceDependency {
    var register: () throws -> Void
    var unregister: () async throws -> Void
    var isEnabled: () -> Bool
}

// Conform to DependencyKey to provide a live and preview implementation of the interface.
extension SMAppServiceDependency: DependencyKey {
    static let liveValue = Self {
        try SMAppService.mainApp.register()
    } unregister: {
        try await SMAppService.mainApp.unregister()
    } isEnabled: {
        SMAppService.mainApp.status == .enabled
    }

    static let previewValue = Self(
        register: {
            print("register")
        },
        unregister: {
            print("unregister")
        },
        isEnabled: {
            true
        }
    )
}

// Register the dependency within DependencyValues.
extension DependencyValues {
    var smAppService: SMAppServiceDependency {
        get { self[SMAppServiceDependency.self] }
        set { self[SMAppServiceDependency.self] = newValue }
    }
}

#Preview {
    let showMissionBriefingAtLaunch = Shared(value: true)
    let reminderInterval = Shared(value: 45.0 * 60)
    let store = Store(
        initialState: SettingsFeature.State(
            reminderInterval: reminderInterval,
            showMissionBriefingAtLaunch: showMissionBriefingAtLaunch
        ),
        reducer: {
            SettingsFeature()
        }
    )
    SettingsView(store: store)
}
