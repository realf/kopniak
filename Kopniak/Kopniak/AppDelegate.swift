//
//  AppDelegate.swift
//  Kopniak
//
//  Created by alf on 30.05.2025.
//

import Cocoa
import UserNotifications

class AppDelegate: NSObject, NSApplicationDelegate {
    private var timer: Timer?
    private var recentMessages: [String] = []
    private let maxRecent = 5
    private var overlayController: FloatingOverlayController?
    
    private let titles = [
        "Attention, Soldier!",
        "Mission Alert!",
        "Posture Command!",
        "Drill Time!",
        "Bootcamp Break!",
        "Move It, Trooper!",
        "Action Stations!",
        "Sergeant’s Call!",
        "Orders from HQ!"
    ]

    private let messages: [String] = [
        "Listen up, recruit! Drop that mouse and march in place!",
        "Sergeant Kopniak here! Stand up and stretch, soldier!",
        "At ease… but only for a second. Move it, move it!",
        "Attention! Your spine needs you to report for duty.",
        "Private, your chair’s not the only thing that needs action. Get up!",
        "This is an order! Step away from the screen. Now.",
        "Stand tall, soldier! Hunching is not part of your mission.",
        "Sergeant Kopniak: whipping that posture into shape. Let’s move!",
        "Operation: Stretch & Breathe is underway. You’re the star recruit!",
        "Don’t make me come over there. Stretch those limbs!",
        "Break time is now, trooper. Execute a perfect posture drill."
    ]
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        requestNotificationPermission()
        setupOverlay()
        scheduleBreakTimer()
        UNUserNotificationCenter.current().delegate = self
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
//            self?.showRandomBreakReminderNotification()
            self?.showBreakReminderOverlay()
        }
    }
    
    func setupOverlay() {
        overlayController = FloatingOverlayController(rootView: AlternativeNotificationView())
    }

    func showRandomBreakReminderNotification() {
        guard let message = pickRandomMessage() else { return }

        let content = UNMutableNotificationContent()
        let title = titles.randomElement() ?? "Sergeant Kopniak Orders!"
        content.title = title
        content.body = message
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request)
        updateRecentMessages(message)
    }
    
    func showBreakReminderOverlay() {
            overlayController?.showOverlay()

            // Play an optional audio cue
            NSSound(named: "Ping")?.play()

            // Hide after a few seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
                self?.overlayController?.hideOverlay()
            }
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

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Called when a notification is delivered while app is in foreground
        print("Intercepted notification while active")
        completionHandler([.banner, .sound]) // You can override and show it anyway
    }
}
