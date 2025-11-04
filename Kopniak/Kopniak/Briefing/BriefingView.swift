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

    private var holdPositionText: Text {
        Text("\(Image(systemName: "pause.fill")) At Ease")
            .fontWeight(.semibold)
    }

    private var standDownText: Text {
        Text("\(Image(systemName: "stop.fill")) Stand Down")
            .fontWeight(.semibold)
    }

    private var reportForDutyText: Text {
        Text("\(Image(systemName: "play.fill")) Report for Duty")
            .fontWeight(.semibold)
    }

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

            GroupBox {
                VStack(spacing: 20) {
                    Text("LISTEN UP, SOLDIER!")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text(
                        """
                        My name is Sergeant Kopniak and I am your drill instructor.
                        Look for my chevron \(chevron) in your menu bar — those twin stripes mean I’m watching. Click it to access your orders.
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

                    Text(
                        """
                        I’ll bark orders every __\(Int(store.reminderInterval / 60.0))__ minutes — time for a movement break!\n
                        \(reportForDutyText) when you’re ready to start your fitness regimen.
                        \(holdPositionText) to temporarily pause reminders (keeps your place in line).
                        \(standDownText) to completely stop and dismiss the drill sergeant.\n
                        When I call, you drop and give me 20… or stretch and go have some water!

                        My job? Keep your spine straight and your circulation flowing. Your chair is NOT a permanent duty station!

                        MOVE OUT!
                        """
                    )
                    .lineSpacing(6)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                }
                .padding()
            }
            .imageScale(.large)

            switch store.remindersStatus {
            case .on:
                HStack(spacing: 12) {
                    Button(action: {
                        store.send(.delegate(.stopRemindersTapped))
                    }) {
                        HStack {
                            Image(systemName: "stop.fill")
                                .foregroundStyle(Color.red)
                            Text("Stand Down")
                        }
                        .frame(width: buttonWidth)
                    }

                    Button(action: {
                        store.send(.delegate(.pauseRemindersTapped))
                    }) {
                        HStack {
                            Image(systemName: "pause.fill")
                                .foregroundStyle(Color.orange)
                            Text("At Ease")
                        }
                        .frame(width: buttonWidth)
                    }

                    Button(action: {
                        store.send(.delegate(.restartRemindersTapped))
                    }) {
                        HStack {
                            Image(systemName: "restart")
                                .foregroundStyle(Color.blue)
                            Text("Reissue Orders")
                        }
                        .frame(width: buttonWidth)
                    }
                }
                .imageScale(.large)
            case .paused:
                HStack(spacing: 12) {
                    Button(action: {
                        store.send(.delegate(.stopRemindersTapped))
                    }) {
                        HStack {
                            Image(systemName: "stop.fill")
                                .foregroundStyle(Color.red)
                            Text("Stand Down")
                        }
                        .frame(width: buttonWidth)
                    }

                    Button(action: {
                        store.send(.delegate(.resumeRemindersTapped))
                    }) {
                        HStack {
                            Image(systemName: "play.fill")
                                .foregroundStyle(Color.green)
                            Text("Resume Duty")
                        }
                        .frame(width: buttonWidth)
                    }

                    Button(action: {
                        store.send(.delegate(.restartRemindersTapped))
                    }) {
                        HStack {
                            Image(systemName: "restart")
                                .foregroundStyle(Color.blue)
                            Text("Reissue Orders")
                        }
                        .frame(width: buttonWidth)
                    }
                }
                .imageScale(.large)
            case .off:
                Button(action: { store.send(.delegate(.startRemindersTapped)) })
                {
                    HStack {
                        Image(systemName: "play.fill")
                            .foregroundStyle(Color.blue)
                        Text("Report for Duty")
                    }
                    .frame(width: buttonWidth)
                }
                .imageScale(.large)
            }
            Divider()
            HStack {
                Spacer()
                Button {
                    store.send(.delegate(.settingsTapped))
                } label: {
                    HStack {
                        Image(systemName: "gear")
                        Text("Settings…")
                    }
                    .frame(width: buttonWidth)
                }
            }
            .imageScale(.large)
        }
        .padding(32)
        .frame(width: 600)
        .fixedSize()
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
