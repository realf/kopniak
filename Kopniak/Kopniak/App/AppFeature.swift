//
//  AppFeature.swift
//  Sergeant Kopniak
//
//  Created by alf on 16.10.2025.
//

import AppKit
import ComposableArchitecture
import Foundation

/// Type used to display windows in SwiftUI. Set a new value to `openWindowID`
/// to show a window. Even if the `destination` stays the same, `uniqueID` will be
/// different and the window will be activated.
struct WindowID: Equatable {
    let destination: Destination
    let uniqueID = UUID()

    enum Destination: Equatable {
        case launchAtLogin
        case main
        case reminder
        case settings
    }
}

@Reducer
struct AppFeature {
    @ObservableState
    struct State {
        // Open and dismiss windows
        var dismissWindow: WindowID?
        var openWindow: WindowID?

        @Shared var showMainWindowAtLaunch: Bool
        @Shared var showMenuBarIcon: Bool

        // Child states
        var appMenu: AppMenuFeature.State
        var appDelegate: AppDelegateFeature.State
        var launchAtLogin: LaunchAtLoginFeature.State
        var menuIcon: AppMenuIconFeature.State
        var reminder: ReminderFeature.State
        var reminders: RemindersFeature.State
        var settings: SettingsFeature.State

        init(remindersStatus: @autoclosure () -> RemindersStatus) {
            launchAtLogin = LaunchAtLoginFeature.State()
            let reminders = RemindersFeature.State(
                remindersStatus: remindersStatus()
            )
            self.reminders = reminders
            appMenu = AppMenuFeature.State(
                remindersStatus: reminders.$remindersStatus,
                remainingTime: reminders.$remainingTime,
                reminderInterval: reminders.$reminderInterval
            )

            let reminder = ReminderFeature.State(
                snoozeInterval: reminders.$snoozeInterval
            )

            self.reminder = reminder

            let menuIcon = AppMenuIconFeature.State(
                remindersStatus: reminders.$remindersStatus,
                remainingTime: reminders.$remainingTime,
                menuIconTimeDisplay: .short
            )
            self.menuIcon = menuIcon
            let showMainWindowAtLaunch = Shared(
                wrappedValue: true,
                .appStorage("showMainWindowAtLaunch")
            )
            _showMainWindowAtLaunch = showMainWindowAtLaunch

            let showMenuBarIcon = Shared(
                wrappedValue: false,
                .appStorage("showMenuBarIcon")
            )
            _showMenuBarIcon = showMenuBarIcon

            _appDelegate = AppDelegateFeature.State()

            settings = SettingsFeature.State(
                reminderInterval: reminders.$reminderInterval,
                snoozeInterval: reminders.$snoozeInterval,
                menuIconTimeDisplay: menuIcon.$menuIconTimeDisplay,
                restartAfterScreenLock: reminders.$restartAfterScreenLock,
                reminderSound: reminder.$reminderSound,
                soundVolume: reminder.$soundVolume,
                showMainWindowAtLaunch: showMainWindowAtLaunch,
                showMenuBarIcon: showMenuBarIcon
            )
        }
    }

    enum Action {
        case appDelegate(AppDelegateFeature.Action)
        case appMenu(AppMenuFeature.Action)
        case launchAtLogin(LaunchAtLoginFeature.Action)
        case menuIcon(AppMenuIconFeature.Action)
        case reminder(ReminderFeature.Action)
        case reminders(RemindersFeature.Action)
        case settings(SettingsFeature.Action)
    }

    var body: some Reducer<State, Action> {
        Scope(state: \.appDelegate, action: \.appDelegate) {
            AppDelegateFeature()
        }
        Scope(state: \.appMenu, action: \.appMenu) { AppMenuFeature() }
        Scope(state: \.menuIcon, action: \.menuIcon) { AppMenuIconFeature() }

        Scope(state: \.launchAtLogin, action: \.launchAtLogin) {
            LaunchAtLoginFeature()
        }
        Scope(state: \.reminder, action: \.reminder) { ReminderFeature() }
        Scope(state: \.reminders, action: \.reminders) { RemindersFeature() }
        Scope(state: \.settings, action: \.settings) { SettingsFeature() }

        Reduce { state, action in
            switch action {
            case .appDelegate(.delegate(let action)):
                return reduceAppDelegateDelegate(&state, action: action)

            case .appMenu(.delegate(let action)):
                return reduceAppMenuDelegate(&state, action: action)

            case .appMenu:
                return .none

            case .launchAtLogin(.delegate(let action)):
                return reduceLaunchAtLoginDelegate(&state, action: action)

            case .launchAtLogin:
                return .none

            case .menuIcon:
                return .none

            case .reminder(.delegate(let action)):
                return reduceReminderDelegate(&state, action: action)

            case .reminder:
                return .none

            case .reminders(.delegate(let action)):
                return reduceRemindersDelegate(&state, action: action)

            case .reminders:
                return .none

            case .settings(.delegate(.reminderIntervalChanged)):
                return reduce(
                    into: &state,
                    action: .reminders(.reminderIntervalChanged)
                )

            case .settings:
                return .none
            }
        }
    }
}

