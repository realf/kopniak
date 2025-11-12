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
                .interpolation(.high)
                .scaledToFit()
                .frame(width: 300, height: 300)
                .cornerRadius(40)
                .shadow(color: .brown, radius: 20)
                .padding(20)

            Spacer()

            // Message
            Text(store.message)
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

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
                                    "arrow.trianglehead.counterclockwise"
                            )
                            .imageScale(.large)
                            Text(
                                "At Ease for \(store.snoozeIntervalFormatted)"
                            )
                            .font(.title3)
                        }
                        .frame(width: 180, height: 32)
                    }
                    .keyboardShortcut(.cancelAction)

                    Spacer()

                    // "Mission Completed" button
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
                    .keyboardShortcut(.defaultAction)

                    Spacer()
                }
            }
            .padding(.bottom, 20)
            .padding(.top, 12)
        }
        .padding(20)
        .frame(width: 520)
        .frame(minHeight: 600)
        .onAppear {
            store.send(.onAppear)
        }
    }
}

#if DEBUG
    private nonisolated struct RNG: RandomNumberGenerator {
        mutating func next() -> UInt64 { 0 }
    }

    #Preview {
        let store = Store(
            initialState: ReminderFeature.State(
                snoozeInterval: Shared(value: 1.0)
            )
        ) {
            ReminderFeature()
        } withDependencies: {
            $0.reminderContentSource = ReminderContentSourceDependency(
                titles: ["Listen to my order!"],
                messages: [
                    "Time to stretch those muscles, soldier\nYour body is your weapon - keep it sharp!"
                ],
                sgtImages: ["Kopniak1"],
                catImages: ["KopniakTheCat1"]
            )

            $0.withRandomNumberGenerator = WithRandomNumberGenerator(RNG())
        }
        ReminderView(store: store)
    }
#endif
