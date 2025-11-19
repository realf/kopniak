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
        @Shared var menuIconTimeDisplay: TimeDisplaySetting
        @Shared var remindersStatus: RemindersStatus
        @Shared var remainingTime: TimeInterval

        var remainingTimeFormatted: String {
            formatted(remainingTime: remainingTime)
        }

        static let positionalTimeFormatter = {
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.minute, .second]
            formatter.zeroFormattingBehavior = .pad
            formatter.unitsStyle = .positional
            return formatter
        }()

        static let shortTimeFormatter = {
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.minute]
            formatter.unitsStyle = .short
            return formatter
        }()

        init(remindersStatus: Shared<RemindersStatus>, remainingTime: Shared<TimeInterval>, menuIconTimeDisplay: TimeDisplaySetting) {
            _remindersStatus = remindersStatus
            _remainingTime = remainingTime
            let menuIconTimeDisplay = Shared(
                wrappedValue: menuIconTimeDisplay,
                .appStorage("menuIconTimeDisplay")
            )
            _menuIconTimeDisplay = menuIconTimeDisplay
        }

        private func formatted(remainingTime: TimeInterval) -> String {
            return switch menuIconTimeDisplay {
            case .none:
                ""
            case .short:
                Self.shortTimeFormatter.string(from: remainingTime) ?? ""
            case .positional:
                Self.positionalTimeFormatter.string(from: remainingTime) ?? ""
            }
        }
    }
}
