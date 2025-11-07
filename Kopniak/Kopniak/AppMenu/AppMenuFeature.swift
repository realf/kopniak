//
//  AppMenuFeature.swift
//  Sergeant Kopniak
//
//  Created by alf on 24.10.2025.
//

import ComposableArchitecture
import Foundation

@Reducer
struct AppMenuFeature {
    @ObservableState
    struct State {
        @Shared var remindersStatus: RemindersStatus
    }

    enum Action {
        case delegate(Delegate)

        enum Delegate {
            case missionBriefingTapped
            case pauseRemindersTapped
            case restartRemindersTapped
            case resumeRemindersTapped
            case settingsTapped
            case startRemindersTapped
            case stopRemindersTapped
            case quitTapped
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
