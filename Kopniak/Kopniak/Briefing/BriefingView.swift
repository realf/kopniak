//
//  BriefingView.swift
//  Sergeant Kopniak
//
//  Created by alf on 01.10.2025.
//

import ComposableArchitecture
import SwiftUI

struct BriefingView: View {
    var store: StoreOf<BriefingFeature>

    // MARK: - Computed Properties

    private var chevron: Text {
        Text("\(Image(systemName: "chevron.up.2"))")
            .fontWeight(.semibold)
    }

    let buttonWidth = 120.0

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "chevron.up.2")
                .imageScale(.large)
                .foregroundStyle(.brown)
                .font(.largeTitle)

            VStack(spacing: 20) {
                Text("LISTEN UP, SOLDIER!")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text(
                    """
                    My name is Sergeant Kopniak and I am your drill instructor.
                    I am here to give you a kick in the butt so you don't forget to take a break from the computer.
                    Look for my chevron \(chevron) in your menu bar — those twin stripes mean I'm watching.
                    Click it to access your orders.
                    """
                )
                .font(.headline)
                .foregroundColor(.secondary)
                .lineSpacing(6)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)

                Divider()

                Text("MISSION BRIEFING")
                    .font(.title2)
                    .fontWeight(.bold)

                VStack(alignment: .leading, spacing: 8) {
                    Text(
                        "I'll bark orders every __\(store.reminderIntervalFormatted)__ — time for a movement break!"
                    )

                    HStack(alignment: .center, spacing: 0) {
                        Image(systemName: "play.fill")
                            .frame(width: 30)
                        Text("Go")
                            .fontWeight(.semibold)
                        Text(
                            " when you're ready to start your fitness regimen."
                        )
                    }

                    HStack(alignment: .center, spacing: 0) {
                        Image(systemName: "pause.fill")
                            .frame(width: 30)
                        Text("Halt")
                            .fontWeight(.semibold)
                        Text(
                            " to temporarily pause reminders (keeps your place in line)."
                        )
                    }

                    HStack(alignment: .center, spacing: 0) {
                        Image(systemName: "stop.fill")
                            .frame(width: 30)
                        Text("Dismissed")
                            .fontWeight(.semibold)
                        Text(
                            " to completely stop and dismiss the drill sergeant."
                        )
                    }

                    HStack(alignment: .center, spacing: 0) {
                        Image(systemName: "backward.end.fill")
                            .frame(width: 30)
                        Text("Say Again")
                            .fontWeight(.semibold)
                        Text(
                            " to restart reminders."
                        )
                    }

                    Text(
                        """
                        \nWhen I call, you drop and give me 20… or stretch and go have some water!

                        My job? Keep your spine straight and your mind clear. Your chair is NOT a permanent duty station!

                        MOVE OUT!
                        """
                    )
                }
                .lineSpacing(6)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
            .background(.regularMaterial)
            .cornerRadius(20)
            .shadow(color: .brown, radius: 20)
            .padding()

            switch store.remindersStatus {
            case .on:
                HStack(spacing: 12) {
                    Button(action: {
                        store.send(.delegate(.stopRemindersTapped))
                    }) {
                        HStack {
                            Image(systemName: "stop.fill")
                                .foregroundStyle(Color.red)
                            Text("Dismissed")
                        }
                        .frame(width: buttonWidth)
                        .padding(.vertical, 8)
                    }

                    Button(action: {
                        store.send(.delegate(.pauseRemindersTapped))
                    }) {
                        HStack {
                            Image(systemName: "pause.fill")
                                .foregroundStyle(Color.orange)
                            Text("Halt")
                        }
                        .frame(width: buttonWidth)
                        .padding(.vertical, 8)
                    }

                    Button(action: {
                        store.send(.delegate(.restartRemindersTapped))
                    }) {
                        HStack {
                            Image(systemName: "backward.end.fill")
                                .foregroundStyle(Color.blue)
                            Text("Say Again")
                        }
                        .frame(width: buttonWidth)
                        .padding(.vertical, 8)
                    }
                }
            case .paused:
                HStack(spacing: 12) {
                    Button(action: {
                        store.send(.delegate(.stopRemindersTapped))
                    }) {
                        HStack {
                            Image(systemName: "stop.fill")
                                .foregroundStyle(Color.red)
                            Text("Dismissed")
                        }
                        .frame(width: buttonWidth)
                        .padding(.vertical, 8)
                    }

                    Button(action: {
                        store.send(.delegate(.resumeRemindersTapped))
                    }) {
                        HStack {
                            Image(systemName: "play.fill")
                                .foregroundStyle(Color.green)
                            Text("Go")
                        }
                        .frame(width: buttonWidth)
                        .padding(.vertical, 8)
                    }

                    Button(action: {
                        store.send(.delegate(.restartRemindersTapped))
                    }) {
                        HStack {
                            Image(systemName: "backward.end.fill")
                                .foregroundStyle(Color.blue)
                            Text("Say Again")
                        }
                        .frame(width: buttonWidth)
                        .padding(.vertical, 8)
                    }
                }
            case .off:
                Button(action: { store.send(.delegate(.startRemindersTapped)) })
                {
                    HStack {
                        Image(systemName: "play.fill")
                            .foregroundStyle(Color.blue)
                        Text("Go")
                    }
                    .frame(width: buttonWidth)
                    .padding(.vertical, 8)
                }
            }
            Divider()
            HStack {
                Spacer()
                Button {
                    store.send(.delegate(.settingsTapped))
                } label: {
                    Image(systemName: "gear")
                        .padding(.vertical, 8)
                }
                .accessibilityLabel("Settings")
            }
        }
        .imageScale(.large)
        .padding(32)
        .frame(width: 700)
    }
}

#Preview {
    let store = Store(
        initialState: BriefingFeature.State(
            reminderInterval: Shared(value: 60.0 * 60),
            remindersStatus: Shared(value: .on)
        )
    ) {
        BriefingFeature()
    }
    BriefingView(store: store)
}
