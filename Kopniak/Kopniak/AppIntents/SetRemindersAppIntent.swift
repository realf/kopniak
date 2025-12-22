//
//  StopRemindersAppIntent.swift
//  Kopniak
//
//  Created by alf on 19.12.2025.
//

import AppIntents
import ComposableArchitecture
import Foundation

enum BreakRemindersAction: String, AppEnum {
    static let typeDisplayRepresentation: TypeDisplayRepresentation =
        "Break Reminders Action"

    static let caseDisplayRepresentations:
        [BreakRemindersAction: DisplayRepresentation] = [
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
        "Opens the app and performs a selected action on the break reminders."
    )
    @AppDependency var store: StoreOf<AppIntentFeature>

    @Parameter(
        title: "Break Reminders Action",
        description: "Action to perform on the break reminders.",
        default: .start
    )
    var breakRemindesAction: BreakRemindersAction

    @available(macOS 26.0, *)
    static let supportedModes: IntentModes = [.background, .foreground]

    static var parameterSummary: some ParameterSummary {
        Summary("\(\.$breakRemindesAction) break reminders")
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        switch breakRemindesAction {
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
