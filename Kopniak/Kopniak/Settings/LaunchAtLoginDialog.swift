//
//  LaunchAtLoginDialog.swift
//  Sergeant Kopniak
//
//  Created by alf on 03.10.2025.
//

import SwiftUI

struct LaunchAtLoginDialog: View {
    let onResponse: (Bool?, Bool) -> Void

    var body: some View {
        VStack(spacing: 20) {
            // Icon
            Image(systemName: "calendar.badge.clock")
                .imageScale(.large)
                .foregroundStyle(.brown)
                .font(.system(size: 32))

            // Title
            Text("ENLIST FOR DAILY DUTY?")
                .font(.title2)
                .fontWeight(.bold)

            // Message
            Text(
                """
                Want me to report for duty automatically every time you log in to your Mac?

                I'll be standing by in your menu bar, ready to keep you moving!
                """
            )
            .multilineTextAlignment(.leading)
            .foregroundColor(.secondary)
            .fixedSize(horizontal: false, vertical: true)

            // Buttons
            HStack(spacing: 12) {
                Button("No Thanks") {
                    onResponse(false, false)
                }

                Spacer()

                Button("Ask Later") {
                    onResponse(nil, true)
                }
                .keyboardShortcut(.cancelAction)

                Button("Yes, Sir!") {
                    onResponse(true, false)
                }
                .keyboardShortcut(.defaultAction)
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(30)
        .frame(width: 450)
    }
}

#Preview {
    LaunchAtLoginDialog { enable, askLater in
        print("Enable: \(String(describing: enable)), Ask Later: \(askLater)")
    }
}
