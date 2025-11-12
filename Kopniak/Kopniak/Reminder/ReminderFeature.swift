//
//  ReminderFeature.swift
//  Sergeant Kopniak
//
//  Created by alf on 23.10.2025.
//

import ComposableArchitecture
import Foundation

struct ReminderContentSource {
    // Military-style titles
    static let militaryTitles = [
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
    static let militaryMessages = [
        "Drop that mouse and march in place!",
        "Stand up and stretch, soldier!",
        "Your spine needs you to report for duty.",
        "Private, your chair’s not the only thing that needs action.\nGet up!",
        "This is an order!\nStep away from the screen. Now!",
        "Stand tall, soldier!\nHunching is not part of your mission.",
        "Whipping that posture into shape.\nLet’s move!",
        "Operation: Stretch & Breathe is underway.\nYou’re the star recruit!",
        "Don’t make me come over there.\nStretch those limbs!",
        "Break time is now, trooper.\nExecute a perfect posture drill.",
        "Time for a break, soldier!\nDrop and give me 20 pushups!",
        "Your eyes need rest!\nLook away from that screen!",
        "Stand up and march around the room!",
        "Hydration check!\nDrink some water, private!",
        "Time to stretch those muscles!",
        "Look out the window - that’s an order!",
        "Do some jumping jacks, on the double!",
        "Roll those shoulders, soldier!",
        "Time for a quick walk around the base!",
        "Blink those eyes 20 times - that’s military precision!",
        "Time to stretch those muscles, soldier!\nYour body is your weapon - keep it sharp!",
        "Get up and do some jumping jacks!\nA good soldier is always ready for action!",
        "Stand up and march in place!\nSitting too long makes you soft, recruit!",
        "Touch your toes and stretch!\nFlexibility wins battles, trooper!",
        "Do some push-ups against your desk!\nShow me what you’re made of!",
        "Roll those shoulders back!\nPosture like a soldier, not a slacker!",
        "Take a walk around the perimeter!\nMovement keeps the mind sharp!",
        "Stretch those legs, private!\nBlood flow is essential for peak performance!",
    ]

    static let sgtImages = ["Kopniak1", "Kopniak2", "Kopniak3", "Kopniak4"]
    static let catImages = ["KopniakTheCat1"]
}

@Reducer
struct ReminderFeature {
    @Dependency(\.withRandomNumberGenerator) var withRandomNumberGenerator
    @Dependency(\.reminderContentSource) var reminderContentSource
    @Dependency(\.soundPlayback) var soundPlayback

    let maxRecent = 10

    @ObservableState
    struct State {
        var title: String = ""
        var message: String = ""
        var imageName: String = "Kopniak1"

        // Recent history to avoid repetition
        var recentTitles: [String] = []
        var recentMessages: [String] = []

        @Shared(.appStorage("dismissReminderStreakCount"))
        var dismissReminderStreakCount = 0

        @Shared var snoozeInterval: TimeInterval
        @Shared var reminderSound: String?
        @Shared var soundVolume: Double

        var snoozeIntervalFormatted: String {
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.minute]
            return formatter.string(from: snoozeInterval) ?? "0"
        }

        init(
            snoozeInterval: Shared<TimeInterval>
        ) {
            _snoozeInterval = snoozeInterval

            let reminderSound = Shared(
                wrappedValue: Optional<String>.none,
                .appStorage("reminderSound")
            )
            let soundVolume = Shared(
                wrappedValue: 1.0,
                .appStorage("soundVolume")
            )

            _reminderSound = reminderSound
            _soundVolume = soundVolume
        }
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
            case .delegate(let action):
                return reduceDelegateAction(&state, action: action)

            case .onAppear:
                let title = pickRandomTitle(state)
                let message = pickRandomMessage(state)
                let imageName = pickRandomImage(state)
                state.title = title
                state.message = message
                state.imageName = imageName
                updateRecentTitle(&state, title: title)
                updateRecentMessage(&state, message: message)

                if let sound = state.reminderSound {
                    let volume = state.soundVolume
                    return .run { send in
                        // Play sound if configured
                        await soundPlayback.playSound(sound, volume)
                    }
                } else {
                    return .none
                }
            }
        }
    }

    private func reduceDelegateAction(
        _ state: inout State,
        action: Action.Delegate
    ) -> Effect<Action> {
        switch action {
        case .dismissTapped:
            state.$dismissReminderStreakCount.withLock { $0 += 1 }
            return .none
        case .snoozeTapped:
            state.$dismissReminderStreakCount.withLock { $0 = 0 }
            return .none
        }
    }

    // MARK: - Random image picking logic

    private func pickRandomImage(_ state: State) -> String {
        let count = state.dismissReminderStreakCount
        return withRandomNumberGenerator { [reminderContentSource] generator in
            return if count > 0 && count % 10 == 0 {
                reminderContentSource.catImages.randomElement(using: &generator)
                    ?? "KopniakTheCat1"
            } else {
                reminderContentSource.sgtImages.randomElement(using: &generator)
                    ?? "Kopniak1"
            }
        }
    }

    // MARK: - Picking logic that avoids recent repeats

    private func pickRandomTitle(_ state: State) -> String {
        let available = reminderContentSource.titles.filter {
            !state.recentTitles.contains($0)
        }

        return withRandomNumberGenerator { [reminderContentSource] generator in
            (available.isEmpty
                ? reminderContentSource.titles.randomElement(using: &generator)
                : available.randomElement(using: &generator))
                ?? "Time for Action, Trooper!"
        }
    }

    private func pickRandomMessage(_ state: State) -> String {
        let available = reminderContentSource.messages.filter {
            !state.recentMessages.contains($0)
        }
        return withRandomNumberGenerator { [reminderContentSource] generator in
            (available.isEmpty
                ? reminderContentSource.titles.randomElement(using: &generator)
                : available.randomElement(using: &generator))
                ?? "Time to stretch those muscles, soldier\nYour body is your weapon - keep it sharp!"
        }
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

// MARK: - ReminderContentSource dependency.
nonisolated struct ReminderContentSourceDependency {
    let titles: [String]
    let messages: [String]
    let sgtImages: [String]
    let catImages: [String]
}

// Conform to DependencyKey to provide a live and preview implementation of the interface.
extension ReminderContentSourceDependency: DependencyKey {
    static let liveValue = Self(
        titles: ReminderContentSource.militaryTitles,
        messages: ReminderContentSource.militaryMessages,
        sgtImages: ReminderContentSource.sgtImages,
        catImages: ReminderContentSource.catImages
    )
}

// Register the dependency within DependencyValues.
extension DependencyValues {
    var reminderContentSource: ReminderContentSourceDependency {
        get { self[ReminderContentSourceDependency.self] }
        set { self[ReminderContentSourceDependency.self] = newValue }
    }
}
