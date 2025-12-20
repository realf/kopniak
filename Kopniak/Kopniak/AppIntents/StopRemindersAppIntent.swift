//
//  StopRemindersAppIntent.swift
//  Kopniak
//
//  Created by alf on 19.12.2025.
//

import AppIntents
import ComposableArchitecture
import Foundation

struct StopRemindersAppIntent: AppIntent {
    static let title: LocalizedStringResource = "Stop Reminders"
    static let description: IntentDescription = IntentDescription(
        "Stops break reminders."
    )
    @AppDependency var store: StoreOf<AppIntentFeature>

    @available(macOS 26.0, *)
    static let supportedModes: IntentModes = [.background]

    @MainActor
    func perform() async throws -> some IntentResult {
        store.send(.delegate(.stopReminders))
        return .result()
    }
}

@available(*, deprecated)
extension StopRemindersAppIntent {
    static var openAppWhenRun: Bool { false }
}
