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
        case reminder
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
        static let snoozeReminderInterval: TimeInterval = 10.0 * 60

        var briefing: BriefingFeature.State
        var menuIcon: AppMenuIconFeature.State
        @Shared var remainingTime: TimeInterval
        var reminder: ReminderFeature.State
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

            let remainingTime = Shared(
                wrappedValue: 0.0,
                .remainingTime
            )
            _remainingTime = remainingTime

            menuIcon = AppMenuIconFeature.State(remindersStatus: status, remainingTime: remainingTime)
            reminder = ReminderFeature.State(title: "", message: "")

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

            briefing = BriefingFeature.State(
                reminderInterval: reminderInterval,
                remindersStatus: status
            )
        }
    }

    enum Action {
        case briefing(BriefingFeature.Action)
        case menuIcon(AppMenuIconFeature.Action)
        case missionBriefingTapped
        case pauseRemindersTapped
        case reminder(ReminderFeature.Action)
        case restartRemindersTapped
        case resumeRemindersTapped
        case settings(SettingsFeature.Action)
        case settingsTapped
        #if DEBUG
            case testReminderTapped
        #endif
        case startRemindersTapped
        case stopRemindersTapped
        case timerTicked
        case quitTapped
    }

    var body: some Reducer<State, Action> {
        Scope(state: \.briefing, action: \.briefing) {
            BriefingFeature()
        }

        Scope(state: \.menuIcon, action: \.menuIcon) {
            AppMenuIconFeature()
        }

        Scope(state: \.reminder, action: \.reminder) {
            ReminderFeature()
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

            case .missionBriefingTapped:
                let window = WindowID(destination: .window(id: "briefing"))
                return showWindow(&state, window: window)

            case .reminder(.delegate(.dismissTapped)):
                state.$remainingTime.withLock { $0 = state.reminderInterval }
                return .merge(
                    dismissWindow(
                        &state,
                        window: WindowID(destination: .reminder)
                    ),
                    startTimer(state)
                )

            case .reminder(.delegate(.snoozeTapped)):
                state.$remainingTime.withLock { $0 = State.snoozeReminderInterval }
                return .merge(
                    dismissWindow(
                        &state,
                        window: WindowID(destination: .reminder)
                    ),
                    startTimer(state)
                )

            case .reminder:
                return .none

            case .pauseRemindersTapped, .briefing(.delegate(.pauseRemindersTapped)):
                state.$remindersStatus.withLock { $0 = .paused }
                return .cancel(id: state.timerID)

            case .restartRemindersTapped, .briefing(.delegate(.restartRemindersTapped)):
                return restartReminders(&state)

            case .resumeRemindersTapped, .briefing(.delegate(.resumeRemindersTapped)):
                return resumeReminders(&state)

            case .settings(.delegate(.reminderIntervalChanged)):
                return restartReminders(&state)

            case .settings:
                return .none

            case .settingsTapped:
                let window = WindowID(destination: .settings)
                return showWindow(&state, window: window)

            case .startRemindersTapped, .briefing(.delegate(.startRemindersTapped)):
                return startReminders(&state)

            case .stopRemindersTapped, .briefing(.delegate(.stopRemindersTapped)):
                return .merge(
                    stopReminders(&state),
                    dismissWindow(
                        &state,
                        window: WindowID(destination: .reminder)
                    )
                )

            #if DEBUG
                case .testReminderTapped:
                    let window = WindowID(destination: .reminder)
                    return showWindow(&state, window: window)
            #endif

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
        -> Effect<AppFeature.Action>
    {
        var effects: [Effect<Action>] = []

        if state.showMissionBriefingAtLaunch {
            let window = WindowID(destination: .window(id: "briefing"))
            effects.append(showWindow(&state, window: window))
        }

        if state.remindersStatus == .on {
            if state.remainingTime <= 0 {
                state.$remainingTime.withLock { $0 = state.reminderInterval }
            }
            effects.append(startTimer(state))
        }

        return .merge(effects)
    }

    private func startTimer(_ state: AppFeature.State) -> Effect<
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
        state.$remainingTime.withLock { $0 = state.reminderInterval }
        return startTimer(state)
    }

    private func stopReminders(_ state: inout AppFeature.State) -> Effect<
        AppFeature.Action
    > {
        state.$remainingTime.withLock { $0 = 0.0 }
        state.$remindersStatus.withLock { $0 = .off }
        return .cancel(id: state.timerID)
    }

    private func restartReminders(_ state: inout AppFeature.State)
        -> Effect<AppFeature.Action>
    {
        state.$remindersStatus.withLock { $0 = .on }
        state.$remainingTime.withLock { $0 = state.reminderInterval }
        return .concatenate(
            .cancel(id: state.timerID),
            startTimer(state)
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
            state.$remainingTime.withLock { $0 = state.reminderInterval }
        }
        return startTimer(state)
    }

    private func processTimerTick(_ state: inout AppFeature.State)
        -> Effect<AppFeature.Action>
    {
        state.$remainingTime.withLock { $0 -= 1.0 }
        if state.remainingTime <= 0 {
            state.$remainingTime.withLock { $0 = 0.0 }

            return .merge(
                .cancel(id: state.timerID),
                showWindow(&state, window: WindowID(destination: .reminder))
            )
        }
        return .none
    }

    private func showWindow(_ state: inout State, window: WindowID) -> Effect<
        Action
    > {
        return reduce(into: &state, action: .menuIcon(.openWindow(window)))
    }

    private func dismissWindow(_ state: inout State, window: WindowID)
        -> Effect<Action>
    {
        return reduce(into: &state, action: .menuIcon(.dismissWindow(window)))
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

extension SharedReaderKey where Self == AppStorageKey<TimeInterval> {
    static var remainingTime: Self {
        .appStorage("RemainingTimeInterval")
    }
}
