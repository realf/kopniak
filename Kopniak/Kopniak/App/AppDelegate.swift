//
//  AppDelegate.swift
//  Kopniak
//
//  Created by alf on 19.11.2025.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct AppDelegateFeature {
    @ObservableState
    struct State {}

    enum Action {
        case delegate(Delegate)

        enum Delegate {
            case applicationDidFinishLaunching
            case handleReopen(_ hasVisibleWindows: Bool)
        }
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .delegate:
                return .none
            }
        }
    }
}

@Observable
class AppDelegate: NSObject, NSApplicationDelegate {
    var store: StoreOf<AppDelegateFeature>!

    func applicationShouldHandleReopen(
        _ sender: NSApplication,
        hasVisibleWindows: Bool
    ) -> Bool {
        store.send(.delegate(.handleReopen(hasVisibleWindows)))
        return true
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        store.send(.delegate(.applicationDidFinishLaunching))
    }
}
