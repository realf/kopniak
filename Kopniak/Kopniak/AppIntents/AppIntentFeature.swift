//
//  AppIntentFeature.swift
//  Kopniak
//
//  Created by alf on 17.12.2025.
//

import ComposableArchitecture
import Foundation

@Reducer
struct AppIntentFeature {
    enum Action {
        case delegate(Delegate)

        enum Delegate {
            case startReminders
            case stopReminders
        }
    }
}
