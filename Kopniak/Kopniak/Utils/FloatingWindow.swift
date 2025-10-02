//
//  FloatWindow.swift
//  Sergeant Kopniak
//
//  Created by alf on 02.10.2025.
//

import AppKit
import Foundation

class FloatingWindow: NSPanel {
    init() {
        // Make it non-activating (won't steal focus)
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 350, height: 200),
            styleMask: [.nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        setupFloatingBehavior()
    }

    private func setupFloatingBehavior() {
        // Make it float above everything
        level = .floating

        // Don't steal focus
        hidesOnDeactivate = false
        canHide = false

        // Show on all spaces and don't move with active space changes
        collectionBehavior = [.canJoinAllSpaces, .stationary]

        styleMask.insert(.titled)

        // Center on screen
        center()

        isRestorable = false
    }

    override var canBecomeKey: Bool {
        return true  // Allow it to receive keyboard events for the button
    }

    override var canBecomeMain: Bool {
        return false  // But don't make it the main window
    }
}
