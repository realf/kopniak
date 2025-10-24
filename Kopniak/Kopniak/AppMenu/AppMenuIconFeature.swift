//
//  AppMenuIconFeature.swift
//  Sergeant Kopniak
//
//  Created by alf on 23.10.2025.
//

import ComposableArchitecture
import Foundation

@Reducer
struct AppMenuIconFeature {
    @ObservableState
    struct State {
        @Shared var remindersStatus: RemindersStatus
        @Shared var remainingTime: TimeInterval
        var openWindow: WindowID?
        var dismissWindow: WindowID?
    }

    enum Action {
        case delegate(Delegate)
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
