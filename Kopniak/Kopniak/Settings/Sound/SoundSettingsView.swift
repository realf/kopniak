//
//  SoundSettingsView.swift
//  Sergeant Kopniak
//
//  Created by alf on 12.11.2025.
//

import ComposableArchitecture
import SwiftUI

struct SoundSettingsView: View {
    @Bindable var store: StoreOf<SoundSettingsFeature>

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
                        .accessibilityLabel("Play")
                        .disabled(store.reminderSound == nil)
                    }

                    Slider(
                        value: $store.soundVolume,
                        in: 0...1,
                        label: {
                            Text("Volume")
                        },
                        minimumValueLabel: {
                            Image(systemName: "speaker.fill")
                        },
                        maximumValueLabel: {
                            Image(systemName: "speaker.wave.3.fill")
                        }
                    )
                } header: {
                    Text("Reminder Sound")
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
    let reminderSound = Shared(value: Optional<String>.none)
    let soundVolume = Shared(value: 1.0)
    let store = Store(
        initialState: SoundSettingsFeature.State(
            reminderSound: reminderSound,
            soundVolume: soundVolume
        )
    ) {
        SoundSettingsFeature()
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

    SoundSettingsView(store: store)
}
