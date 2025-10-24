//
//  AppMenuView.swift
//  Sergeant Kopniak
//
//  Created by alf on 18.10.2025.
//

import ComposableArchitecture
import SwiftUI

struct AppMenuView: View {
    let store: StoreOf<AppMenuFeature>

    var body: some View {
        VStack {
            Button {
                store.send(.delegate(.missionBriefingTapped))
            } label: {
                HStack {
                    Image(systemName: "chevron.up.2")
                    Text("Mission Briefing")
                }
            }
            .keyboardShortcut("b", modifiers: .command)

            Divider()

            switch store.remindersStatus {
            case .off:
                Button {
                    store.send(.delegate(.startRemindersTapped))
                } label: {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Report for Duty")
                    }
                }
                .keyboardShortcut("r", modifiers: .command)
            case .on:
                Button {
                    store.send(.delegate(.stopRemindersTapped))
                } label: {
                    HStack {
                        Image(systemName: "stop.fill")
                        Text("Stand Down")
                    }
                }
                .keyboardShortcut("s", modifiers: .command)

                Button {
                    store.send(.delegate(.pauseRemindersTapped))
                } label: {
                    HStack {
                        Image(systemName: "pause.fill")
                        Text("At Ease")
                    }
                }
                .keyboardShortcut("p", modifiers: .command)

                Button {
                    store.send(.delegate(.restartRemindersTapped))
                } label: {
                    HStack {
                        Image(systemName: "restart.circle.fill")
                        Text("Reissue Orders")
                    }
                }
                .keyboardShortcut("o", modifiers: .command)
            case .paused:
                Button {
                    store.send(.delegate(.stopRemindersTapped))
                } label: {
                    HStack {
                        Image(systemName: "stop.fill")
                        Text("Stand Down")
                    }
                }
                .keyboardShortcut("s", modifiers: .command)

                Button {
                    store.send(.delegate(.resumeRemindersTapped))
                } label: {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Resume Duty")
                    }
                }
                .keyboardShortcut("r", modifiers: .command)

                Button {
                    store.send(.delegate(.restartRemindersTapped))
                } label: {
                    HStack {
                        Image(systemName: "restart.circle.fill")
                        Text("Reissue Orders")
                    }
                }
                .keyboardShortcut("o", modifiers: .command)
            }

            Divider()

            Button {
                store.send(.delegate(.settingsTapped))
            } label: {
                HStack {
                    Image(systemName: "gear")
                    Text("Settings…")
                }
            }
            .keyboardShortcut(",", modifiers: .command)

            Divider()

            Button("Quit Sergeant Kopniak") {
                store.send(.delegate(.quitTapped))
            }
            .keyboardShortcut("q", modifiers: .command)
        }
    }
}

#Preview {
    AppMenuView(
        store: Store(
            initialState: AppMenuFeature.State(
                remindersStatus: Shared(value: .on)
            ),
            reducer: {
                AppMenuFeature()
            }
        )
    )
    .frame(width: 400, height: 300)
}
