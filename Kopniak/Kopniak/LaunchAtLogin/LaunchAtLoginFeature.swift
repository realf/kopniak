//
//  LaunchAtLoginFeature.swift
//  Sergeant Kopniak
//
//  Created by alf on 23.10.2025.
//

import ComposableArchitecture
import Foundation

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
    }

    enum Action {
        case delegate(Delegate)
        case noTapped
        case yesTapped
        case startRemindersTapped

        enum Delegate {
            case showLaunchAtLogin
            case dismissLaunchAtLogin
        }
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .delegate:
                return .none

            case .noTapped:
                state.$launchAtLoginResponseReceived.withLock { $0 = true }
                return .run { send in
                    await send(.delegate(.dismissLaunchAtLogin))
                }

            case .startRemindersTapped:
                guard !state.launchAtLoginResponseReceived else {
                    return .none
                }
                guard !smAppService.isEnabled() else {
                    state.$launchAtLoginResponseReceived.withLock { $0 = true }
                    return .none
                }

                state.$reminderActivationCount.withLock { $0 += 1 }
                if state.reminderActivationCount >= 3 {
                    state.$reminderActivationCount.withLock { $0 = 0 }
                    return .run { send in
                        await send(.delegate(.showLaunchAtLogin))
                    }
                }
                return .none

            case .yesTapped:
                state.$launchAtLoginResponseReceived.withLock { $0 = true }
                return .run { send in
                    do {
                        try await smAppService.register()
                    } catch {
                        NSLog("Failed to enable launch at login: \(error)")
                    }
                    await send(.delegate(.dismissLaunchAtLogin))
                }
            }
        }
    }
}
