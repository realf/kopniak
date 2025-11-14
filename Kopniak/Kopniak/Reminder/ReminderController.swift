//
//  ReminderController.swift
//  Sergeant Kopniak
//
//  Created by alf on 01.10.2025.
//

import AppKit
import ComposableArchitecture
import SwiftUI

/// Window controller to manage the floating reminder window
class ReminderController: NSWindowController {
    let store: StoreOf<ReminderFeature>
    // MARK: - Initialization

    init(store: StoreOf<ReminderFeature>) {
        self.store = store
        super.init(window: FloatingWindow())
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Methods

    func showReminder(title: String) {
        guard let window = window else { return }

        // Create SwiftUI view and set as window content
        let reminderView = ReminderView(store: self.store)

        let hostingView = NSHostingView(rootView: reminderView)
        hostingView.frame = window.contentView?.bounds ?? NSRect.zero
        hostingView.autoresizingMask = [.width, .height]

        window.contentView = hostingView
        window.title = title
        window.center()  // Re-center before showing
        window.orderFrontRegardless()  // Show without activating

        // Add subtle animation
        window.alphaValue = 0
        window.isMovableByWindowBackground = true
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 2.0
            window.animator().alphaValue = 1.0
        }
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
