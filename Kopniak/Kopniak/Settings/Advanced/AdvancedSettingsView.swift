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
                // Appearance Section
                Section {
                    Picker(
                        selection: $store.reminderStyle,
                        label: Text("Reminder style")
                    ) {
                        ForEach(ReminderStyle.allCases) { style in
                            Text(style.displayName).tag(style)
                        }
                    }

                    Toggle(
                        "Show main window when Kopniak opens",
                        isOn: $store.showMainWindowAtLaunch
                    )
                } header: {
                    Text("Appearance")
                }

                // Sound Effects Section
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
                        label: Text("Time format")
                    ) {
                        ForEach(TimeDisplaySetting.allCases) { setting in
                            switch setting {
                            case .short:
                                Text("Short")
                            case .positional:
                                Text("Positional")
                            case .none:
                                Text("None")
                            }
                        }
                    }
                } header: {
                    Text("Menu Icon")
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
    let showMainWindowAtLaunch = Shared(value: true)
    let showMenuBarIcon = Shared(value: false)
    let soundVolume = Shared(value: 1.0)
    let store = Store(
        initialState: AdvancedSettingsFeature.State(
            menuIconTimeDisplay: menuIconTimeDisplay,
            reminderSound: reminderSound,
            reminderStyle: reminderStyle,
            showMainWindowAtLaunch: showMainWindowAtLaunch,
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
