//
//  AppDelegate.swift
//  Kopniak
//
//  Created by alf on 30.05.2025.
//

import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    private var timer: Timer?
    private var snoozeTimer: Timer?
    private var recentMessages: [String] = []
    private let maxRecent = 5
    private var statusItem: NSStatusItem?
    private let reminderInterval = 45.0 * 60.0
    private let snoozeInterval = 10.0 * 60.0

    private var reminderWindow: NSWindow?
    private var reminderHostingController: NSHostingController<ReminderView>?
    
    private var introductionPopover: NSPopover?

    private var toggleMenuItem: NSMenuItem?
    private let iconActive = NSImage(systemSymbolName: "chevron.up.2", accessibilityDescription: "Sergeant Kopniak")
    private let iconInactive = NSImage(systemSymbolName: "chevron.up.dotted.2", accessibilityDescription: "Sergeant Kopniak")

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide all windows by default
        NSApplication.shared.setActivationPolicy(.accessory)

        scheduleBreakTimer()
        setupMenuBar()
        
        // Show briefing on first launch
        showBriefingOnFirstLaunch()
    }

    func applicationWillTerminate(_ notification: Notification) {
        timer?.invalidate()
        snoozeTimer?.invalidate()
    }

    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem?.button?.image = iconActive

        let menu = NSMenu()
        
        // Show Introduction menu item
        let showIntroItem = NSMenuItem(title: "Mission Briefing", action: #selector(showIntroduction), keyEquivalent: "")
        menu.addItem(showIntroItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Toggle reminders menu item
        let toggleRemindersItem = NSMenuItem(title: "Stand Down", action: #selector(toggleTimer), keyEquivalent: "")
        toggleMenuItem = toggleRemindersItem
        menu.addItem(toggleRemindersItem)
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusItem?.menu = menu
    }
    
    private func showBriefingOnFirstLaunch() {
        let hasLaunchedBefore = UserDefaults.standard.bool(forKey: "HasLaunchedBefore")
        
        if !hasLaunchedBefore {
            // Mark as launched
            UserDefaults.standard.set(true, forKey: "HasLaunchedBefore")
            
            // Show briefing after a short delay to ensure UI is ready
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.showIntroduction()
            }
        }
    }

    @objc private func showIntroduction() {
        if let popover = introductionPopover {
            if popover.isShown {
                popover.close()
                return
            }
        }
        
        let popover = NSPopover()
        popover.contentSize = NSSize(width: 400, height: 450)
        popover.behavior = .transient
        popover.animates = true
        
        let contentView = IntroView()
        let hostingController = NSHostingController(rootView: contentView)
        popover.contentViewController = hostingController
        
        self.introductionPopover = popover
        
        if let statusButton = statusItem?.button {
            // Activate the application to ensure proper focus
            NSApplication.shared.activate(ignoringOtherApps: true)
            popover.show(relativeTo: statusButton.bounds, of: statusButton, preferredEdge: .minY)
            
            // Ensure the popover gets focus
            DispatchQueue.main.async {
                popover.contentViewController?.view.window?.makeKey()
            }
        }
    }

    @objc private func toggleTimer() {
        if timer?.isValid == true {
            timer?.invalidate()
            snoozeTimer?.invalidate()
            statusItem?.button?.image = iconInactive
            toggleMenuItem?.title = "Report for Duty"
        } else {
            scheduleBreakTimer()
            statusItem?.button?.image = iconActive
            toggleMenuItem?.title = "Stand Down"
        }
    }

    private func scheduleBreakTimer() {
        // Fire immediately, uncomment for testing
//        self.showReminder()

        timer = Timer.scheduledTimer(
            withTimeInterval: reminderInterval,
            repeats: true
        ) { [weak self] _ in
            self?.showReminder()
        }
    }

    private func showReminder() {
        let content = self.prepareReminderContent()
        self.showReminderWindow(title: content.title, message: content.message)
        NSSound.beep()
        self.updateRecentMessages(content.message)
    }
    
    private func snoozeReminder() {
        // Cancel any existing snooze timer
        snoozeTimer?.invalidate()
        // Cancel main timer
        timer?.invalidate()

        // Schedule a snooze timer
        snoozeTimer = Timer.scheduledTimer(withTimeInterval: snoozeInterval, repeats: false) { [weak self] _ in
            self?.showReminder()
            // Restore main timer
            self?.scheduleBreakTimer()
        }
    }

    private func pickRandomMessage() -> String? {
        let available = messages.filter { !recentMessages.contains($0) }
        guard !available.isEmpty else {
            recentMessages.removeAll()
            return messages.randomElement()
        }
        return available.randomElement()
    }

    private func updateRecentMessages(_ message: String) {
        recentMessages.append(message)
        if recentMessages.count > maxRecent {
            recentMessages.removeFirst()
        }
    }

    private func prepareReminderContent() -> (title: String, message: String) {
        let titleText = titles.randomElement() ?? "Sergeant Kopniak Orders!"
        let messageText = pickRandomMessage() ?? (messages.randomElement() ?? "Time to move!")
        return (titleText, messageText)
    }

    private func showReminderWindow(title: String, message: String) {
        if let hosting = reminderHostingController, let window = reminderWindow {
            let view = ReminderView(
                title: title, 
                message: message, 
                onDismiss: { window.close() },
                onSnooze: { [weak self] in
                    window.close()
                    self?.snoozeReminder()
                }
            )
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
        window.level = .floating
        window.isRestorable = false

        let view = ReminderView(
            title: title, 
            message: message, 
            onDismiss: { window.close() },
            onSnooze: { [weak self] in
                window.close()
                self?.snoozeReminder()
            }
        )
        let hosting = NSHostingController(rootView: view)
        window.title = "Sergeant Kopniak says:"
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
}
