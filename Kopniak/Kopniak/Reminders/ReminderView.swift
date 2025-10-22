//
//  ReminderView.swift
//  Sergeant Kopniak
//
//  Created by alf on 01.10.2025.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct ReminderFeature {
    // Military-style titles
    private let militaryTitles = [
        "Listen to my order!",
        "Drop and Give Me Twenty!",
        "On Your Feet, Recruit!",
        "Time for Action, Trooper!",
        "Move It, Move It!",
        "Stand at Attention!",
        "Orders from Command!",
        "Attention, Soldier!",
        "Mission Alert!",
        "Posture Command!",
        "Drill Time!",
        "Bootcamp Break!",
        "Move It, Trooper!",
        "Action Stations!",
        "Orders from HQ!",
        "Attention!",
        "Orders from Above!",
    ]

    // Military-style exercise messages
    private let militaryMessages = [
        "Listen up, recruit! Drop that mouse and march in place!",
        "Stand up and stretch, soldier!",
        "At ease… but only for a second. Move it, move it!",
        "Attention! Your spine needs you to report for duty.",
        "Private, your chair’s not the only thing that needs action. Get up!",
        "This is an order! Step away from the screen. Now.",
        "Stand tall, soldier! Hunching is not part of your mission.",
        "Whipping that posture into shape. Let’s move!",
        "Operation: Stretch & Breathe is underway. You’re the star recruit!",
        "Don’t make me come over there. Stretch those limbs!",
        "Break time is now, trooper. Execute a perfect posture drill.",
        "Time for a break, soldier! Drop and give me 20 pushups!",
        "Your eyes need rest! Look away from that screen!",
        "Stand up and march around the room!",
        "Hydration check! Drink some water, private!",
        "Time to stretch those muscles!",
        "Look out the window - that's an order!",
        "Do some jumping jacks, on the double!",
        "Roll those shoulders, soldier!",
        "Time for a quick walk around the base!",
        "Blink those eyes 20 times - that's military precision!",
        "Time to stretch those muscles, soldier! Your body is your weapon - keep it sharp!",
        "Get up and do some jumping jacks! A good soldier is always ready for action!",
        "Stand up and march in place! Sitting too long makes you soft, recruit!",
        "Touch your toes and stretch! Flexibility wins battles, trooper!",
        "Do some push-ups against your desk! Show me what you're made of!",
        "Roll those shoulders back! Posture like a soldier, not a slacker!",
        "Take a walk around the perimeter! Movement keeps the mind sharp!",
        "Stretch those legs, private! Blood flow is essential for peak performance!",
    ]

    let maxRecent = 10

    @ObservableState
    struct State {
        var title: String
        var message: String

        // Recent history to avoid repetition
        var recentTitles: [String] = []
        var recentMessages: [String] = []
    }

    enum Action {
        case delegate(Delegate)
        case onAppear

        enum Delegate {
            case dismissTapped
            case snoozeTapped
        }
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .delegate:
                return .none
            case .onAppear:
                let title = pickRandomTitle(state)
                let message = pickRandomMessage(state)
                state.title = title
                state.message = message
                updateRecentTitle(&state, title: title)
                updateRecentMessage(&state, message: message)
                return .none
            }
        }
    }

    // MARK: - Picking logic that avoids recent repeats
    private func pickRandomTitle(_ state: State) -> String {
        let available = militaryTitles.filter { !state.recentTitles.contains($0) }
        let choice = available.isEmpty ? militaryTitles.randomElement() : available.randomElement()
        return choice ?? "Attention Soldier!"
    }

    private func pickRandomMessage(_ state: State) -> String {
        let available = militaryMessages.filter { !state.recentMessages.contains($0) }
        let choice = available.isEmpty ? militaryMessages.randomElement() : available.randomElement()
        return choice ?? "Time to exercise, soldier!"
    }

    private func updateRecentTitle(_ state: inout State, title: String) {
        state.recentTitles.append(title)
        if state.recentTitles.count > maxRecent {
            state.recentTitles.removeFirst()
        }
    }

    private func updateRecentMessage(_ state: inout State, message: String) {
        state.recentMessages.append(message)
        if state.recentMessages.count > maxRecent {
            state.recentMessages.removeFirst()
        }
    }
}

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
                        Image(systemName: "pause.fill")
                        Text("At Ease for 10")
                            .fontWeight(.semibold)
                    }
                }

                // "Yes Sir!" button
                Button(action: {
                    store.send(.delegate(.dismissTapped))
                }) {
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
        .onAppear {
            store.send(.onAppear)
        }
    }
}

#Preview {
    let store = Store(initialState: ReminderFeature.State(title: "Attention!", message: "Give me 20!")) {
        ReminderFeature()
    }
    ReminderView(store: store)
}
