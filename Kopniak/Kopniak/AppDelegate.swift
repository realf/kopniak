//
//  AppDelegate.swift
//  Kopniak
//
//  Created by alf on 30.05.2025.
//

import Cocoa
import UserNotifications

class AppDelegate: NSObject, NSApplicationDelegate {
    var timer: Timer?
    var recentMessages: [String] = []
    let maxRecent = 5

    let messages: [String] = [
        "Your spine called. It wants a better life.",
        "Stretch now, or your keyboard might become permanent furniture.",
        "Be kind to your spine.",
        "You're not a robot (yet). Move those human limbs.",
        "Stand up before your chair finishes absorbing you.",
        "Clicking isn't cardio. Move a little.",
        "Coffee's brewing. So should your circulation.",
        "Tired? Brain fog’s worst enemy is movement.",
        "Pretend you dropped something and stand up!",
        "Posture check: don't be a croissant."
    ]

    func applicationDidFinishLaunching(_ notification: Notification) {
        requestNotificationPermission()
        scheduleBreakTimer()
    }

    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted.")
            } else if let error {
                print("Notification error: \(error)")
                // TODO: Show message explaining why we need the notification permission
            }
        }
    }

    func scheduleBreakTimer() {
        let reminderTimeInterval = AppContext.notificationTimeInterval()
        
        timer = Timer.scheduledTimer(withTimeInterval: reminderTimeInterval, repeats: true) { [weak self] _ in
            self?.sendRandomBreakReminder()
        }
    }

    func sendRandomBreakReminder() {
        guard let message = pickRandomMessage() else { return }

        let content = UNMutableNotificationContent()
        content.title = "Break Reminder"
        content.body = message
        content.sound = .default
        
        // TODO: Check if we need a time-sensitive entitlement for that.
//        content.interruptionLevel = .timeSensitive

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request)
        updateRecentMessages(message)
    }

    func pickRandomMessage() -> String? {
        let available = messages.filter { !recentMessages.contains($0) }
        guard !available.isEmpty else {
            recentMessages.removeAll()
            return messages.randomElement()
        }
        return available.randomElement()
    }

    func updateRecentMessages(_ message: String) {
        recentMessages.append(message)
        if recentMessages.count > maxRecent {
            recentMessages.removeFirst()
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        timer?.invalidate()
    }
}
