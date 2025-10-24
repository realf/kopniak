//
//  RemindersFeature.swift
//  Sergeant Kopniak
//
//  Created by alf on 23.10.2025.
//

import ComposableArchitecture
import Foundation

nonisolated enum RemindersStatus: Codable {
    case off
    case on
    case paused
}

@Reducer
struct RemindersFeature {
    @Dependency(\.suspendingClock) var clock

    @ObservableState
    struct State {
        static let defaultReminderInterval: TimeInterval = 45.0 * 60
        static let snoozeReminderInterval: TimeInterval = 10.0 * 60

        @Shared var remainingTime: TimeInterval
        @Shared var reminderInterval: TimeInterval
        @Shared var remindersStatus: RemindersStatus

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

            let reminderInterval = Shared(
                wrappedValue: State.defaultReminderInterval,
                .reminderInterval
            )

            _reminderInterval = reminderInterval
        }
    }

    enum Action {
        case delegate(Delegate)
        case menuIconOnAppear
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
        Reduce { state, action in
            switch action {
            case .menuIconOnAppear:
                return restoreTimerState(state)

            case .pauseRemindersTapped:
                return pauseReminders(&state)

            case .reminderDismissTapped:
                return reminderResponse(
                    &state,
                    nextReminderIn: state.reminderInterval
                )

            case .reminderIntervalChanged:
                return restartReminders(&state)

            case .reminderSnoozeTapped:
                return reminderResponse(
                    &state,
                    nextReminderIn: State.snoozeReminderInterval
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

    private func reminderResponse(
        _ state: inout State,
        nextReminderIn remaining: TimeInterval
    ) -> Effect<Action> {
        state.$remainingTime.withLock { $0 = remaining }

        var effects: [Effect<Action>] = [
            .run { send in await send(.delegate(.dismissReminder)) }
        ]
        if state.remindersStatus == .on {
            effects.append(startTimer(state))
        }

        return .merge(effects)
    }

    private func restoreTimerState(_ state: State) -> Effect<Action> {
        if state.remindersStatus == .on {
            if state.remainingTime <= 0 {
                state.$remainingTime.withLock { $0 = state.reminderInterval }
            }
            return startTimer(state)
        }
        return .none
    }

    private func startTimer(_ state: State) -> Effect<Action> {
        return .run { @MainActor [clock] send in
            for await _ in clock.timer(interval: .seconds(1)) {
                send(.timerTicked)
            }
        }
        .cancellable(id: state.timerID)
    }

    private func dismissReminder(_ state: inout State) -> Effect<Action> {
        .run { send in await send(.delegate(.dismissReminder)) }
    }

    private func startReminders(_ state: inout State) -> Effect<Action> {
        guard state.remindersStatus != .on else {
            return .none
        }
        state.$remindersStatus.withLock { $0 = .on }
        state.$remainingTime.withLock { $0 = state.reminderInterval }
        return startTimer(state)
    }

    private func stopReminders(_ state: inout State) -> Effect<Action> {
        state.$remainingTime.withLock { $0 = 0.0 }
        state.$remindersStatus.withLock { $0 = .off }
        return .cancel(id: state.timerID)
    }

    private func pauseReminders(_ state: inout State) -> Effect<Action> {
        state.$remindersStatus.withLock { $0 = .paused }
        return .merge(
            .cancel(id: state.timerID),
            dismissReminder(&state)
        )
    }

    private func restartReminders(_ state: inout State) -> Effect<Action> {
        state.$remindersStatus.withLock { $0 = .on }
        state.$remainingTime.withLock { $0 = state.reminderInterval }
        return .concatenate(
            .cancel(id: state.timerID),
            startTimer(state)
        )
    }

    private func resumeReminders(_ state: inout State) -> Effect<Action> {
        guard state.remindersStatus == .paused else {
            return .none
        }
        state.$remindersStatus.withLock { $0 = .on }
        if state.remainingTime <= 0 {
            state.$remainingTime.withLock { $0 = state.reminderInterval }
        }
        return startTimer(state)
    }

    private func processTimerTick(_ state: inout State) -> Effect<Action> {
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
        return .run { send in await send(.delegate(.showReminder)) }
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
    static var remainingTime: Self {
        .appStorage("remainingTime")
    }
}
