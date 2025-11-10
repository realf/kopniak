//
//  SettingsFeature.swift
//  Sergeant Kopniak
//
//  Created by alf on 23.10.2025.
//

import ComposableArchitecture
import Foundation

enum SettingsTab: Sendable, Equatable {
    case general
    case about
}

@Reducer
struct SettingsFeature {
    @ObservableState
    struct State {
        var selectedTab: SettingsTab = .general
        var generalSettings: GeneralSettingsFeature.State
        var about: AboutFeature.State

        init(
            reminderInterval: Shared<TimeInterval>,
            snoozeInterval: Shared<TimeInterval>,
            menuIconTimeDisplay: Shared<TimeDisplaySetting>,
            restartAfterScreenLock: Shared<Bool>
        ) {
            self.selectedTab = .general
            self.generalSettings = GeneralSettingsFeature.State(
                reminderInterval: reminderInterval,
                snoozeInterval: snoozeInterval,
                menuIconTimeDisplay: menuIconTimeDisplay,
                restartAfterScreenLock: restartAfterScreenLock
            )
            self.about = AboutFeature.State()
        }
    }

    enum Action {
        case about(AboutFeature.Action)
        case delegate(Delegate)
        case generalSettings(GeneralSettingsFeature.Action)
        case selectTab(SettingsTab)

        enum Delegate {
            case reminderIntervalChanged
        }
    }

    var body: some Reducer<State, Action> {
        Scope(state: \.generalSettings, action: \.generalSettings) {
            GeneralSettingsFeature()
        }

        Scope(state: \.about, action: \.about) {
            AboutFeature()
        }

        Reduce { state, action in
            switch action {
            case .about:
                return .none

            case .delegate:
                return .none

            case .generalSettings(.delegate(.reminderIntervalChanged)):
                return .run { send in
                    await send(.delegate(.reminderIntervalChanged))
                }

            case .generalSettings:
                return .none

            case .selectTab(let tab):
                state.selectedTab = tab
                return .none
            }
        }
    }
}
