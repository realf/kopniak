//
//  ReminderFeature.swift
//  Sergeant Kopniak
//
//  Created by alf on 23.10.2025.
//

import ComposableArchitecture
import Foundation

struct ReminderContentSource {
    // Military-style exercise messages
    static let militaryMessages = [
        String(localized: "Blink those eyes 20 times - that’s military precision!"),
        String(localized: "Break time is now, trooper.\nExecute a perfect posture drill."),
        String(localized: "Do some push-ups against your desk!\nShow me what you’re made of!"),
        String(localized: "Don’t make me come over there.\nStretch those limbs!"),
        String(localized: "Drop that mouse and march in place!"),
        String(localized: "Get up and do some jumping jacks!\nA good soldier is always ready for action!"),
        String(localized: "Hydration check!\nDrink some water, private!"),
        String(localized: "Look out the window - that’s an order!"),
        String(localized: "Operation: Stretch is underway.\nYou’re the star recruit!"),
        String(localized: "Private, your chair’s not the only thing that needs action.\nGet up!"),
        String(localized: "Roll those shoulders back!\nPosture like a soldier, not a slacker!"),
        String(localized: "Stand tall, soldier!\nHunching is not part of your mission."),
        String(localized: "Stand up and march around the room!\nSitting too long makes you soft, recruit!"),
        String(localized: "Stand up and stretch, soldier!"),
        String(localized: "Stretch those legs, private!\nBlood flow is essential for peak performance!"),
        String(localized: "Take a walk around the perimeter!\nMovement keeps the mind sharp!"),
        String(localized: "This is an order!\nStep away from the screen. Now!"),
        String(localized: "Time for a break, soldier!\nDrop and give me 20 pushups!"),
        String(localized: "Time for a quick walk around the base!"),
        String(localized: "Time to stretch those muscles, soldier!\nYour body is your weapon - keep it sharp!"),
        String(localized: "Touch your toes and stretch!\nFlexibility wins battles, trooper!"),
        String(localized: "Whip that posture into shape.\nLet’s move!"),
        String(localized: "Your eyes need rest!\nLook away from that screen!"),
        String(localized: "Your spine needs immediate action, soldier!"),
    ]

    static let sgtImages = [""]
    static let catImages = [""]
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

        @Shared var reminderStyle: ReminderStyle
        @Shared var snoozeInterval: TimeInterval
        @Shared var reminderSound: String?
        @Shared var soundVolume: Double

        var snoozeIntervalFormatted: String {
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.minute]
            formatter.unitsStyle = .short
            return formatter.string(from: snoozeInterval) ?? "0"
        }

        init(
            reminderStyle: Shared<ReminderStyle>,
            snoozeInterval: Shared<TimeInterval>
        ) {
            _reminderStyle = reminderStyle
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
                let message = pickRandomMessage(state)
                let imageName = pickRandomImage(state)
                state.message = message
                state.imageName = imageName
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

    private func pickRandomMessage(_ state: State) -> String {
        let available = reminderContentSource.messages.filter {
            !state.recentMessages.contains($0)
        }
        return withRandomNumberGenerator { [reminderContentSource] generator in
            (available.isEmpty
                ? reminderContentSource.messages.randomElement(using: &generator)
                : available.randomElement(using: &generator))
                ?? "Time to stretch those muscles, soldier\nYour body is your weapon - keep it sharp!"
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
struct ReminderContentSourceDependency {
    let messages: [String]
    let sgtImages: [String]
    let catImages: [String]
}

// Conform to DependencyKey to provide a live and preview implementation of the interface.
extension ReminderContentSourceDependency: DependencyKey {
    static let liveValue = Self(
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
