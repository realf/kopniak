//
//  AppFeature.swift
//  Sergeant Kopniak
//
//  Created by alf on 16.10.2025.
//

import AppKit
import ComposableArchitecture
import Foundation

nonisolated enum RemindersStatus: Codable {
    case off
    case on
    case paused
}

/// Type used to display windows in SwiftUI. Set a new value to `openWindowID`
/// to show a window. Even if the `destination` stays the same, `uniqueID` will be
/// different and the window will be activated.
struct WindowID: Equatable {
    let destination: Destination
    let uniqueID = UUID()

    enum Destination: Equatable {
        case settings
        case window(id: String)
    }
}

@Reducer
struct AppFeature {
    @Dependency(\.suspendingClock) var clock

    @ObservableState
    struct State {
        static let defaultReminderInterval: TimeInterval = 45.0 * 60

        var menuIcon: AppMenuIconFeature.State
        var remainingTime: TimeInterval = 0
        @Shared var reminderInterval: TimeInterval
        @Shared var remindersStatus: RemindersStatus
        var settings: SettingsFeature.State
        @Shared var showMissionBriefingAtLaunch: Bool

        let timerID = UUID()

        init(remindersStatus: @autoclosure () -> RemindersStatus) {
            let status = Shared<RemindersStatus>(
                wrappedValue: remindersStatus(),
                .remindersStatus
            )
            _remindersStatus = status
            menuIcon = AppMenuIconFeature.State(remindersStatus: status)

            let showMissionBriefingAtLaunch = Shared(
                wrappedValue: true,
                .appStorage("ShowMissionBriefingAtLaunch")
            )

            _showMissionBriefingAtLaunch = showMissionBriefingAtLaunch

            let reminderInterval = Shared(
                wrappedValue: State.defaultReminderInterval,
                .reminderInterval
            )

            _reminderInterval = reminderInterval

            settings = SettingsFeature.State(
                reminderInterval: reminderInterval,
                showMissionBriefingAtLaunch: showMissionBriefingAtLaunch
            )
        }
    }

    enum Action {
        case menuIcon(AppMenuIconFeature.Action)
        case missionBriefingTapped
        case pauseRemindersTapped
        case restartRemindersTapped
        case resumeRemindersTapped
        case settings(SettingsFeature.Action)
        case settingsTapped
        case startRemindersTapped
        case stopRemindersTapped
        case timerTicked
        case quitTapped
    }

    var body: some Reducer<State, Action> {
        Scope(state: \.menuIcon, action: \.menuIcon) {
            AppMenuIconFeature()
        }

        Scope(state: \.settings, action: \.settings) {
            SettingsFeature()
        }

        Reduce { state, action in
            switch action {
            case .menuIcon(.delegate(.onAppear)):
                return handleMenuIconOnAppear(&state)

            case .menuIcon:
                return .none

            case .pauseRemindersTapped:
                state.$remindersStatus.withLock { $0 = .paused }
                return .cancel(id: state.timerID)

            case .restartRemindersTapped:
                return restartReminders(&state)

            case .resumeRemindersTapped:
                return resumeReminders(&state)

            case .missionBriefingTapped:
                return showMissionBriefing(&state)

            case .settings(.delegate(.reminderIntervalChanged)):
                return restartReminders(&state)

            case .settings:
                return .none

            case .settingsTapped:
                let window = WindowID(destination: .settings)
                return reduce(
                    into: &state,
                    action: .menuIcon(.openWindow(window))
                )

            case .startRemindersTapped:
                return startReminders(&state)

            case .stopRemindersTapped:
                return stopReminders(&state)

            case .timerTicked:
                return processTimerTick(&state)

            case .quitTapped:
                return .run { send in
                    await NSApplication.shared.terminate(nil)
                }
            }
        }
    }

    private func handleMenuIconOnAppear(_ state: inout AppFeature.State)
        -> Effect<
            AppFeature.Action
        >
    {
        var effects: [Effect<Action>] = []
        if state.showMissionBriefingAtLaunch {
            effects.append(showMissionBriefing(&state))
        }
        if state.remindersStatus == .on {
            if state.remainingTime <= 0 {
                state.remainingTime = state.reminderInterval
            }
            effects.append(makeStartTimerEffect(state))
        }
        return .merge(effects)
    }

    private func showMissionBriefing(_ state: inout State) -> Effect<Action> {
        let window = WindowID(destination: .window(id: "main"))
        return reduce(into: &state, action: .menuIcon(.openWindow(window)))
    }

    private func makeStartTimerEffect(_ state: AppFeature.State) -> Effect<
        AppFeature.Action
    > {
        return .run { @MainActor [clock] send in
            for await _ in clock.timer(interval: .seconds(1)) {
                send(.timerTicked)
            }
        }
        .cancellable(id: state.timerID)
    }

    private func startReminders(_ state: inout AppFeature.State) -> Effect<
        AppFeature.Action
    > {
        guard state.remindersStatus != .on else {
            return .none
        }
        state.$remindersStatus.withLock { $0 = .on }
        state.remainingTime = state.reminderInterval
        return makeStartTimerEffect(state)
    }

    private func stopReminders(_ state: inout AppFeature.State) -> Effect<
        AppFeature.Action
    > {
        state.remainingTime = 0.0
        state.$remindersStatus.withLock { $0 = .off }
        return .cancel(id: state.timerID)
    }

    private func restartReminders(_ state: inout AppFeature.State)
        -> Effect<AppFeature.Action>
    {
        state.$remindersStatus.withLock { $0 = .on }
        state.remainingTime = state.reminderInterval
        return .concatenate(
            .cancel(id: state.timerID),
            makeStartTimerEffect(state)
        )
    }

    private func resumeReminders(_ state: inout AppFeature.State)
        -> Effect<AppFeature.Action>
    {
        guard state.remindersStatus == .paused else {
            return .none
        }
        state.$remindersStatus.withLock { $0 = .on }
        if state.remainingTime <= 0 {
            state.remainingTime = state.reminderInterval
        }
        return makeStartTimerEffect(state)
    }

    private func processTimerTick(_ state: inout AppFeature.State)
        -> Effect<AppFeature.Action>
    {
        state.remainingTime -= 1.0
        if state.remainingTime <= 0 {
            state.remainingTime = 0

            return .concatenate(
                .cancel(id: state.timerID),
                .run { _ in
                    print("show reminder")
                    // TODO: Show reminder
                }
            )
        }
        return .none
    }
}

extension SharedReaderKey where Self == AppStorageKey<RemindersStatus> {
    static var remindersStatus: Self {
        .appStorage("RemindersStatus")
    }
}

extension SharedReaderKey where Self == AppStorageKey<TimeInterval> {
    static var reminderInterval: Self {
        .appStorage("ReminderInterval")
    }
}