// MARK: - LaunchAtLoginDelegate
extension AppFeature {
    fileprivate func reduceLaunchAtLoginDelegate(
        _ state: inout State,
        action: LaunchAtLoginFeature.Action.Delegate
    ) -> Effect<Action> {
        switch action {
        case .dismissLaunchAtLogin:
            return .merge(
                dismissWindow(
                    &state,
                    window: WindowID(destination: .launchAtLogin)
                ),
                reduce(
                    into: &state,
                    action: .settings(
                        .generalSettings(.launchAtLoginUpdatedExternally)
                    )
                )
            )
        case .showLaunchAtLogin:
            return showWindow(
                &state,
                window: WindowID(destination: .launchAtLogin)
            )
        }
    }
}

// MARK: - AppDelegateDelegate
extension AppFeature {
    fileprivate func reduceAppDelegateDelegate(
        _ state: inout State,
        action: AppDelegateFeature.Action.Delegate
    ) -> Effect<Action> {
        switch action {
        case .applicationDidFinishLaunching:
            if state.showMainWindowAtLaunch {
                state.openWindow = WindowID(destination: .main)
            }

            return reduce(into: &state, action: .reminders(.applicationDidLaunch))

        case .handleReopen(let hasVisibleWindows):
            if !hasVisibleWindows {
                state.openWindow = WindowID(destination: .main)
            }
            return .none
        }
    }
}

// MARK: - AppMenuDelegate
extension AppFeature {
    fileprivate func reduceAppMenuDelegate(
        _ state: inout State,
        action: AppMenuFeature.Action.Delegate
    ) -> Effect<Action> {
        switch action {
        case .pauseRemindersTapped:
            return reduce(
                into: &state,
                action: .reminders(.pauseRemindersTapped)
            )
        case .restartRemindersTapped:
            return reduce(
                into: &state,
                action: .reminders(.restartRemindersTapped)
            )
        case .resumeRemindersTapped:
            return reduce(
                into: &state,
                action: .reminders(.resumeRemindersTapped)
            )
        case .settingsTapped:
            let window = WindowID(destination: .settings)
            return showWindow(&state, window: window)

        case .startRemindersTapped:
            return .merge(
                reduce(
                    into: &state,
                    action: .launchAtLogin(.startRemindersTapped)
                ),
                reduce(
                    into: &state,
                    action: .reminders(.startRemindersTapped)
                )
            )
        case .stopRemindersTapped:
            return reduce(
                into: &state,
                action: .reminders(.stopRemindersTapped)
            )
        case .quitTapped:
            return .run { send in
                await NSApplication.shared.terminate(nil)
            }
        }
    }
}

// MARK: - Reminder Delegate
extension AppFeature {
    fileprivate func reduceReminderDelegate(
        _ state: inout State,
        action: ReminderFeature.Action.Delegate
    ) -> Effect<Action> {
        switch action {
        case .dismissTapped:
            return reduce(
                into: &state,
                action: .reminders(.reminderDismissTapped)
            )

        case .snoozeTapped:
            return reduce(
                into: &state,
                action: .reminders(.reminderSnoozeTapped)
            )
        }
    }
}

// MARK: - Reminders Delegate
extension AppFeature {
    fileprivate func reduceRemindersDelegate(
        _ state: inout State,
        action: RemindersFeature.Action.Delegate
    ) -> Effect<Action> {
        switch action {
        case .dismissReminder:
            return dismissReminder(&state)
        case .showReminder:
            return showReminder(&state)
        }
    }
}

// MARK: - Window presentation
extension AppFeature {
    fileprivate func showWindow(_ state: inout State, window: WindowID)
        -> Effect<Action>
    {
        state.openWindow = window

        switch window.destination {
        case .launchAtLogin, .main, .settings:
            return activateApp()
        case .reminder:
            return .none
        }
    }

    fileprivate func dismissWindow(_ state: inout State, window: WindowID)
        -> Effect<Action>
    {
        state.dismissWindow = window
        return .none
    }

    fileprivate func showReminder(_ state: inout State) -> Effect<Action> {
        return showWindow(&state, window: WindowID(destination: .reminder))
    }

    fileprivate func dismissReminder(_ state: inout State) -> Effect<Action> {
        dismissWindow(&state, window: WindowID(destination: .reminder))
    }

    private func activateApp() -> Effect<Action> {
        return .run { send in
            // Activate the app to bring it to front
            DispatchQueue.main.async {
                NSRunningApplication.current.activate(
                    options: .activateAllWindows
                )
            }
        }
    }
}
