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

extension SharedReaderKey where Self == AppStorageKey<RemindersStatus> {
    static var remindersStatus: Self {
        .appStorage("RemindersStatus")
    }
}

extension SharedReaderKey where Self == AppStorageKey<TimeInterval> {
    static var defaultReminderInterval: Self {
        .appStorage("RemindersDefaultIntervalSeconds")
    }
}

@Reducer
struct AppFeature {
    @Dependency(\.continuousClock) var clock

    @ObservableState
    struct State {
        @Shared(.defaultReminderInterval)
        var defaultReminderInterval: TimeInterval = 45.0

        var menuIcon: AppMenuIconFeature.State
        var remainingTime: TimeInterval = 0
        @Shared
        var remindersStatus: RemindersStatus

        var openWindowID: String?

        let timerID = UUID()

        init(remindersStatus: @autoclosure () -> RemindersStatus) {
            let status = Shared<RemindersStatus>(
                wrappedValue: remindersStatus(),
                .remindersStatus
            )
            _remindersStatus = status
            menuIcon = AppMenuIconFeature.State(remindersStatus: status)
        }
    }

    enum Action {
        case menuIcon(AppMenuIconFeature.Action)
        case missionBriefingTapped
        case onSleep
        case onWake
        case pauseRemindersTapped
        case restartRemindersTapped
        case resumeRemindersTapped
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

        Reduce { state, action in
            switch action {
            case .menuIcon(.delegate(.onAppear)):
                return handleOnAppear(&state)

            case .menuIcon:
                return .none

            case .onSleep:
                return .cancel(id: state.timerID)

            case .onWake:
                return handleWake(&state)

            case .pauseRemindersTapped:
                state.$remindersStatus.withLock { $0 = .paused }
                return .cancel(id: state.timerID)

            case .restartRemindersTapped:
                return restartReminders(&state)

            case .resumeRemindersTapped:
                return resumeReminders(&state)

            case .missionBriefingTapped:
                state.openWindowID = "main"
                return .run { send in
                    print("show briefing")
                }

            case .settingsTapped:
                return .run { send in
                    print("show settings")
                }

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

    private func handleOnAppear(_ state: inout AppFeature.State) -> Effect<
        AppFeature.Action
    > {
        handleWake(&state)
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

    private func handleWake(_ state: inout AppFeature.State) -> Effect<
        AppFeature.Action
    > {
        if state.remindersStatus == .on {
            if state.remainingTime <= 0 {
                state.remainingTime = state.defaultReminderInterval
            }
            return makeStartTimerEffect(state)
        }
        return .none
    }

    private func startReminders(_ state: inout AppFeature.State) -> Effect<
        AppFeature.Action
    > {
        guard state.remindersStatus != .on else {
            return .none
        }
        state.$remindersStatus.withLock { $0 = .on }
        state.remainingTime = state.defaultReminderInterval
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
        state.remainingTime = state.defaultReminderInterval
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
            state.remainingTime = state.defaultReminderInterval
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
