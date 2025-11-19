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
        @Shared var remainingTime: TimeInterval
        @Shared var reminderInterval: TimeInterval

        var remainingTimeFormatted: String {
            Self.positionalTimeFormatter.string(from: remainingTime) ?? ""
        }

        var reminderIntervalFormatted: String {
            Self.positionalTimeFormatter.string(from: reminderInterval) ?? ""
        }
        var isMenuShown = false

        static let positionalTimeFormatter = {
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.minute, .second]
            formatter.zeroFormattingBehavior = .pad
            formatter.unitsStyle = .positional
            return formatter
        }()
    }

    enum Action {
        case delegate(Delegate)
        case menuDidClose
        case menuIconTapped

        enum Delegate {
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
            case .menuDidClose:
                state.isMenuShown = false
                return .none

            case .menuIconTapped:
                state.isMenuShown.toggle()
                return .none

            case .delegate:
                return .none
            }
        }
    }
}
