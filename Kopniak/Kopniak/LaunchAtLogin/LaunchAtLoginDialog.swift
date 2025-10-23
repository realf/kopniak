//
//  LaunchAtLoginDialog.swift
//  Sergeant Kopniak
//
//  Created by alf on 03.10.2025.
//

import ComposableArchitecture
import SwiftUI

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
                return .run { send in await send(.delegate(.dismissLaunchAtLogin)) }

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

struct LaunchAtLoginDialog: View {
    var store: StoreOf<LaunchAtLoginFeature>

    var body: some View {
        VStack(spacing: 20) {
            // Icon
            Image(systemName: "calendar.badge.clock")
                .imageScale(.large)
                .foregroundStyle(.brown)
                .font(.system(size: 32))

            // Title
            Text("ENLIST FOR DAILY DUTY?")
                .font(.title2)
                .fontWeight(.bold)

            // Message
            Text(
                """
                Want me to report for duty automatically every time you log in to your Mac?

                I'll be standing by in your menu bar, ready to keep you moving!
                """
            )
            .multilineTextAlignment(.leading)
            .foregroundColor(.secondary)
            .fixedSize(horizontal: false, vertical: true)

            // Buttons
            HStack(spacing: 12) {
                Button("No, Sir!") {
                    store.send(.noTapped)
                }

                Button("Yes, Sir!") {
                    store.send(.yesTapped)
                }
                .keyboardShortcut(.defaultAction)
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(30)
        .frame(width: 450)
    }
}

#Preview {
    LaunchAtLoginDialog(
        store: Store(
            initialState: LaunchAtLoginFeature.State(),
            reducer: {
                LaunchAtLoginFeature()
            }
        )
    )
}
