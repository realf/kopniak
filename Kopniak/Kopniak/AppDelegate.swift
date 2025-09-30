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
        if let hosting = reminderHostingController, let window = reminderWindow {
            let view = ReminderView(title: title, message: message, onDismiss: { window.close() })
            hosting.rootView = view
            self.sizeWindowToFitContent(hosting: hosting, window: window)
            window.orderFrontRegardless()
            return
        }

        let window = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 380, height: 200),
            styleMask: [.titled, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        window.collectionBehavior = [.canJoinAllSpaces]

        let view = ReminderView(title: title, message: message, onDismiss: { window.close() })
        let hosting = NSHostingController(rootView: view)
        window.title = "Kopniak Reminder"
        window.isReleasedWhenClosed = false
        window.contentViewController = hosting
        self.sizeWindowToFitContent(hosting: hosting, window: window)
        window.center()

        self.reminderHostingController = hosting
        self.reminderWindow = window

        window.orderFrontRegardless()
    }
    
    private func sizeWindowToFitContent(hosting: NSHostingController<ReminderView>, window: NSWindow) {
        let contentWidth: CGFloat = 380
        // Ensure layout is up to date before measuring
        hosting.view.layoutSubtreeIfNeeded()
        let fittingSize = hosting.view.fittingSize
        let minHeight: CGFloat = 160
        let contentHeight = max(minHeight, fittingSize.height)
        window.setContentSize(NSSize(width: contentWidth, height: contentHeight))
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
