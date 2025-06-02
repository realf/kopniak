//
//  FloatingOverlayController.swift
//  Sergeant Kopniak
//
//  Created by alf on 02.06.2025.
//

import SwiftUI
import AppKit

class FloatingOverlayController: NSWindowController {
    init(rootView: some View) {
        let panel = NSPanel(
            contentRect: NSRect(x: 100, y: 100, width: 300, height: 100),
            styleMask: [.titled, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.level = .floating
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = true
        panel.isMovableByWindowBackground = true
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true

        let hostingView = NSHostingView(rootView: rootView)
        panel.contentView = hostingView

        super.init(window: panel)
        self.window?.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func showOverlay() {
        self.window?.makeKeyAndOrderFront(nil)
    }

    func hideOverlay() {
        self.window?.orderOut(nil)
    }
}
