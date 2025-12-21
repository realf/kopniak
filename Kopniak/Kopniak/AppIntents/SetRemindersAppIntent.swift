//
//  StopRemindersAppIntent.swift
//  Kopniak
//
//  Created by alf on 19.12.2025.
//

import AppIntents
import ComposableArchitecture
import Foundation

enum RemindersStateSwitchOption: String, AppEnum {
    static let typeDisplayRepresentation: TypeDisplayRepresentation =
        "Break Reminders State Switch Option"

    static let caseDisplayRepresentations:
        [RemindersStateSwitchOption: DisplayRepresentation] = [
            .start: DisplayRepresentation(title: "Start", image: .init(systemName: "play.fill")),
            .stop: DisplayRepresentation(title: "Stop", image: .init(systemName: "stop.fill")),
            .toggle: DisplayRepresentation(title: "Toggle", image: .init(systemName: "playpause.fill"))
        ]

    case start
    case stop
    case toggle
}

struct SetRemindersAppIntent: AppIntent {
    static let title: LocalizedStringResource = "Set Break Reminders"
    static let description: IntentDescription = IntentDescription(
        "Opens the app and switches the state of break reminders."
    )
    @AppDependency var store: StoreOf<AppIntentFeature>

    @Parameter(
        title: "Start",
        description: "The break reminders state switch option.",
        default: .start
    )
    var stateTransitionOption: RemindersStateSwitchOption

    @available(macOS 26.0, *)
    static let supportedModes: IntentModes = [.background, .foreground]

    static var parameterSummary: some ParameterSummary {
        Summary("\(\.$stateTransitionOption) break reminders")
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        switch stateTransitionOption {
        case .start:
            store.send(.delegate(.startReminders))
        case .stop:
            store.send(.delegate(.stopReminders))
        case .toggle:
            store.send(.delegate(.toggleReminders))
        }

        return .result()
    }
}

@available(*, deprecated)
extension SetRemindersAppIntent {
    static var openAppWhenRun: Bool { true }
}
