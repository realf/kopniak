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
        VStack {
            Image(systemName: "chevron.up.2")
                .foregroundStyle(Color.accentColor)
                .imageScale(.large)
                .font(.system(size: 40))
                .bold()
                .symbolEffect(
                    .wiggle.byLayer,
                    options: .repeat(.periodic(delay: 1.0)).speed(0.5)
                )
                .padding(.top, 20)
                .accessibilityLabel("It's a break time")

            // Buttons
            HStack(spacing: 0) {
                Group {
                    Spacer()

                    Button(action: {
                        store.send(
                            .delegate(.snoozeTapped),
                            animation: .easeInOut
                        )
                    }) {
                        Image(systemName: "zzz")
                            .foregroundStyle(Color.secondary)
                            .roundButtonLabel()
                    }
                    .help("Snooze")

                    Spacer()

                    Button(action: {
                        store.send(
                            .delegate(.dismissTapped),
                            animation: .easeInOut
                        )
                    }) {
                        Image(systemName: "checkmark")
                            .foregroundStyle(Color.accentColor)
                            .roundButtonLabel()
                    }
                    .help("Done")

                    Spacer()
                }
                .buttonStyle(.plain)
                .imageScale(.large)
                .padding()
            }
        }
        .padding(20)
        .frame(width: 300)
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
