//
//  ReminderController.swift
//  Sergeant Kopniak
//
//  Created by alf on 01.10.2025.
//

import AppKit
import SwiftUI

/// Window controller to manage the floating reminder window
class ReminderController: NSWindowController {
    // MARK: - Initialization

    init() {
        super.init(window: FloatingWindow())
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Methods

    func showReminder(
        title: String,
        message: String,
        onDismiss: @escaping () -> Void,
        onSnooze: @escaping () -> Void
    ) {
        guard let window = window else { return }

        // Create SwiftUI view and set as window content
        let reminderView = ReminderView(
            title: title,
            message: message,
            onDismiss: onDismiss,
            onSnooze: onSnooze
        )

        let hostingView = NSHostingView(rootView: reminderView)
        hostingView.frame = window.contentView?.bounds ?? NSRect.zero
        hostingView.autoresizingMask = [.width, .height]

        window.contentView = hostingView
        window.title = "Sergeant Kopniak"
        window.center()  // Re-center before showing
        window.orderFrontRegardless()  // Show without activating

        // Add subtle animation
        window.alphaValue = 0
        window.animator().alphaValue = 1.0
    }

    func hideReminder() {
        guard let window = window else { return }

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.3
            window.animator().alphaValue = 0
        } completionHandler: {
            window.orderOut(nil)
        }
    }
}
