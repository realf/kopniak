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
    }

    enum Action {
        case delegate(Delegate)
        case onAppear
        case openWindow(WindowID)

        enum Delegate {
            case onAppear
        }
    }

    var body: some Reducer<State, Action> {
        Reduce.init { state, action in
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
            }
        }
    }
}

struct AppMenuIconView: View {
    @Environment(\.openWindow) var openWindow
    @Environment(\.openSettings) private var openSettings

    let store: StoreOf<AppMenuIconFeature>

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
                    case .settings:
                        openSettings()
                    case .window(id: let id):
                        openWindow(id: id)
                    }
                    NSApp.activate(ignoringOtherApps: true)
                }
            }
    }
}

#Preview {
    let status = Shared<RemindersStatus>(value: .on)
    AppMenuIconView(
        store: Store(
            initialState: AppMenuIconFeature.State(remindersStatus: status)
        ) {
            AppMenuIconFeature()
        }
    )
    .frame(width: 400, height: 300)
}
