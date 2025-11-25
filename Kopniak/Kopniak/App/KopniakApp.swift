//
//  KopniakApp.swift
//  Sergeant Kopniak
//
//  Created by alf on 02.10.2025.
//

import AppKit
import ComposableArchitecture
import SwiftUI

@main
struct KopniakApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    private static let store = Store(
        initialState: AppFeature.State(remindersStatus: .off)
    ) {
        AppFeature()
    }

    private let reminderController = ReminderController(
        store: store.scope(state: \.reminder, action: \.reminder)
    )

    private let statusItemController: StatusItemController = {
        let controller = StatusItemController(
            iconStore: store.scope(state: \.menuIcon, action: \.menuIcon),
            menuStore: store.scope(state: \.appMenu, action: \.appMenu),
            launchAtLoginStore: store.scope(
                state: \.launchAtLogin,
                action: \.launchAtLogin
            )
        )

        return controller
    }()

    init() {
        self.appDelegate.store = Self.store.scope(
            state: \.appDelegate,
            action: \.appDelegate
        )
        updateMenuBarIconState(Self.store.showMenuBarIcon)
    }

    @Environment(\.dismissWindow) private var dismissWindow
    @Environment(\.openSettings) private var openSettings
    @Environment(\.openWindow) private var openWindow

    var body: some Scene {
        Window("Kopniak", id: "main") {
            AppMenuView(
                store: Self.store.scope(
                    state: \.appMenu,
                    action: \.appMenu
                ),
                launchAtLoginStore: Self.store.scope(
                    state: \.launchAtLogin,
                    action: \.launchAtLogin
                )
            )
        }
        .windowResizability(.contentSize)
        .defaultPosition(.center)
        .restorationBehavior(.disabled)
        .commandsRemoved()
        .commands {
            CommandGroup(replacing: CommandGroupPlacement.appInfo) {
                Button(action: {
                    let store = Self.store.scope(
                        state: \.settings,
                        action: \.settings
                    )
                    store.send(.selectTab(.about))
                    open(windowID: WindowID(destination: .settings))
                }) {
                    HStack {
                        Image(systemName: "info.circle")
                        Text("About Kopniak")
                    }
                }
            }
        }
        .defaultLaunchBehavior(.suppressed)

        // Add this window, so that the app does not close when there are no other windows
        Window("Empty", id: "lastWindow") {
            EmptyView()
        }
        .defaultLaunchBehavior(.suppressed)
        .restorationBehavior(.disabled)

        // Settings
        Settings {
            let store = Self.store.scope(
                state: \.settings,
                action: \.settings
            )
            SettingsView(store: store)
        }
        .defaultLaunchBehavior(.suppressed)
        .windowResizability(.contentSize)
        .defaultPosition(.center)
        .onChange(of: Self.store.openWindow) { _, windowID in
            if let windowID {
                open(windowID: windowID)
            }
        }
        .onChange(of: Self.store.dismissWindow) { _, windowID in
            if let windowID {
                dismiss(windowID: windowID)
            }
        }
        .onChange(of: Self.store.showMenuBarIcon) { _, showMenuBarIcon in
            updateMenuBarIconState(showMenuBarIcon)
        }
    }

    private func updateMenuBarIconState(_ showMenuBarIcon: Bool) {
        if showMenuBarIcon {
            statusItemController.activateStatusItem()
        } else {
            statusItemController.removeStatusItem()
        }
    }

    private func open(windowID: WindowID) {
        switch windowID.destination {
        case .launchAtLogin:
            openWindow(id: "launchAtLogin")

        case .main:
            openWindow(id: "main")

        case .reminder:
            reminderController.showReminder(title: "Kopniak Command")

        case .settings:
            openSettings()
        }
    }

    private func dismiss(windowID: WindowID) {
        switch windowID.destination {
        case .launchAtLogin:
            dismissWindow(id: "launchAtLogin")

        case .main:
            dismissWindow(id: "main")

        case .reminder:
            reminderController.hideReminder()

        case .settings:
            break
        }
    }
}
