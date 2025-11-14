//
//  FloatingWindow.swift
//  Sergeant Kopniak
//
//  Created by alf on 02.10.2025.
//

import AppKit
import Foundation

/// Custom NSPanel configured as a non-activating floating window that appears above all other windows
class FloatingWindow: NSPanel {
    // MARK: - Initialization

    init() {
        // Make it non-activating (won't steal focus)
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 350, height: 200),
            styleMask: [.nonactivatingPanel, .titled],
            backing: .buffered,
            defer: false
        )

        setupFloatingBehavior()
    }

    // MARK: - Setup

    private func setupFloatingBehavior() {
        // Make it float above everything
        level = .floating

        // Don't steal focus
        hidesOnDeactivate = false
        canHide = false

        // Show on all spaces and don't move with active space changes
        collectionBehavior = [.canJoinAllSpaces, .stationary]

        // Center on screen
        center()

        isRestorable = false
        isMovableByWindowBackground = true
    }

    // MARK: - Overrides

    override var canBecomeKey: Bool {
        return true  // Allow it to receive keyboard events for the button
    }

    override var canBecomeMain: Bool {
        return false  // But don't make it the main window
    }
}
