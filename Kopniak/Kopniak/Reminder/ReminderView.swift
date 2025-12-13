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
                .shadow(color: .brown, radius: 10)
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
                    Spacer()

                    Button(action: {
                        store.send(.delegate(.snoozeTapped))
                    }) {
                        HStack {
                            Image(
                                systemName:
                                    "stopwatch"
                            )
                            .imageScale(.large)
                            Text(
                                "Will comply in \(store.snoozeIntervalFormatted)!"
                            )
                            .font(.title3)
                        }
                        .frame(width: 200, height: 32)
                    }
                    .keyboardShortcut(.cancelAction)

                    Spacer()

                    Button(action: {
                        store.send(.delegate(.dismissTapped))
                    }) {
                        HStack {
                            Image(systemName: "checkmark.square")
                                .imageScale(.large)
                            Text("Done")
                                .font(.title3)
                        }
                        .frame(width: 200, height: 32)
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
    private struct RNG: RandomNumberGenerator {
        mutating func next() -> UInt64 { 0 }
    }

    #Preview {
        let store = Store(
            initialState: ReminderFeature.State(
                reminderStyle: Shared(value: .kopniak),
                snoozeInterval: Shared(value: 600.0)
            )
        ) {
            ReminderFeature()
        } withDependencies: {
            $0.reminderContentSource = ReminderContentSourceDependency(
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
