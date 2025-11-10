//
//  BriefingFeature.swift
//  Sergeant Kopniak
//
//  Created by alf on 23.10.2025.
//

import ComposableArchitecture
import Foundation

@Reducer
struct BriefingFeature {
    @ObservableState
    struct State {
        @Shared var reminderInterval: TimeInterval
        var reminderIntervalFormatted: String {
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.minute, .second]
            formatter.unitsStyle = .full
            return formatter.string(from: reminderInterval) ?? "0 minutes"
        }
        @Shared var remindersStatus: RemindersStatus
    }

    enum Action {
        case delegate(Delegate)

        enum Delegate {
            case pauseRemindersTapped
            case restartRemindersTapped
            case resumeRemindersTapped
            case startRemindersTapped
            case stopRemindersTapped
            case settingsTapped
        }
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            return .none
        }
    }
}
