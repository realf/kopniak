//
//  AppMenuIconView.swift
//  Sergeant Kopniak
//
//  Created by alf on 19.10.2025.
//

import ComposableArchitecture
import SwiftUI

struct AppMenuIconView: View {
    @Environment(\.openWindow) var openWindow
    @Environment(\.dismissWindow) var dismissWindow
    @Environment(\.openSettings) private var openSettings

    let store: StoreOf<AppMenuIconFeature>
    let reminderStore: StoreOf<ReminderFeature>
    let reminderController: ReminderController

    init(
        store: StoreOf<AppMenuIconFeature>,
        reminderStore: StoreOf<ReminderFeature>
    ) {
        self.store = store
        self.reminderStore = reminderStore
        self.reminderController = ReminderController(store: reminderStore)
    }

    private var menuBarIcon: String {
        if store.remindersStatus == .on {
            return "chevron.up.2"
        } else {
            return "chevron.up.dotted.2"
        }
    }

    private func formatted(remainingTime: TimeInterval) -> String {
        let totalSeconds = Int(remainingTime)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    var body: some View {
        HStack {
            Image(systemName: menuBarIcon)
            if store.remindersStatus != .off {
                Text(formatted(remainingTime: store.remainingTime))
                    .font(.system(.body, design: .monospaced))
            }
        }
        .onAppear {
            store.send(.onAppear)
            DispatchQueue.main.async {
                // Activate the app to bring it to front
                activateApp()
            }
        }
        .onChange(of: store.openWindow) { _, windowID in
            if let windowID {
                switch windowID.destination {
                case .briefing:
                    openWindow(id: "briefing")
                    activateApp()
                case .launchAtLogin:
                    openWindow(id: "launchAtLogin")
                    activateApp()
                case .reminder:
                    showReminder()
                case .settings:
                    openSettings()
                    activateApp()
                }
            }
        }
        .onChange(of: store.dismissWindow) { _, windowID in
            if let windowID {
                switch windowID.destination {
                case .briefing:
                    dismissWindow(id: "briefing")
                case .launchAtLogin:
                    dismissWindow(id: "launchAtLogin")
                case .reminder:
                    dismissReminder()
                case .settings:
                    break
                }
            }
        }
    }

    private func showReminder() {
        reminderController.showReminder()
    }

    private func dismissReminder() {
        reminderController.hideReminder()
    }

    private func activateApp() {
        DispatchQueue.main.async {
            // Activate the app to bring it to front
            NSRunningApplication.current.activate(
                options: .activateAllWindows
            )
        }
    }
}

#Preview {
    let status = Shared<RemindersStatus>(value: .on)
    AppMenuIconView(
        store: Store(
            initialState: AppMenuIconFeature.State(
                remindersStatus: status,
                remainingTime: Shared(value: 90.0)
            )
        ) {
            AppMenuIconFeature()
        },
        reminderStore: Store(
            initialState: ReminderFeature.State(
                title: "Title",
                message: "Message"
            ),
            reducer: {
                ReminderFeature()
            }
        )
    )
    .frame(width: 400, height: 300)
}
