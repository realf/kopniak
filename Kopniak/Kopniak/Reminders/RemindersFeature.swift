//
//  RemindersFeature.swift
//  Sergeant Kopniak
//
//  Created by alf on 23.10.2025.
//

import ComposableArchitecture
import Foundation

enum RemindersStatus: Codable {
    case off
    case on
    case paused
}

enum LockScreenTimerBehavior: Codable, CaseIterable, Identifiable {
    case reset
    case pause
    var title: String {
        switch self {
        case .reset: return String(localized: "Timer Resets")
        case .pause: return String(localized: "Timer Pauses")
        }
    }
    var id: Self { self }
}

@Reducer
struct RemindersFeature {
    @Dependency(\.suspendingClock) var clock

    @ObservableState
    struct State {
        static let defaultReminderInterval: TimeInterval = 30.0 * 60
        static let defaultSnoozeInterval: TimeInterval = 5.0 * 60

        var idleMonitor: IdleMonitorFeature.State
        @Shared var remainingTime: TimeInterval
        @Shared var reminderInterval: TimeInterval
        @Shared var remindersStatus: RemindersStatus
        @Shared var lockScreenTimerBehavior: LockScreenTimerBehavior
        @Shared var snoozeInterval: TimeInterval

        let timerID = UUID()

        init(remindersStatus: @autoclosure () -> RemindersStatus) {
            idleMonitor = IdleMonitorFeature.State()
            let status = Shared<RemindersStatus>(
                wrappedValue: remindersStatus(),
                .remindersStatus
            )
            _remindersStatus = status

            let remainingTime = Shared(value: 0.0)
            _remainingTime = remainingTime

            let reminderInterval = Shared(
                wrappedValue: Self.defaultReminderInterval,
                .reminderInterval
            )

            _reminderInterval = reminderInterval

            _lockScreenTimerBehavior = Shared(
                wrappedValue: .reset,
                .lockScreenTimerBehavior
            )

            let snoozeInterval = Shared(
                wrappedValue: Self.defaultSnoozeInterval,
                .snoozeInterval
            )
            _snoozeInterval = snoozeInterval
        }
    }

    enum Action {
        case appIntent(AppIntentFeature.Action)
        case applicationDidLaunch
        case delegate(Delegate)
        case idleMonitor(IdleMonitorFeature.Action)
        case reminderDismissTapped
        case reminderSnoozeTapped
        case pauseRemindersTapped
        case reminderIntervalChanged
        case restartRemindersTapped
        case resumeRemindersTapped
        case startRemindersTapped
        case stopRemindersTapped
        case timerTicked

        enum Delegate {
            case dismissReminder
            case showReminder
        }
    }

    var body: some Reducer<State, Action> {
        Scope(state: \.idleMonitor, action: \.idleMonitor) {
            IdleMonitorFeature()
        }
        Reduce { state, action in
            switch action {
            case .appIntent(.delegate(let action)):
                return reduceAppIntentDelegate(&state, action: action)

            case .applicationDidLaunch:
                return restoreTimerState(&state)

            case .idleMonitor(.delegate(let delegateAction)):
                return reduceIdleMonitorDelegate(&state, action: delegateAction)

            case .idleMonitor:
                return .none

            case .pauseRemindersTapped:
                return pauseReminders(&state)

            case .reminderDismissTapped:
                return reminderResponse(
                    &state,
                    nextReminderIn: state.reminderInterval
                )

            case .reminderIntervalChanged:
                state.$remainingTime.withLock { $0 = state.reminderInterval }
                return .none

            case .reminderSnoozeTapped:
                return reminderResponse(
                    &state,
                    nextReminderIn: state.snoozeInterval
                )

            case .restartRemindersTapped:
                return .merge(
                    restartReminders(&state),
                    dismissReminder(&state)
                )

            case .resumeRemindersTapped:
                return resumeReminders(&state)

            case .startRemindersTapped:
                return startReminders(&state)

            case .stopRemindersTapped:
                return .merge(
                    stopReminders(&state),
                    dismissReminder(&state)
                )

            case .timerTicked:
                return processTimerTick(&state)

            case .delegate:
                return .none
            }
        }
    }

    private func reduceAppIntentDelegate(
        _ state: inout State,
        action: AppIntentFeature.Action
            .Delegate
    ) -> Effect<Action> {
        switch action {
        case .startReminders:
            return startReminders(&state)
        case .stopReminders:
            return stopReminders(&state)
        case .toggleReminders:
            switch state.remindersStatus {
            case .off:
                return startReminders(&state)
            case .on:
                return pauseReminders(&state)
            case .paused:
                return resumeReminders(&state)
            }
        }
    }

