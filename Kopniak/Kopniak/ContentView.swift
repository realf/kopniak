//
//  ContentView.swift
//  Sergeant Kopniak
//
//  Created by alf on 01.10.2025.
//

import SwiftUI

struct ContentView: View {
    @Environment(ReminderManager.self) private var reminderManager

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

                    let yesSir = Text(
                        "\(Image(systemName: "checkmark.shield")) Yes Sir!"
                    )
                    .fontWeight(.semibold)
                    let atEaseFor10 = Text(
                        "\(Image(systemName: "pause.fill")) At Ease for 10"
                    )
                    .fontWeight(.semibold)
                    let standDown = Text(
                        "\(Image(systemName: "stop.fill")) Stand Down"
                    )
                    .fontWeight(.semibold)
                    let reportForDuty = Text(
                        "\(Image(systemName: "play.fill")) Report for Duty"
                    )
                    .fontWeight(.semibold)

                    Text(
                        """
                        • I'll bark orders every __\(reminderManager.reminderIntervalMinutes)__ minutes — time for a movement break!
                        • \(reportForDuty) when you're ready to soldier on.
                        • Use \(standDown) to pause me (but don't get too comfortable).
                        • When I call, you drop and give me 20... or stretch and go have some water!
                        • Hit \(yesSir) when you've completed your mission.
                        • Need more time? \(atEaseFor10) buys you 10 minutes.

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
                Button(action: { reminderManager.stopReminders() }) {
                    HStack {
                        Image(systemName: "stop.fill")
                            .foregroundStyle(Color.red)
                        Text("Stand Down")
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
