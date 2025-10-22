//
//  AppMenuIconView.swift
//  Sergeant Kopniak
//
//  Created by alf on 19.10.2025.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct AppMenuIconFeature {
    @ObservableState
    struct State {
        @Shared var remindersStatus: RemindersStatus
        var openWindow: WindowID?
        var dismissWindow: WindowID?
    }

    enum Action {
        case delegate(Delegate)
        case onAppear
        case openWindow(WindowID)
        case dismissWindow(WindowID)

        enum Delegate {
            case onAppear
        }
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .delegate:
                return .none
            case .onAppear:
                return .run { send in
                    await send(.delegate(.onAppear))
                }
            case .openWindow(let windowID):
                state.openWindow = windowID
                return .none

            case .dismissWindow(let windowID):
                state.dismissWindow = windowID
                return .none
            }
        }
    }
}

struct AppMenuIconView: View {
    @Environment(\.openWindow) var openWindow
    @Environment(\.dismissWindow) var dismissWindow
    @Environment(\.openSettings) private var openSettings

    let store: StoreOf<AppMenuIconFeature>
    let reminderStore: StoreOf<ReminderFeature>
    let reminderController: ReminderController

    init(store: StoreOf<AppMenuIconFeature>, reminderStore: StoreOf<ReminderFeature>) {
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

    var body: some View {
        Image(systemName: menuBarIcon)
            .onAppear {
                store.send(.onAppear)
            }
            .onChange(of: store.openWindow) { _, windowID in
                if let windowID {
                    switch windowID.destination {
                    case .reminder:
                        showReminder()
                    case .settings:
                        openSettings()
                        NSApp.activate(ignoringOtherApps: true)
                    case .window(id: let id):
                        openWindow(id: id)
                        NSApp.activate(ignoringOtherApps: true)
                    }
                }
            }
            .onChange(of: store.dismissWindow) { _, windowID in
                if let windowID {
                    switch windowID.destination {
                    case .reminder:
                        dismissReminder()
                    case .settings:
                        break
                    case .window(id: let id):
                        dismissWindow(id: id)
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
}

#Preview {
    let status = Shared<RemindersStatus>(value: .on)
    AppMenuIconView(
        store: Store(
            initialState: AppMenuIconFeature.State(remindersStatus: status)
        ) {
            AppMenuIconFeature()
        },
        reminderStore: Store(initialState: ReminderFeature.State(title: "Title", message: "Message"), reducer: {
            ReminderFeature()
        })
    )
    .frame(width: 400, height: 300)
}
