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
        VStack(spacing: 18) {
            // App icon - random Kopniak variant
            Image(store.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 300)
                .cornerRadius(24)
                .padding(20)

            // Title with military styling
            Text(store.title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)

            Spacer()

            // Message
            Text(store.message)
                .font(.title3)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()

            // Buttons
            HStack(spacing: 0) {
                Group {
                    // "At Ease for 10" button
                    Spacer()

                    Button(action: {
                        store.send(.delegate(.snoozeTapped))
                    }) {
                        HStack {
                            Image(
                                systemName:
                                    "10.arrow.trianglehead.counterclockwise"
                            )
                            .imageScale(.large)
                            Text("At Ease for 10")
                                .font(.title3)
                        }
                        .frame(width: 180, height: 32)
                    }

                    Spacer()

                    // "Yes Sir!" button
                    Button(action: {
                        store.send(.delegate(.dismissTapped))
                    }) {
                        HStack {
                            Image(systemName: "checkmark.square")
                                .imageScale(.large)
                            Text("Mission Completed")
                                .font(.title3)
                        }
                        .frame(width: 180, height: 32)
                    }
                    .buttonStyle(.borderedProminent)

                    Spacer()
                }
            }
            .padding(.bottom, 20)
            .padding(.top, 12)
        }
        .padding(20)
        .frame(width: 520)
        .onAppear {
            store.send(.onAppear)
        }
    }
}

#Preview {
    let store = Store(
        initialState: ReminderFeature.State(title: "", message: "")
    ) {
        ReminderFeature()
    } withDependencies: {
        $0.reminderContentSource = ReminderContentSourceDependency(
            titles: ["Listen to my order!"],
            messages: [
                "Time to stretch those muscles, soldier\nYour body is your weapon - keep it sharp!"
            ]
        )
    }
    ReminderView(store: store)
}
