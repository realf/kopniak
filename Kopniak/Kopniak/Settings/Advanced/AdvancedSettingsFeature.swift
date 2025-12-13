//
//  AdvancedSettingsFeature.swift
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
struct AdvancedSettingsFeature {
    @Dependency(\.soundPlayback) var soundPlayback
    @Dependency(\.systemSounds) var systemSounds

    @ObservableState
    struct State {
        var availableSounds: [String] = []
        var isLoadingSounds = true

        var soundOptions: [SoundOption] {
            // Build sound options, ensuring current selection is included even if not yet loaded
            var options: [SoundOption] = [
                SoundOption(label: String(localized: "None", comment: "Sound option"), soundName: nil)
            ]

            options.append(
                contentsOf: availableSounds.map {
                    SoundOption(label: $0, soundName: $0)
                }
            )

            return options
        }

        @Shared var menuIconTimeDisplay: TimeDisplaySetting
        @Shared var reminderSound: String?
        @Shared var reminderStyle: ReminderStyle
        @Shared var showMenuBarIcon: Bool
        @Shared var soundVolume: Double

        init(
            menuIconTimeDisplay: Shared<TimeDisplaySetting>,
            reminderSound: Shared<String?>,
            reminderStyle: Shared<ReminderStyle>,
            showMenuBarIcon: Shared<Bool>,
            soundVolume: Shared<Double>
        ) {
            _menuIconTimeDisplay = menuIconTimeDisplay
            _reminderSound = reminderSound
            _reminderStyle = reminderStyle
            _showMenuBarIcon = showMenuBarIcon
            _soundVolume = soundVolume
        }
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
                    let sounds = systemSounds.availableSounds()
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
