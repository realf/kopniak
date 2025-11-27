//
//  SimpleReminderView.swift
//  Sergeant Kopniak
//
//  Created by alf on 25.11.2025.
//

import ComposableArchitecture
import SwiftUI

struct SimpleReminderView: View {
    let store: StoreOf<ReminderFeature>

    var body: some View {
        VStack(spacing: 20) {
            // Brown chevron icon
            Image(systemName: "chevron.up.2")
                .resizable()
                .foregroundColor(.brown)
                .scaledToFit()
                .frame(width: 50, height: 50)

            // Buttons
            HStack(spacing: 0) {
                Group {
                    Button(action: {
                        store.send(.delegate(.snoozeTapped))
                    }) {
                        Text(
                            "Delay for \(store.snoozeIntervalFormatted)"
                        )
                        .font(.title3)
                        .frame(width: 200, height: 32)
                    }
                    .keyboardShortcut(.cancelAction)

                    Spacer()

                    Button(action: {
                        store.send(.delegate(.dismissTapped))
                    }) {
                        Text("Done")
                            .font(.title3)
                            .frame(width: 200, height: 32)
                    }
                    .buttonStyle(.borderedProminent)
                    .keyboardShortcut(.defaultAction)
                }
            }
        }
        .padding(20)
        .frame(width: 520)
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
                reminderStyle: Shared(value: .simple),
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
        SimpleReminderView(store: store)
    }
#endif
