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
    }

    enum Action {
        case delegate(Delegate)
        enum Delegate {
            case onAppear
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
