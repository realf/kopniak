//
//  KopniakApp.swift
//  Sergeant Kopniak
//
//  Created by alf on 02.10.2025.
//

import AppKit
import ComposableArchitecture
import SwiftUI

@Reducer
struct AppDelegateFeature {
    @ObservableState
    struct State {
        var openWindow: WindowID?
    }

    enum Action {
        case handleReopen(_ hasVisibleWindows: Bool)
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .handleReopen(let hasVisibleWindows):
                if !hasVisibleWindows {
                    state.openWindow = WindowID(destination: .main)
                }
                return .none
            }
        }
    }
}

@Observable
class AppDelegate: NSObject, NSApplicationDelegate {
    let store = Store(initialState: AppDelegateFeature.State()) {
        AppDelegateFeature()
    }

    func applicationShouldHandleReopen(
        _ sender: NSApplication,
        hasVisibleWindows: Bool
    ) -> Bool {
        store.send(.handleReopen(hasVisibleWindows))
        return true
    }
}

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
            menuStore: store.scope(state: \.appMenu, action: \.appMenu)
        )
        controller.activateStatusItem()
        DispatchQueue.main.async {
            store.send(.statusItemDidActivate)
        }

        return controller
    }()

    @Environment(\.dismissWindow) private var dismissWindow
    @Environment(\.openSettings) private var openSettings
    @Environment(\.openWindow) private var openWindow

    var body: some Scene {
        Window("Kopniak", id: "main") {
            AppMenuView(
                store: KopniakApp.store.scope(
                    state: \.appMenu,
                    action: \.appMenu
                )
            )
        }
        .windowResizability(.contentSize)
        .defaultPosition(.center)
        .restorationBehavior(.disabled)
        .commandsRemoved()
        .defaultLaunchBehavior(.suppressed)

        // Launch at login dialog
        Window("Open Kopniak automatically?", id: "launchAtLogin") {
            let store = KopniakApp.store.scope(
                state: \.launchAtLogin,
                action: \.launchAtLogin
            )
            LaunchAtLoginView(store: store)
        }
        .windowResizability(.contentSize)
        .defaultPosition(.center)
        .restorationBehavior(.disabled)
        .commandsRemoved()
        .defaultLaunchBehavior(.suppressed)

        // Add this window, so that the app does not close when there are no other windows
        Window("Empty", id: "lastWindow") {
            EmptyView()
        }
        .defaultLaunchBehavior(.suppressed)
        .restorationBehavior(.disabled)

        // Settings
        Settings {
            let store = KopniakApp.store.scope(
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
                openWindow(windowID: windowID)
            }
        }
        .onChange(
            of: appDelegate.store.openWindow,
            { _, windowID in
                if let windowID {
                    openWindow(windowID: windowID)
                }
            }
        )
        .onChange(of: Self.store.dismissWindow) { _, windowID in
            if let windowID {
                switch windowID.destination {
                case .launchAtLogin:
                    dismissWindow(id: "launchAtLogin")

                case .main:
                    dismissWindow(id: "main")

                case .menu:
                    DispatchQueue.main.async {
                        statusItemController.hideMenu()
                    }
                case .reminder:
                    reminderController.hideReminder()
                case .settings:
                    break
                }
            }
        }
    }

    private func openWindow(windowID: WindowID) {
        switch windowID.destination {
        case .launchAtLogin:
            openWindow(id: "launchAtLogin")

        case .main:
            openWindow(id: "main")

        case .menu:
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                statusItemController.showMenu()
            }

        case .reminder:
            reminderController.showReminder(title: "Kopniak Command")

        case .settings:
            openSettings()
        }
    }
}
