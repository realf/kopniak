//
//  ReminderView.swift
//  Sergeant Kopniak
//
//  Created by alf on 01.10.2025.
//

import ComposableArchitecture
import SwiftUI

struct ReminderView: View {
    let store: StoreOf<ReminderFeature>

    var body: some View {
        VStack(spacing: 16) {
            // Title with military styling
            Text(store.title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)

            // Message
            Text(store.message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)
                .fixedSize(horizontal: false, vertical: true)

            // Buttons
            HStack(spacing: 12) {
                Spacer()

                // "At Ease for 10" button
                Button(action: {
                    store.send(.delegate(.snoozeTapped))
                }) {
                    HStack {
                        Image(
                            systemName: "10.arrow.trianglehead.counterclockwise"
                        )
                        Text("At Ease for 10")
                            .fontWeight(.semibold)
                    }
                }

                // "Yes Sir!" button
                Button(action: {
                    store.send(.delegate(.dismissTapped))
                }) {
                    HStack {
                        Image(systemName: "checkmark.square")
                        Text("Yes Sir!")
                            .fontWeight(.semibold)
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(20)
        .frame(width: 400)
        .onAppear {
            store.send(.onAppear)
        }
    }
}

#Preview {
    let store = Store(
        initialState: ReminderFeature.State(
            title: "Attention!",
            message: "Give me 20!"
        )
    ) {
        ReminderFeature()
    }
    ReminderView(store: store)
}
