//
//  SoundSettingsFeature.swift
//  Sergeant Kopniak
//
//  Created by alf on 12.11.2025.
//

import AppKit
import ComposableArchitecture

struct SoundOption {
    var label: String
    var soundName: String?
}

@Reducer
struct SoundSettingsFeature {
    @Dependency(\.soundPlayback) var soundPlayback
    @Dependency(\.systemSounds) var systemSounds

    @ObservableState
    struct State {
        var availableSounds: [String] = []

        var soundOptions: [SoundOption] {
            // Build sound options, ensuring current selection is included even if not yet loaded
            var options: [SoundOption] = [
                SoundOption(label: "None", soundName: nil)
            ]

            options.append(
                contentsOf: availableSounds.map {
                    SoundOption(label: $0, soundName: $0)
                }
            )

            // If current reminderSound is set but not in available sounds (e.g., before onAppear), add it
            if let currentSound = reminderSound,
                !availableSounds.contains(currentSound)
            {
                options.append(
                    SoundOption(label: currentSound, soundName: currentSound)
                )
            }

            return options
        }

        @Shared var reminderSound: String?
        @Shared var soundVolume: Double
    }

    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        case playPreviewSound
    }

    var body: some Reducer<State, Action> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .onAppear:
                state.availableSounds = systemSounds.availableSounds()
                return .none

            case .playPreviewSound:
                if let sound = state.reminderSound {
                    soundPlayback.playSound(sound, state.soundVolume)
                }
                return .none
            }
        }
    }
}
