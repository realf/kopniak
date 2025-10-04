//
//  ReminderManager.swift
//  Sergeant Kopniak
//
//  Created by alf on 01.10.2025.
//

import AppKit
import Foundation
import SwiftUI

@MainActor
@Observable
class ReminderManager {
    // MARK: - Properties

    // Reference to settings manager
    private let settingsManager: SettingsManager

    private var reminderTimer: Timer?
    private let userDefaults = UserDefaults.standard
    private let isActiveKey = "ReminderManager.isActive"
    private let isPausedKey = "ReminderManager.isPaused"
    private let pausedTimeRemainingKey = "ReminderManager.pausedTimeRemaining"
    private let snoozeInterval: TimeInterval = 10 * 60.0
    
    // Pause/Resume state
    private var isPaused: Bool = false
    private var pausedTimeRemaining: TimeInterval = 0

    // Reminder window controller
    private var reminderWindowController: ReminderController?

    // Recent history to avoid repetition
    private var recentTitles: [String] = []
    private var recentMessages: [String] = []
    private let maxRecent = 10

    // Observable activation count for onboarding
    private(set) var reportForDutyActivationCount: Int = 0

    // MARK: - Computed Properties

    private var reminderInterval: TimeInterval {
        Double(reminderIntervalMinutes) * 60.0
    }

    var reminderIntervalMinutes: Int {
        settingsManager.reminderIntervalMinutes
    }

    var isActive: Bool {
        reminderTimer?.isValid == true
    }
    
    var canPause: Bool {
        isActive && !isPaused
    }
    
    var canResume: Bool {
        !isActive && isPaused
    }

    // MARK: - Constants

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

    // MARK: - Initialization

    init(settingsManager: SettingsManager) {
        self.settingsManager = settingsManager
    }

    // MARK: - Public Methods

    func restorePersistedState() {
        // Restore pause state
        isPaused = userDefaults.bool(forKey: isPausedKey)
        pausedTimeRemaining = userDefaults.double(forKey: pausedTimeRemainingKey)
        
        // Restore persisted state and start reminders if they were active
        if userDefaults.bool(forKey: isActiveKey) {
            if isPaused {
                // Don't start timer if paused, but keep the paused state
                return
            } else {
                startReminders()
            }
        }
    }

    func startReminders() {
        // Initialize reminder window controller
        if reminderWindowController == nil {
            reminderWindowController = ReminderController()
        }

        // Increment activation count (observed by OnboardingManager)
        reportForDutyActivationCount += 1

        // Clear pause state when starting
        isPaused = false
        pausedTimeRemaining = 0

        // Persist active state
        userDefaults.set(true, forKey: isActiveKey)
        userDefaults.set(false, forKey: isPausedKey)
        userDefaults.set(0, forKey: pausedTimeRemainingKey)

        scheduleNextReminder(interval: reminderInterval)
    }

    func stopReminders() {
        reminderTimer?.invalidate()
        reminderTimer = nil
        hideFloatingReminder()
        
        // Clear pause state when stopping
        isPaused = false
        pausedTimeRemaining = 0
        
        // Persist inactive state
        userDefaults.set(false, forKey: isActiveKey)
        userDefaults.set(false, forKey: isPausedKey)
        userDefaults.set(0, forKey: pausedTimeRemainingKey)
    }

    func showReminder() {
        // Show reminder window with non-repeating content
        let title = pickRandomTitle()
        let message = pickRandomMessage()
        updateRecentTitle(title)
        updateRecentMessage(message)
        showFloatingReminder(title: title, message: message)
    }

    func dismissReminder() {
        hideFloatingReminder()
        scheduleNextReminder(interval: reminderInterval)
    }
    
    func snoozeReminder() {
        hideFloatingReminder()
        scheduleNextReminder(interval: snoozeInterval)
    }
    
    func pauseReminders() {
        guard canPause else { return }
        
        // Calculate remaining time
        if let fireDate = reminderTimer?.fireDate {
            pausedTimeRemaining = fireDate.timeIntervalSinceNow
        }
        
        // Stop the timer
        reminderTimer?.invalidate()
        reminderTimer = nil
        hideFloatingReminder()
        
        // Set pause state
        isPaused = true
        
        // Persist pause state
        userDefaults.set(true, forKey: isPausedKey)
        userDefaults.set(pausedTimeRemaining, forKey: pausedTimeRemainingKey)
    }
    
    func resumeReminders() {
        guard canResume else { return }
        
        // Clear pause state
        isPaused = false
        
        // Use remaining time or fallback to full interval
        let timeToWait = pausedTimeRemaining > 0 ? pausedTimeRemaining : reminderInterval
        pausedTimeRemaining = 0
        
        // Persist resumed state
        userDefaults.set(false, forKey: isPausedKey)
        userDefaults.set(0, forKey: pausedTimeRemainingKey)
        
        // Schedule with remaining time
        scheduleNextReminder(interval: timeToWait)
    }

    // MARK: - Presentation logic
    private func showFloatingReminder(title: String, message: String) {
        reminderWindowController?.showReminder(title: title, message: message, onDismiss: {
            [weak self] in
            self?.dismissReminder()
        }, onSnooze: {
            [weak self] in
            self?.snoozeReminder()
        })
    }

    private func hideFloatingReminder() {
        reminderWindowController?.hideReminder()
    }

    private func scheduleNextReminder(interval: TimeInterval) {
        reminderTimer?.invalidate()
        reminderTimer = Timer.scheduledTimer(
            withTimeInterval: interval,
            repeats: false
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.showReminder()
            }
        }
    }

    // MARK: - Picking logic that avoids recent repeats
    private func pickRandomTitle() -> String {
        let available = militaryTitles.filter { !recentTitles.contains($0) }
        let choice = available.isEmpty ? militaryTitles.randomElement() : available.randomElement()
        return choice ?? "Attention Soldier!"
    }

    private func pickRandomMessage() -> String {
        let available = militaryMessages.filter { !recentMessages.contains($0) }
        let choice = available.isEmpty ? militaryMessages.randomElement() : available.randomElement()
        return choice ?? "Time to exercise, soldier!"
    }

    private func updateRecentTitle(_ title: String) {
        recentTitles.append(title)
        if recentTitles.count > maxRecent {
            recentTitles.removeFirst()
        }
    }

    private func updateRecentMessage(_ message: String) {
        recentMessages.append(message)
        if recentMessages.count > maxRecent {
            recentMessages.removeFirst()
        }
    }
}
