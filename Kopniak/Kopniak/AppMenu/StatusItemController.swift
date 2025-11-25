//
//  StatusItemController.swift
//  Kopniak
//
//  Created by alf on 03.11.2025.
//

import AppKit
import Combine
import ComposableArchitecture
import SwiftUI

final class StatusItemController: NSObject, NSPopoverDelegate {
    private let iconStore: StoreOf<AppMenuIconFeature>
    private let menuStore: StoreOf<AppMenuFeature>
    private var item: NSStatusItem?
    private var cancellables = Set<AnyCancellable>()
    private let popover: NSPopover

    init(
        iconStore: StoreOf<AppMenuIconFeature>,
        menuStore: StoreOf<AppMenuFeature>,
        launchAtLoginStore: StoreOf<LaunchAtLoginFeature>
    ) {
        self.iconStore = iconStore
        self.menuStore = menuStore
        let popover = NSPopover()
        popover.contentViewController = NSHostingController(
            rootView: AppMenuView(
                store: menuStore,
                launchAtLoginStore: launchAtLoginStore
            )
        )
        popover.behavior = .transient
        self.popover = popover
        super.init()
        self.popover.delegate = self
    }

    func activateStatusItem() {
        guard self.item == nil else {
            return
        }

        let bar = NSStatusBar.system
        self.item = bar.statusItem(withLength: NSStatusItem.variableLength)

        setupIcon()
        setupMenu()
    }

    func removeStatusItem() {
        guard let item else {
            return
        }
        cancellables.removeAll()
        NSStatusBar.system.removeStatusItem(item)
        self.item = nil
    }

    func showMenu() {
        guard let button = self.item?.button else {
            return
        }
        self.popover.show(
            relativeTo: button.bounds,
            of: button,
            preferredEdge: .maxY
        )
        self.popover
            .contentViewController?
            .view.window?
            .makeKey()
    }

    func hideMenu() {
        self.popover.performClose(self)
    }

    // MARK: - Menu Actions

    @objc private func menuIconTapped() {
        menuStore.send(.menuIconTapped)
    }

    // MARK: - NSPopoverDelegate

    func popoverDidClose(_ notification: Notification) {
        menuStore.send(.menuDidClose)
    }

    // MARK: - Private

    private func setupIcon() {
        if let button = self.item?.button {
            button.font = NSFont.monospacedDigitSystemFont(
                ofSize: 13,
                weight: .regular
            )
            button.widthAnchor.constraint(equalToConstant: 60.0).isActive = true

            let publisher = iconStore.publisher
            publisher.remainingTimeFormatted.sink { [weak self] time in
                guard let self else { return }
                if iconStore.remindersStatus != .off {
                    button.title = time
                }
            }
            .store(in: &cancellables)

            publisher.remindersStatus.sink { [weak self] status in
                guard let self else { return }
                button.image = menuBarIcon(status: status)
                if status == .off {
                    button.title = ""
                }
            }
            .store(in: &cancellables)

            button.target = self
            button.action = #selector(menuIconTapped)
        }
    }

    private func setupMenu() {
        menuStore.publisher
            .isMenuShown.sink { [weak self] isShown in
                guard let self else { return }
                if isShown {
                    self.showMenu()
                } else {
                    self.hideMenu()
                }
            }
            .store(in: &cancellables)
    }

    private func menuBarIcon(status: RemindersStatus) -> NSImage {
        if iconStore.remindersStatus == .on {
            return NSImage(
                systemSymbolName: "chevron.up.2",
                accessibilityDescription: NSLocalizedString(
                    "Kopniak, reminders on",
                    comment: "Chevron up accessibility description"
                )
            )!
        } else if iconStore.remindersStatus == .off {
            return NSImage(
                systemSymbolName: "chevron.up.dotted.2",
                accessibilityDescription: NSLocalizedString(
                    "Kopniak, reminders off",
                    comment: "Chevron up dotted accessibility description"
                )
            )!
        } else {
            return NSImage(
                systemSymbolName: "chevron.up.dotted.2",
                accessibilityDescription: NSLocalizedString(
                    "Kopniak, reminders paused",
                    comment: "Chevron up dotted accessibility description"
                )
            )!
        }
    }
}
