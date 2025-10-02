//
//  ReminderView.swift
//  Sergeant Kopniak
//
//  Created by alf on 01.10.2025.
//

import SwiftUI

struct ReminderView: View {
    let title: String
    let message: String
    let onDismiss: () -> Void
    let onSnooze: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            // Title with military styling
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)

            // Message
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)
                .fixedSize(horizontal: false, vertical: true)

            // Buttons
            HStack(spacing: 12) {
                Spacer()

                // "At Ease for 10" button
                Button(action: onSnooze) {
                    HStack {
                        Image(systemName: "pause.fill")
                        Text("At Ease for 10")
                            .fontWeight(.semibold)
                    }
                }

                // "Yes Sir!" button
                Button(action: onDismiss) {
                    HStack {
                        Image(systemName: "checkmark.shield")
                        Text("Yes Sir!")
                            .fontWeight(.semibold)
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(20)
        .frame(width: 400)
    }
}

#Preview {
    ReminderView(
        title: "Attention Soldier!",
        message:
            "Time to stretch those muscles, soldier! Your body is your weapon - keep it sharp!",
        onDismiss: {},
        onSnooze: {}
    )
    .frame(width: 400, height: 300)
}
