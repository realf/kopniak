//
//  StatusItemController.swift
//  Kopniak
//
//  Created by alf on 03.11.2025.
//

import AppKit
import Combine
import ComposableArchitecture

final class StatusItemController {
    private let iconStore: StoreOf<AppMenuIconFeature>
    private let menuStore: StoreOf<AppMenuFeature>
    private var item: NSStatusItem!
    private var cancellables = Set<AnyCancellable>()

    init(
        iconStore: StoreOf<AppMenuIconFeature>,
        menuStore: StoreOf<AppMenuFeature>
    ) {
        self.iconStore = iconStore
        self.menuStore = menuStore
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

    private func setupIcon() {
        if let button = self.item.button {
            button.font = NSFont.monospacedDigitSystemFont(
                ofSize: 13,
                weight: .regular
            )

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
        }
    }

    private func setupMenu() {
        item.menu = buildMenu()

        let publisher = menuStore.publisher
        publisher.remindersStatus.sink { [weak self] _ in
            guard let self else { return }
            self.item.menu = self.buildMenu()
        }
        .store(in: &cancellables)
    }

    private func buildMenu() -> NSMenu {
        let menu = NSMenu()

        // Mission Briefing
        menu.addItem(
            createMenuItem(
                title: "Mission Briefing",
                icon: "chevron.up.2",
                shortcut: ("b", .command),
                action: #selector(missionBriefingAction)
            )
        )

        menu.addItem(NSMenuItem.separator())

        // Status-dependent menu items
        let status = menuStore.remindersStatus

        switch status {
        case .off:
            menu.addItem(
                createMenuItem(
                    title: "Report for Duty",
                    icon: "play.fill",
                    shortcut: ("r", .command),
                    action: #selector(reportForDutyAction)
                )
            )
        case .on:
            menu.addItem(
                createMenuItem(
                    title: "Stand Down",
                    icon: "stop.fill",
                    shortcut: ("s", .command),
                    action: #selector(standDownAction)
                )
            )

            menu.addItem(
                createMenuItem(
                    title: "At Ease",
                    icon: "pause.fill",
                    shortcut: ("p", .command),
                    action: #selector(atEaseAction)
                )
            )

            menu.addItem(
                createMenuItem(
                    title: "Say Again",
                    icon: "backward.end.fill",
                    shortcut: ("y", .command),
                    action: #selector(sayAgainAction)
                )
            )
        case .paused:
            menu.addItem(
                createMenuItem(
                    title: "Stand Down",
                    icon: "stop.fill",
                    shortcut: ("s", .command),
                    action: #selector(standDownAction)
                )
            )

            menu.addItem(
                createMenuItem(
                    title: "Resume Duty",
                    icon: "play.fill",
                    shortcut: ("r", .command),
                    action: #selector(resumeDutyAction)
                )
            )

            menu.addItem(
                createMenuItem(
                    title: "Say Again",
                    icon: "backward.end.fill",
                    shortcut: ("y", .command),
                    action: #selector(sayAgainAction)
                )
            )
        }

        menu.addItem(NSMenuItem.separator())

        // Settings
        menu.addItem(
            createMenuItem(
                title: "Settings…",
                icon: "gear",
                shortcut: (",", .command),
                action: #selector(settingsAction)
            )
        )

        menu.addItem(NSMenuItem.separator())

        // Quit
        menu.addItem(
            createMenuItem(
                title: "Quit Kopniak",
                icon: nil,
                shortcut: ("q", .command),
                action: #selector(quitAction)
            )
        )

        return menu
    }

    private func createMenuItem(
        title: String,
        icon: String?,
        shortcut: (key: String, modifiers: NSEvent.ModifierFlags)?,
        action: Selector
    ) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: "")
        item.target = self

        if let (key, modifiers) = shortcut {
            item.keyEquivalent = key
            item.keyEquivalentModifierMask = modifiers
        }

        if let iconName = icon {
            item.image = NSImage(
                systemSymbolName: iconName,
                accessibilityDescription: title
            )
        }

        return item
    }

    // MARK: - Menu Actions

    @objc private func missionBriefingAction() {
        menuStore.send(.delegate(.missionBriefingTapped))
    }

    @objc private func reportForDutyAction() {
        menuStore.send(.delegate(.startRemindersTapped))
    }

    @objc private func standDownAction() {
        menuStore.send(.delegate(.stopRemindersTapped))
    }

    @objc private func atEaseAction() {
        menuStore.send(.delegate(.pauseRemindersTapped))
    }

    @objc private func sayAgainAction() {
        menuStore.send(.delegate(.restartRemindersTapped))
    }

    @objc private func resumeDutyAction() {
        menuStore.send(.delegate(.resumeRemindersTapped))
    }

    @objc private func settingsAction() {
        menuStore.send(.delegate(.settingsTapped))
    }

    @objc private func quitAction() {
        menuStore.send(.delegate(.quitTapped))
    }

    private func menuBarIcon(status: RemindersStatus) -> NSImage {
        if iconStore.remindersStatus == .on {
            return NSImage(
                systemSymbolName: "chevron.up.2",
                accessibilityDescription: "Kopniak, reminders active"
            )!
        } else {
            return NSImage(
                systemSymbolName: "chevron.up.dotted.2",
                accessibilityDescription: "Kopniak, reminders inactive"
            )!
        }
    }
}
