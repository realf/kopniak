//
//  LaunchAtLoginView.swift
//  Sergeant Kopniak
//
//  Created by alf on 03.10.2025.
//

import ComposableArchitecture
import SwiftUI

struct LaunchAtLoginView: View {
    var store: StoreOf<LaunchAtLoginFeature>

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
                Spacer()

                Button {
                    store.send(.noTapped)
                } label: {
                    Text("No, Sir!")
                }

                Button("Yes, Sir!") {
                    store.send(.yesTapped)
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
    LaunchAtLoginView(
        store: Store(
            initialState: LaunchAtLoginFeature.State(),
            reducer: {
                LaunchAtLoginFeature()
            }
        )
    )
}
