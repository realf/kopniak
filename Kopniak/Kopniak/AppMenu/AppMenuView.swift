//
//  AppMenuView.swift
//  Sergeant Kopniak
//
//  Created by alf on 18.10.2025.
//

import ComposableArchitecture
import SwiftUI

struct AppMenuView: View {
    @Environment(\.openWindow) var openWindow
    let store: StoreOf<AppFeature>

    var body: some View {
        VStack {
            Button {
                // Activate the app and show the window
                store.send(.openBriefingTapped)
                NSApp.activate(ignoringOtherApps: true)
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
                    store.send(.startRemindersTapped)
                } label: {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Report for Duty")
                    }
                }
                .keyboardShortcut("r", modifiers: .command)
            case .on:
                Button {
                    store.send(.stopRemindersTapped)
                } label: {
                    HStack {
                        Image(systemName: "stop.fill")
                        Text("Stand Down")
                    }
                }
                .keyboardShortcut("s", modifiers: .command)

                Button {
                    store.send(.pauseRemindersTapped)
                } label: {
                    HStack {
                        Image(systemName: "pause.fill")
                        Text("At Ease")
                    }
                }
                .keyboardShortcut("p", modifiers: .command)

                Button {
                    store.send(.restartRemindersTapped)
                } label: {
                    HStack {
                        Image(systemName: "restart.circle.fill")
                        Text("I Say Again")
                    }
                }
                .keyboardShortcut("a", modifiers: .command)
            case .paused:
                Button {
                    store.send(.stopRemindersTapped)
                } label: {
                    HStack {
                        Image(systemName: "stop.fill")
                        Text("Stand Down")
                    }
                }
                .keyboardShortcut("s", modifiers: .command)

                Button {
                    store.send(.resumeRemindersTapped)
                } label: {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Resume Duty")
                    }
                }
                .keyboardShortcut("r", modifiers: .command)

                Button {
                    store.send(.restartRemindersTapped)
                } label: {
                    HStack {
                        Image(systemName: "restart.circle.fill")
                        Text("I Say Again")
                    }
                }
                .keyboardShortcut("a", modifiers: .command)
            }

            Divider()

            Button {
                store.send(.showSettingsTapped)
                NSApp.activate(ignoringOtherApps: true)
            } label: {
                HStack {
                    Image(systemName: "gear")
                    Text("Settings...")
                }
            }
            .keyboardShortcut(",", modifiers: .command)

            Divider()

            Button("Quit Sergeant Kopniak") {
                store.send(.quitTapped)
            }
            .keyboardShortcut("q", modifiers: .command)
        }
        .onChange(of: store.openWindowID) { _, id in
            if let id {
                openWindow(id: id)
            }
        }
    }
}

#Preview {
    AppMenuView(
        store: Store(
            initialState: AppFeature.State(remindersStatus: .paused),
            reducer: {
                AppFeature()._printChanges()
            }
        )
    )
    .frame(width: 400, height: 300)
}

#Preview {
    AppMenuView(
        store: Store(
            initialState: AppFeature.State(remindersStatus: .on),
            reducer: {
                AppFeature()._printChanges()
            }
        )
    )
    .frame(width: 400, height: 300)
}

#Preview {
    AppMenuView(
        store: Store(
            initialState: AppFeature.State(remindersStatus: .off),
            reducer: {
                AppFeature()._printChanges()
            }
        )
    )
    .frame(width: 400, height: 300)
}
