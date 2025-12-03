//
//  AdvancedSettingsView.swift
//  Sergeant Kopniak
//
//  Created by alf on 12.11.2025.
//

import ComposableArchitecture
import SwiftUI

struct AdvancedSettingsView: View {
    @Bindable var store: StoreOf<AdvancedSettingsFeature>

    var body: some View {
        HStack {
            Spacer()
            Form {
                Section {
                    HStack {
                        Picker(
                            selection: $store.reminderSound,
                            label: Text("Reminder sound")
                        ) {
                            if !store.isLoadingSounds {
                                ForEach(store.soundOptions, id: \.soundName) {
                                    option in
                                    Text(option.label)
                                }
                            }
                        }
                        .onChange(of: store.reminderSound) {
                            store.send(.reminderSoundChanged)
                        }

                        Button {
                            store.send(.playPreviewSound)
                        } label: {
                            Image(systemName: "play.circle")
                                .imageScale(.large)
                        }
                        .buttonStyle(.borderless)
                        .help("Play")
                        .disabled(store.reminderSound == nil)
                    }
                    Slider(
                        value: $store.soundVolume,
                        in: 0...1,
                        label: {
                            Text("Reminder volume")
                        },
                        minimumValueLabel: {
                            Image(systemName: "speaker.fill")
                        },
                        maximumValueLabel: {
                            Image(systemName: "speaker.wave.3.fill")
                        }
                    )
                } header: {
                    Text("Sound Effects")
                }

                // Menu Icon Section
                Section {
                    Toggle(
                        "Show menu bar icon",
                        isOn: $store.showMenuBarIcon
                    )

                    Picker(
                        selection: Binding(
                            get: { store.menuIconTimeDisplay },
                            set: { newValue in store.menuIconTimeDisplay = newValue }
                        ),
                        label: Text("Display remaining time as:")
                    ) {
                        ForEach(TimeDisplaySetting.allCases) { setting in
                            switch setting {
                            case .short:
                                Text("Minutes only (9 min)")
                            case .positional:
                                Text("Minutes and Seconds (09:41)")
                            case .none:
                                Text("Not shown")
                            }
                        }
                    }
                    .disabled(!store.showMenuBarIcon)
                } header: {
                    Text("Menu Bar Icon")
                }
            }
            .formStyle(.grouped)
            Spacer()
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}

#Preview {
    let menuIconTimeDisplay = Shared(value: TimeDisplaySetting.short)
    let reminderSound = Shared(value: Optional<String>.none)
    let reminderStyle = Shared(value: ReminderStyle.simple)
    let showMenuBarIcon = Shared(value: false)
    let soundVolume = Shared(value: 1.0)
    let store = Store(
        initialState: AdvancedSettingsFeature.State(
            menuIconTimeDisplay: menuIconTimeDisplay,
            reminderSound: reminderSound,
            reminderStyle: reminderStyle,
            showMenuBarIcon: showMenuBarIcon,
            soundVolume: soundVolume
        )
    ) {
        AdvancedSettingsFeature()
    } withDependencies: {
        $0.systemSounds = SystemSoundsDependency(
            availableSounds: {
                [
                    "Basso",
                    "Blow",
                    "Bottle",
                    "Frog",
                    "Funk",
                    "Glass",
                    "Hero",
                    "Morse",
                    "Ping",
                    "Pop",
                    "Purr",
                    "Sosumi",
                    "Submarine",
                    "Tink",
                ]
            }
        )
    }

    AdvancedSettingsView(store: store)
}
