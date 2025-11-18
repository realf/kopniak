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

        var remainingTimeFormatted: String {
            formatted(remainingTime: remainingTime)
        }
        var isMenuShown = true

        static let positionalTimeFormatter = {
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.minute, .second]
            formatter.zeroFormattingBehavior = .pad
            formatter.unitsStyle = .positional
            return formatter
        }()

        private func formatted(remainingTime: TimeInterval) -> String {
            Self.positionalTimeFormatter.string(from: remainingTime) ?? ""
        }
    }

    enum Action {
        case delegate(Delegate)
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
            case .menuIconTapped:
                state.isMenuShown.toggle()
                return .none

            case .delegate:
                return .none
            }
        }
    }
}
