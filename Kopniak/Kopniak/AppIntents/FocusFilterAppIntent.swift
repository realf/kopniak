//
//  FocusFilterAppIntent.swift
//  Kopniak
//
//  Created by alf on 21.12.2025.
//

import AppIntents
import ComposableArchitecture
import Foundation

struct FocusFilterAppIntent: SetFocusFilterIntent {
    static let title: LocalizedStringResource = "Configure Break Reminders"
    static let description: LocalizedStringResource? =
        "Configure automatic pause when this Focus filter is active."

    @AppDependency var store: StoreOf<AppIntentFeature>

    @Parameter(
        title: "Pause when this focus filter is active",
        description: "The break reminders timer is automatically paused.",
        default: false
    )
    var isAutoPauseActive: Bool

    var displayRepresentation: DisplayRepresentation {
        var titleList: [LocalizedStringResource] = []
        var subtitleList: [LocalizedStringResource] = []

        titleList.append("Automatic Pause")
        subtitleList.append(
            self.isAutoPauseActive
                ? "Automatic Pause: On" : "Automatic Pause: Off"
        )

        let title = LocalizedStringResource(
            "Configure Break Reminders Title",
            defaultValue: "Set \(titleList, format: .list(type: .and))"
        )
        let subtitle = LocalizedStringResource(
            "Configure Break Reminders Subtitle",
            defaultValue: "\(subtitleList, format: .list(type: .and))"
        )

        return DisplayRepresentation(title: title, subtitle: subtitle)
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        store.send(.delegate(.focusFilterDidSetAutoPause(isAutoPauseActive)))
        return .result()
    }

    static func suggestedFocusFilters(for: FocusFilterSuggestionContext) async
        -> [Self]
    {
        let focusFilter = FocusFilterAppIntent()
        focusFilter.isAutoPauseActive = true
        return [focusFilter]
    }
}
