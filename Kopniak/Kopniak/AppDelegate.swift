//
//  AppDelegate.swift
//  Kopniak
//
//  Created by alf on 30.05.2025.
//

import Cocoa
import UserNotifications
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    private var timer: Timer?
    private var recentMessages: [String] = []
    private let maxRecent = 5
    let reminderTimeInterval = 45.0 * 60.0

    private var reminderWindow: NSWindow?
    private var reminderHostingController: NSHostingController<ReminderView>?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        requestNotificationPermission()
        scheduleBreakTimer()
        UNUserNotificationCenter.current().delegate = self
        showReminderWindowIfNeeded()
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
        timer = Timer.scheduledTimer(withTimeInterval: reminderTimeInterval, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            let content = self.prepareReminderContent()
            self.showReminderNotification(title: content.title, message: content.message)
            self.showReminderWindow(title: content.title, message: content.message)
            self.updateRecentMessages(content.message)
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

    func prepareReminderContent() -> (title: String, message: String) {
        let titleText = titles.randomElement() ?? "Sergeant Kopniak Orders!"
        let messageText = pickRandomMessage() ?? (messages.randomElement() ?? "Time to move!")
        return (titleText, messageText)
    }

    func showReminderNotification(title: String, message: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request)
    }
    
    func showReminderWindow(title: String, message: String) {
        let view = ReminderView(title: title, message: message)

        if let hosting = reminderHostingController, let window = reminderWindow {
            hosting.rootView = view
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let hosting = NSHostingController(rootView: view)
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 380, height: 200),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Kopniak Reminder"
        window.isReleasedWhenClosed = false
        window.contentViewController = hosting
        window.center()

        self.reminderHostingController = hosting
        self.reminderWindow = window

        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    private func showReminderWindowIfNeeded() {
        // No-op for now; window is created on first show
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
