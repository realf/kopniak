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
        @Shared var remindersStatus: RemindersStatus
        @Shared var remainingTime: TimeInterval
    }
}
