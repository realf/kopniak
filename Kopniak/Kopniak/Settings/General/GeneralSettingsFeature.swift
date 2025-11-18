//
//  GeneralSettingsFeature.swift
//  Sergeant Kopniak
//
//  Created by alf on 23.10.2025.
//

import ComposableArchitecture
import ServiceManagement

enum TimeDisplaySetting: String, CaseIterable, Identifiable {
    case abbreviated
    case positional
    case none

    var id: Self { self }
}

@Reducer
struct GeneralSettingsFeature {
    @Dependency(\.smAppService) var smAppService

    @ObservableState
    struct State {
        var launchAtLogin: Bool = false
        static let intervalFormatter = {
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.minute, .second]
            formatter.unitsStyle = .full
            return formatter
        }()

        static let rangeBoundFormatter = {
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.minute, .second]
            formatter.unitsStyle = .short
            return formatter
        }()

        @Shared var menuIconTimeDisplay: TimeDisplaySetting
        @Shared var restartAfterScreenLock: Bool
        @Shared var reminderInterval: TimeInterval
        @Shared var showMissionBriefingAtLaunch: Bool
        @Shared var snoozeInterval: TimeInterval

        var reminderIntervalFormatted: String {
            return Self.intervalFormatter.string(from: reminderInterval)
                ?? "0 minutes"
        }

        var snoozeIntervalFormatted: String {
            return Self.intervalFormatter.string(from: snoozeInterval)
                ?? "0 minutes"
        }

        var minReminderIntervalFormatted: String {
            return Self.rangeBoundFormatter.string(
                from: reminderIntervalRange.lowerBound
            ) ?? "0 minutes"
        }

        var maxReminderIntervalFormatted: String {
            return Self.rangeBoundFormatter.string(
                from: reminderIntervalRange.upperBound
            ) ?? "0 minutes"
        }

        var minSnoozeIntervalFormatted: String {
            return Self.rangeBoundFormatter.string(
                from: snoozeIntervalRange.lowerBound
            ) ?? "0 minutes"
        }

        var maxSnoozeIntervalFormatted: String {
            return Self.rangeBoundFormatter.string(
                from: snoozeIntervalRange.upperBound
            ) ?? "0 minutes"
        }

        // MARK: - Constants

        let reminderIntervalRange = 15.0...120.0
        let reminderIntervalStep = 5.0
        let snoozeIntervalRange = 5.0...15.0
        let snoozeIntervalStep = 5.0

        init(
            reminderInterval: Shared<TimeInterval>,
            snoozeInterval: Shared<TimeInterval>,
            menuIconTimeDisplay: Shared<TimeDisplaySetting>,
            restartAfterScreenLock: Shared<Bool>
        ) {
            _reminderInterval = reminderInterval
            let showMissionBriefingAtLaunch = Shared(
                wrappedValue: true,
                .appStorage("showMissionBriefingAtLaunch")
            )
            _showMissionBriefingAtLaunch = showMissionBriefingAtLaunch
            _snoozeInterval = snoozeInterval
            _menuIconTimeDisplay = menuIconTimeDisplay
            _restartAfterScreenLock = restartAfterScreenLock
        }
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