    private func reduceIdleMonitorDelegate(
        _ state: inout State,
        action: IdleMonitorFeature.Action.Delegate
    ) -> Effect<Action> {
        // Only respond to idle events if reminders are actively on
        guard state.remindersStatus == .on else {
            return .none
        }

        // When entering idle state, cancel the reminder timer and dismiss the reminder
        switch action {
        case .screenDidLock, .sessionDidResignActive, .systemWillSleep:
            return .merge(
                cancelTimer(state),
                dismissReminder(&state)
            )

        // When exiting idle state, restart or start the reminder timer
        case .screenDidUnlock, .sessionDidBecomeActive, .systemDidWake:
            switch state.lockScreenTimerBehavior {
            case .reset:
                return restartReminders(&state)
            case .pause:
                return startTimer(&state)
            }
        }
    }

    private func reminderResponse(
        _ state: inout State,
        nextReminderIn remaining: TimeInterval
    ) -> Effect<Action> {
        state.$remainingTime.withLock { $0 = remaining }

        var effects: [Effect<Action>] = [
            .run { send in await send(.delegate(.dismissReminder)) }
        ]
        if state.remindersStatus == .on {
            effects.append(startTimer(&state))
        }

        return .merge(effects)
    }

    private func restoreTimerState(_ state: inout State) -> Effect<Action> {
        if state.remindersStatus == .on {
            if state.remainingTime <= 0 {
                state.$remainingTime.withLock { $0 = state.reminderInterval }
            }
            return startTimer(&state)
        }
        return .none
    }

    private func startReminders(_ state: inout State) -> Effect<Action> {
        guard state.remindersStatus != .on else {
            return .none
        }
        state.$remindersStatus.withLock { $0 = .on }
        state.$remainingTime.withLock { $0 = state.reminderInterval }
        return startTimer(&state)
    }

    private func stopReminders(_ state: inout State) -> Effect<Action> {
        state.$remainingTime.withLock { $0 = 0.0 }
        state.$remindersStatus.withLock { $0 = .off }
        return .merge(
            cancelTimer(state),
            dismissReminder(&state),
            reduce(into: &state, action: .idleMonitor(.stopObserving))
        )
    }

    private func pauseReminders(_ state: inout State) -> Effect<Action> {
        state.$remindersStatus.withLock { $0 = .paused }
        return .merge(
            cancelTimer(state),
            dismissReminder(&state),
            reduce(into: &state, action: .idleMonitor(.stopObserving))
        )
    }

    private func restartReminders(_ state: inout State) -> Effect<Action> {
        state.$remindersStatus.withLock { $0 = .on }
        state.$remainingTime.withLock { $0 = state.reminderInterval }
        return startTimer(&state)
    }

    private func resumeReminders(_ state: inout State) -> Effect<Action> {
        guard state.remindersStatus == .paused else {
            return .none
        }
        state.$remindersStatus.withLock { $0 = .on }
        if state.remainingTime <= 0 {
            state.$remainingTime.withLock { $0 = state.reminderInterval }
        }
        return startTimer(&state)
    }

    private func processTimerTick(_ state: inout State) -> Effect<Action> {
        state.$remainingTime.withLock { $0 -= 1.0 }
        if state.remainingTime <= 0 {
            state.$remainingTime.withLock { $0 = 0.0 }

            return .merge(
                cancelTimer(state),
                showReminder(&state)
            )
        }
        return .none
    }

    private func startTimer(_ state: inout State) -> Effect<Action> {
        return .merge(
            .concatenate(
                cancelTimer(state),
                .run { [clock] send in
                    for await _ in clock.timer(interval: .seconds(1)) {
                        await send(.timerTicked)
                    }
                }.cancellable(id: state.timerID)
            ),
            reduce(into: &state, action: .idleMonitor(.startObserving))
        )
    }

    private func cancelTimer(_ state: State) -> Effect<Action> {
        return .cancel(id: state.timerID)
    }

    private func showReminder(_ state: inout State) -> Effect<Action> {
        return .run { send in await send(.delegate(.showReminder)) }
    }

    private func dismissReminder(_ state: inout State) -> Effect<Action> {
        .run { send in await send(.delegate(.dismissReminder)) }
    }
}

extension SharedReaderKey where Self == AppStorageKey<RemindersStatus> {
    static var remindersStatus: Self {
        .appStorage("remindersStatus")
    }
}

extension SharedReaderKey where Self == AppStorageKey<TimeInterval> {
    static var reminderInterval: Self {
        .appStorage("reminderInterval")
    }
}

extension SharedReaderKey where Self == AppStorageKey<TimeInterval> {
    static var snoozeInterval: Self {
        .appStorage("snoozeInterval")
    }
}

extension SharedReaderKey where Self == AppStorageKey<LockScreenTimerBehavior> {
    static var lockScreenTimerBehavior: Self {
        .appStorage("lockScreenTimerBehavior")
    }
}
