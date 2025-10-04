//
//  SettingsManager.swift
//  Sergeant Kopniak
//
//  Created by alf on 02.10.2025.
//

import Foundation
import AppKit
import ServiceManagement

@MainActor
@Observable
class SettingsManager {
    // MARK: - Properties

    private let userDefaults = UserDefaults.standard

    // MARK: - UserDefaults Keys

    private let reminderIntervalKey = "SettingsManager.reminderIntervalMinutes"
    private let showMainWindowOnLaunchKey = "SettingsManager.showMainWindowOnLaunch"
    private let launchAtLoginKey = "SettingsManager.launchAtLogin"

    // MARK: - Settings Properties

    var reminderIntervalMinutes: Int {
        didSet {
            userDefaults.set(reminderIntervalMinutes, forKey: reminderIntervalKey)
        }
    }

    var showMainWindowOnLaunch: Bool {
        didSet {
            userDefaults.set(showMainWindowOnLaunch, forKey: showMainWindowOnLaunchKey)
        }
    }

    var launchAtLogin: Bool {
        didSet {
            userDefaults.set(launchAtLogin, forKey: launchAtLoginKey)
            updateLaunchAtLogin(launchAtLogin)
        }
    }

    // MARK: - Initialization

    init() {
        // Load settings from UserDefaults with default values
        self.reminderIntervalMinutes = userDefaults.object(forKey: reminderIntervalKey) as? Int ?? 45
        self.showMainWindowOnLaunch = userDefaults.object(forKey: showMainWindowOnLaunchKey) as? Bool ?? true
        self.launchAtLogin = userDefaults.bool(forKey: launchAtLoginKey)
    }

    // MARK: - Launch at Login Implementation

    private func updateLaunchAtLogin(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            NSLog("Failed to \(enabled ? "enable" : "disable") launch at login: \(error)")
        }
    }
}
