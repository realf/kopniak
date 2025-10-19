//
//  AppFeature.swift
//  Sergeant Kopniak
//
//  Created by alf on 16.10.2025.
//

import AppKit
import ComposableArchitecture
import Foundation

@Reducer
struct AppFeature {
    @Dependency(\.continuousClock) var clock
    var defaultReminderInterval: TimeInterval = 45.0

    @ObservableState
    struct State {
        var remainingTime: TimeInterval = 0.0
        var remindersStatus: RemindersStatus = .on
        var openWindowID: String?
        let timerID = UUID()

        enum RemindersStatus {
            case off
            case on
            case paused
        }
    }

    enum Action {
        case onAppear
        case onSleep
        case onWake
        case openBriefingTapped
        case pauseRemindersTapped
        case restartRemindersTapped
        case resumeRemindersTapped
        case showIntroTapped
        case showSettingsTapped
        case startRemindersTapped
        case stopRemindersTapped
        case timerTicked
        case quitTapped
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return handleOnAppear(&state)

            case .onSleep:
                return .cancel(id: state.timerID)

            case .onWake:
                return handleWake(&state)

            case .openBriefingTapped:
                state.openWindowID = "main"
                return .none

            case .pauseRemindersTapped:
                state.remindersStatus = .paused
                return .cancel(id: state.timerID)

            case .restartRemindersTapped:
                return restartReminders(&state)

            case .resumeRemindersTapped:
                return resumeReminders(&state)

            case .showIntroTapped:
                return .run { send in
                    print("show intro")
                }

            case .showSettingsTapped:
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

    private func handleWake(_ state: inout AppFeature.State) -> Effect<
        AppFeature.Action
    > {
        if state.remindersStatus == .on {
            if state.remainingTime <= 0 {
                state.remainingTime = defaultReminderInterval
            }
            return .run { send in
                await startTimer(send)
            }
        }
        return .none
    }

    private func startReminders(_ state: inout AppFeature.State) -> Effect<
        AppFeature.Action
    > {
        guard state.remindersStatus != .on else {
            return .none
        }
        state.remindersStatus = .on
        state.remainingTime = defaultReminderInterval
        return .run { send in
            await startTimer(send)
        }
        .cancellable(id: state.timerID)
    }

    private func startTimer(_ send: Send<AppFeature.Action>) async {
        for await _ in self.clock.timer(interval: .seconds(1)) {
            send(.timerTicked)
        }
    }

    private func stopReminders(_ state: inout AppFeature.State) -> Effect<
        AppFeature.Action
    > {
        state.remainingTime = 0.0
        state.remindersStatus = .off
        return .cancel(id: state.timerID)
    }

    private func restartReminders(_ state: inout AppFeature.State)
        -> Effect<AppFeature.Action>
    {
        state.remindersStatus = .on
        state.remainingTime = defaultReminderInterval
        return .concatenate(
            .cancel(id: state.timerID),
            .run { send in
                await startTimer(send)
            }
            .cancellable(id: state.timerID)
        )
    }

    private func resumeReminders(_ state: inout AppFeature.State)
        -> Effect<AppFeature.Action>
    {
        guard state.remindersStatus == .paused else {
            return .none
        }
        state.remindersStatus = .on
        if state.remainingTime <= 0 {
            state.remainingTime = defaultReminderInterval
        }
        return .run { send in
            await startTimer(send)
        }
        .cancellable(id: state.timerID)
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
