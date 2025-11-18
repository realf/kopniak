//
//  AppMenuView.swift
//  Kopniak
//
//  Created by alf on 18.11.2025.
//

import ComposableArchitecture
import SwiftUI

struct AppMenuView: View {
    var store: StoreOf<AppMenuFeature>

    var body: some View {
        VStack(spacing: 20) {
            switch store.remindersStatus {
            case .on:
                Text("Reminders on")
                    .font(.largeTitle)
                Text("Next in \(store.remainingTimeFormatted)")
                    .monospacedDigit()
                    .font(.title)

                HStack(spacing: 12) {
                    Button(action: {
                        store.send(.delegate(.stopRemindersTapped))
                    }) {
                        Image(systemName: "stop.fill")
                            .foregroundStyle(Color.red)
                            .roundButtonLabel()
                    }
                    .accessibilityLabel(Text("Stop reminders"))

                    Button(action: {
                        store.send(.delegate(.pauseRemindersTapped))
                    }) {
                        Image(systemName: "pause.fill")
                            .foregroundStyle(Color.orange)
                            .roundButtonLabel()
                    }
                    .accessibilityLabel(Text("Pause reminders"))

                    Button(action: {
                        store.send(.delegate(.restartRemindersTapped))
                    }) {
                        Image(systemName: "backward.end.fill")
                            .foregroundStyle(Color.blue)
                            .roundButtonLabel()
                    }
                    .accessibilityLabel(Text("Restart reminders"))
                }
            case .paused:
                Text("Reminders paused")
                    .font(.largeTitle)
                Text("Next in \(store.remainingTimeFormatted)")
                    .monospacedDigit()
                    .font(.title)

                HStack(spacing: 12) {
                    Button(action: {
                        store.send(.delegate(.stopRemindersTapped))
                    }) {
                        Image(systemName: "stop.fill")
                            .foregroundStyle(Color.red)
                            .roundButtonLabel()
                    }
                    .accessibilityLabel(Text("Stop reminders"))

                    Button(action: {
                        store.send(.delegate(.resumeRemindersTapped))
                    }) {
                        Image(systemName: "play.fill")
                            .foregroundStyle(Color.green)
                            .roundButtonLabel()
                    }
                    .accessibilityLabel(Text("Resume reminders"))

                    Button(action: {
                        store.send(.delegate(.restartRemindersTapped))
                    }) {
                        Image(systemName: "backward.end.fill")
                            .foregroundStyle(Color.blue)
                            .roundButtonLabel()
                    }
                    .accessibilityLabel(Text("Restart reminders"))
                }
            case .off:
                Text("Reminders off")
                    .font(.largeTitle)

                HStack(spacing: 12) {
                    Button(action: { store.send(.delegate(.startRemindersTapped)) })
                    {
                        Image(systemName: "play.fill")
                            .foregroundStyle(Color.blue)
                            .roundButtonLabel()
                    }
                    .accessibilityLabel(Text("Start reminders"))
                }
            }
            Divider()
            HStack {
                HStack {
                    Button {
                        store.send(.delegate(.quitTapped))
                    } label: {
                        HStack {
                            Image(systemName: "xmark.circle.fill")
                            Text("Quit Kopniak")
                        }
                    }
                    Spacer()
                }

                Spacer()

                Button {
                    store.send(.delegate(.settingsTapped))
                } label: {
                    Image(systemName: "gear")
                }
                .accessibilityLabel("Settings")
            }
        }
        .buttonStyle(.plain)
        .imageScale(.large)
        .padding()
        .frame(width: 500)
    }
}

struct RoundButtonLabel: ViewModifier {
    let buttonSize = 40.0
    let buttonMaterial = Material.ultraThick

    func body(content: Content) -> some View {
        content
            .frame(width: buttonSize, height: buttonSize)
            .background(buttonMaterial)
            .clipShape(Circle())
            .overlay(.primary, in: Circle().stroke(lineWidth: 2))
    }
}

extension View {
    func roundButtonLabel() -> some View {
        modifier(RoundButtonLabel())
    }
}

#Preview {
    let store = Store(
        initialState: AppMenuFeature.State(
            remindersStatus: Shared(value: .on),
            remainingTime: Shared(value: 42),
            isMenuShown: false
        )
    ) {
        AppMenuFeature()
    }
    AppMenuView(store: store)
}

#Preview {
    let store = Store(
        initialState: AppMenuFeature.State(
            remindersStatus: Shared(value: .off),
            remainingTime: Shared(value: 42),
            isMenuShown: false
        )
    ) {
        AppMenuFeature()
    }
    AppMenuView(store: store)
}

#Preview {
    let store = Store(
        initialState: AppMenuFeature.State(
            remindersStatus: Shared(value: .paused),
            remainingTime: Shared(value: 42),
            isMenuShown: false
        )
    ) {
        AppMenuFeature()
    }
    AppMenuView(store: store)
}
