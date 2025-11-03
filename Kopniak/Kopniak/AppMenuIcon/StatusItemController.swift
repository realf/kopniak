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

    init(iconStore: StoreOf<AppMenuIconFeature>, menuStore: StoreOf<AppMenuFeature>) {
        self.iconStore = iconStore
        self.menuStore = menuStore
    }

    func activateStatusItem() {
        guard item == nil else {
            return
        }

        let bar = NSStatusBar.system
        item = bar.statusItem(withLength: NSStatusItem.variableLength)

        setupIcon()
        setupMenu()
    }

    private func setupIcon() {
        if let button = item.button {
            button.font = NSFont.monospacedDigitSystemFont(ofSize: 13, weight: .regular)

            let publisher = iconStore.publisher
            publisher.remainingTime.sink { [weak self] time in
                guard let self else { return }
                if iconStore.remindersStatus != .off {
                    button.title = self.formatted(remainingTime: time)
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
        
    }

    private func formatted(remainingTime: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: remainingTime) ?? "00:00"
    }

    private func menuBarIcon(status: RemindersStatus) -> NSImage {
        if iconStore.remindersStatus == .on {
            return NSImage(systemSymbolName: "chevron.up.2", accessibilityDescription: "Kopniak, reminders active")!
        } else {
            return NSImage(systemSymbolName: "chevron.up.dotted.2", accessibilityDescription: "Kopniak, reminders inactive")!
        }
    }
}
