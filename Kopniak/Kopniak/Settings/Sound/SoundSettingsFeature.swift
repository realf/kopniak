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
        var isLoadingSounds = true

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

            return options
        }

        @Shared var reminderSound: String?
        @Shared var soundVolume: Double
    }

    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        case playPreviewSound
        case reminderSoundChanged
        case soundsLoaded([String])
    }

    var body: some Reducer<State, Action> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .onAppear:
                state.isLoadingSounds = true
                return .run { send in
                    let sounds = await systemSounds.availableSounds()
                    await send(.soundsLoaded(sounds))
                }

            case .soundsLoaded(let sounds):
                state.availableSounds = sounds
                state.isLoadingSounds = false
                return .none

            case .playPreviewSound, .reminderSoundChanged:
                if let sound = state.reminderSound {
                    let volume = state.soundVolume
                    return .run { send in
                        await soundPlayback.playSound(sound, volume)
                    }
                } else {
                    return .none
                }
            }
        }
    }
}
