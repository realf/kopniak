//
//  LaunchAtLoginFeature.swift
//  Sergeant Kopniak
//
//  Created by alf on 23.10.2025.
//

import ComposableArchitecture
import Foundation
import OSLog

@Reducer
struct LaunchAtLoginFeature {
    @Dependency(\.smAppService) var smAppService

    @ObservableState
    struct State {
        @Shared(.appStorage("launchAtLoginResponseReceived"))
        var launchAtLoginResponseReceived =
            false
        @Shared(.appStorage("reminderActivationCount"))
        var reminderActivationCount = 0

        @Presents var alert: AlertState<Action.Alert>?
    }

    enum Action {
        case alert(PresentationAction<Alert>)
        case delegate(Delegate)
        case startRemindersTapped

        enum Delegate {
            case launchAtLoginDidUpdate
        }

        enum Alert: Equatable {
            case decideLater
            case no
            case yes
        }
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .alert(.presented(let action)):
                switch action {
                case .yes:
                    state.$launchAtLoginResponseReceived.withLock { $0 = true }
                    return .run { send in
                        do {
                            try smAppService.register()
                        } catch {
                            Logger.launchAtLoginLogging.error("Failed to enable launch at login: \(error)")
                        }
                        await send(.delegate(.launchAtLoginDidUpdate))
                    }

                case .no:
                    state.$launchAtLoginResponseReceived.withLock { $0 = true }
                    return .none

                case .decideLater:
                    return .none
                }

            case .alert:
                return .none

            case .delegate:
                return .none

            case .startRemindersTapped:
                guard !state.launchAtLoginResponseReceived else {
                    return .none
                }
                guard !smAppService.isEnabled() else {
                    state.$launchAtLoginResponseReceived.withLock { $0 = true }
                    return .none
                }

                state.$reminderActivationCount.withLock { $0 += 1 }
                let count = state.reminderActivationCount
                if count == 3 || count == 8 || count % 21 == 0 {
                    state.alert = AlertState {
                        TextState(
                            "Open at Login"
                        )
                    } actions: {
                        ButtonState(action: .yes) { TextState("Yes") }
                        ButtonState(action: .no) { TextState("No") }
                        ButtonState(
                            role: .cancel,
                            action: .decideLater
                        ) {
                            TextState("Ask Later")
                        }
                    } message: {
                        TextState("Do you want to open Kopniak automatically when you log in?")
                    }
                }
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}
