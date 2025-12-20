//
//  StartTimerAppIntent.swift
//  Kopniak
//
//  Created by alf on 17.12.2025.
//

import AppIntents
import ComposableArchitecture
import Foundation

struct StartRemindersAppIntent: AppIntent {
    static let title: LocalizedStringResource = "Start Reminders"
    static let description: IntentDescription = IntentDescription(
        "Opens the app and starts break reminders."
    )
    @AppDependency var store: StoreOf<AppIntentFeature>

    @available(macOS 26.0, *)
    static let supportedModes: IntentModes = [.foreground]

    @MainActor
    func perform() async throws -> some IntentResult {
        store.send(.delegate(.startReminders))
        return .result()
    }
}

@available(*, deprecated)
extension StartRemindersAppIntent {
    static var openAppWhenRun: Bool { true }
}
