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
    @Bindable var launchAtLoginStore: StoreOf<LaunchAtLoginFeature>

    var body: some View {
        VStack(spacing: 20) {
            switch store.remindersStatus {
            case .on:
                Text("\(store.remainingTimeFormatted)")
                    .monospacedDigit()
                    .font(.largeTitle)

                HStack(spacing: 12) {
                    Button(action: {
                        store.send(
                            .delegate(.stopRemindersTapped),
                            animation: .easeInOut
                        )
                    }) {
                        Image(systemName: "stop.fill")
                            .foregroundStyle(Color.red)
                            .roundButtonLabel()
                    }
                    .accessibilityLabel("Stop reminders")
                    .help("Stop reminders")

                    Button(action: {
                        store.send(
                            .delegate(.pauseRemindersTapped),
                            animation: .easeInOut
                        )
                    }) {
                        Image(systemName: "pause.fill")
                            .foregroundStyle(Color.orange)
                            .roundButtonLabel()
                    }
                    .accessibilityLabel("Pause reminders")
                    .help("Pause reminders")

                    Button(action: {
                        store.send(
                            .delegate(.restartRemindersTapped),
                            animation: .easeInOut
                        )
                    }) {
                        Image(systemName: "backward.end.fill")
                            .foregroundStyle(Color.blue)
                            .roundButtonLabel()
                    }
                    .accessibilityLabel("Restart reminders")
                    .help("Restart reminders")
                }
            case .paused:
                Text("\(store.remainingTimeFormatted)")
                    .blinking()
                    .monospacedDigit()
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)

                HStack(spacing: 12) {
                    Button(action: {
                        store.send(
                            .delegate(.stopRemindersTapped),
                            animation: .easeInOut
                        )
                    }) {
                        Image(systemName: "stop.fill")
                            .foregroundStyle(Color.red)
                            .roundButtonLabel()
                    }
                    .accessibilityLabel("Stop reminders")
                    .help("Stop reminders")

                    Button(action: {
                        store.send(
                            .delegate(.resumeRemindersTapped),
                            animation: .easeInOut
                        )
                    }) {
                        Image(systemName: "play.fill")
                            .foregroundStyle(Color.green)
                            .roundButtonLabel()
                    }
                    .accessibilityLabel("Resume reminders")
                    .help("Resume reminders")

                    Button(action: {
                        store.send(
                            .delegate(.restartRemindersTapped),
                            animation: .easeInOut
                        )
                    }) {
                        Image(systemName: "backward.end.fill")
                            .foregroundStyle(Color.blue)
                            .roundButtonLabel()
                    }
                    .accessibilityLabel("Restart reminders")
                    .help("Restart reminders")
                }
            case .off:
                Text("\(store.reminderIntervalFormatted)")
                    .monospacedDigit()
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)

                HStack(spacing: 12) {
                    Button(action: {
                        store.send(
                            .delegate(.startRemindersTapped),
                            animation: .easeInOut
                        )
                    }) {
                        Image(systemName: "play.fill")
                            .foregroundStyle(Color.blue)
                            .roundButtonLabel()
                    }
                    .accessibilityLabel("Start reminders")
                    .help("Start reminders")
                }
            }
            Divider()
                .padding(.top, 6)
            HStack {
                Button {
                    store.send(.delegate(.quitTapped))
                } label: {
                    HStack {
                        Text("Quit")
                    }
                }
                .buttonStyle(.bordered)

                Spacer()

                Button {
                    store.send(.delegate(.settingsTapped))
                } label: {
                    Image(systemName: "gear")
                }
                .accessibilityLabel("Settings")
                .help("Settings")
            }
        }
        .buttonStyle(.plain)
        .imageScale(.large)
        .padding()
        .frame(width: 300)
        .alert($launchAtLoginStore.scope(state: \.alert, action: \.alert))
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

struct BlinkViewModifier: ViewModifier {
    let duration: Double
    @State private var blinking: Bool = false

    func body(content: Content) -> some View {
        content
            .opacity(blinking ? 0 : 1.0)
            .animation(
                .easeIn(duration: duration).repeatForever(),
                value: blinking
            )
            .onAppear {
                blinking = true
            }
    }
}

extension View {
    func blinking(duration: Double = 0.5) -> some View {
        modifier(BlinkViewModifier(duration: duration))
    }
}

#Preview {
    let store = Store(
        initialState: AppMenuFeature.State(
            remindersStatus: Shared(value: .on),
            remainingTime: Shared(value: 42),
            reminderInterval: Shared(value: 5),
            isMenuShown: false
        )
    ) {
        AppMenuFeature()
    }
    let launchAtLoginStore = Store(initialState: LaunchAtLoginFeature.State()) {
        LaunchAtLoginFeature()
    }
    AppMenuView(store: store, launchAtLoginStore: launchAtLoginStore)
}

#Preview {
    let store = Store(
        initialState: AppMenuFeature.State(
            remindersStatus: Shared(value: .off),
            remainingTime: Shared(value: 42),
            reminderInterval: Shared(value: 5),
            isMenuShown: false
        )
    ) {
        AppMenuFeature()
    }

    let launchAtLoginStore = Store(initialState: LaunchAtLoginFeature.State()) {
        LaunchAtLoginFeature()
    }
    AppMenuView(store: store, launchAtLoginStore: launchAtLoginStore)
}

#Preview {
    let store = Store(
        initialState: AppMenuFeature.State(
            remindersStatus: Shared(value: .paused),
            remainingTime: Shared(value: 42),
            reminderInterval: Shared(value: 5),
            isMenuShown: false
        )
    ) {
        AppMenuFeature()
    }
    let launchAtLoginStore = Store(initialState: LaunchAtLoginFeature.State()) {
        LaunchAtLoginFeature()
    }
    AppMenuView(store: store, launchAtLoginStore: launchAtLoginStore)
}
