//
//  ContentView.swift
//  Sergeant Kopniak
//
//  Created by alf on 01.10.2025.
//

import SwiftUI

struct ContentView: View {
    @Environment(ReminderManager.self) private var reminderManager

    // MARK: - Computed Properties

    private var yesSirText: Text {
        Text("\(Image(systemName: "checkmark.shield")) Yes Sir!")
            .fontWeight(.semibold)
    }

    private var atEaseText: Text {
        Text("\(Image(systemName: "pause.fill")) At Ease for 10")
            .fontWeight(.semibold)
    }

    private var holdPositionText: Text {
        Text("\(Image(systemName: "pause.circle")) Hold Position")
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

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "chevron.up.2")
                .imageScale(.large)
                .foregroundStyle(.brown)
                .font(.system(size: 32))

            GroupBox {
                VStack(spacing: 20) {
                    Text("ATTENTION, RECRUIT!")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text(
                        """
                        Look for my chevron in your status bar — those twin stripes mean I'm watching. Click it to access your orders.
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
                        • I'll bark orders every __\(reminderManager.reminderIntervalMinutes)__ minutes — time for a movement break!
                        • \(reportForDutyText) when you're ready to start your fitness regimen.
                        • Use \(holdPositionText) to temporarily pause reminders (keeps your place in line).
                        • Use \(standDownText) to completely stop and dismiss the drill sergeant.
                        • When I call, you drop and give me 20... or stretch and go have some water!
                        • Hit \(yesSirText) when you've completed your mission.
                        • Need more time? \(atEaseText) buys you 10 minutes.

                        My job? Keep your spine straight and your circulation flowing. Your chair is NOT a permanent duty station!

                        You ready to join the Anti-Slouch Squadron and whip that body back into shape?

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

            if reminderManager.isActive {
                HStack(spacing: 12) {
                    Button(action: { reminderManager.pauseReminders() }) {
                        HStack {
                            Image(systemName: "pause.circle")
                                .foregroundStyle(Color.orange)
                            Text("Hold Position")
                        }
                    }
                    .disabled(!reminderManager.canPause)

                    Button(action: { reminderManager.stopReminders() }) {
                        HStack {
                            Image(systemName: "stop.fill")
                                .foregroundStyle(Color.red)
                            Text("Stand Down")
                        }
                    }
                }
            } else if reminderManager.canResume {
                HStack(spacing: 12) {
                    Button(action: { reminderManager.resumeReminders() }) {
                        HStack {
                            Image(systemName: "play.fill")
                                .foregroundStyle(Color.green)
                            Text("Resume Duty")
                        }
                    }

                    Button(action: { reminderManager.stopReminders() }) {
                        HStack {
                            Image(systemName: "stop.fill")
                                .foregroundStyle(Color.red)
                            Text("Stand Down")
                        }
                    }
                }
            } else {
                Button(action: { reminderManager.startReminders() }) {
                    HStack {
                        Image(systemName: "play.fill")
                            .foregroundStyle(Color.blue)
                        Text("Report for Duty")
                    }
                }
            }
        }
        .padding(32)
        .frame(width: 600)
        .fixedSize()
    }
}

#Preview {
    let settingsManager = SettingsManager()
    ContentView()
        .environment(ReminderManager(settingsManager: settingsManager))
}
