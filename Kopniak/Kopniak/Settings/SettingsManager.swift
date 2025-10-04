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
    
    /// Cached launch at login state to prevent UI flickering during system calls
    private var _launchAtLogin: Bool?

    // MARK: - UserDefaults Keys

    private let reminderIntervalKey = "SettingsManager.reminderIntervalMinutes"
    private let showMainWindowOnLaunchKey = "SettingsManager.showMainWindowOnLaunch"

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
        get {
            // Use cached value if available, otherwise read from system
            return _launchAtLogin ?? (SMAppService.mainApp.status == .enabled)
        }
        set {
            // Immediately update the cached state to prevent UI flickering
            _launchAtLogin = newValue
            updateLaunchAtLogin(newValue)
        }
    }

    // MARK: - Initialization

    init() {
        // Load settings from UserDefaults with default values
        self.reminderIntervalMinutes = userDefaults.object(forKey: reminderIntervalKey) as? Int ?? 45
        self.showMainWindowOnLaunch = userDefaults.object(forKey: showMainWindowOnLaunchKey) as? Bool ?? true
        
        // Initialize launch at login state from system
        self._launchAtLogin = SMAppService.mainApp.status == .enabled
    }

    // MARK: - Launch at Login Implementation

    private func updateLaunchAtLogin(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
            
            // Update cached state after successful operation
            _launchAtLogin = enabled
        } catch {
            NSLog("Failed to \(enabled ? "enable" : "disable") launch at login: \(error)")
            
            // Revert cached state on failure and refresh UI
            _launchAtLogin = SMAppService.mainApp.status == .enabled
        }
    }
    
    /// Refreshes the launch at login state from the system
    /// Call this method if you need to ensure the UI reflects the current system state
    func refreshLaunchAtLoginState() {
        _launchAtLogin = SMAppService.mainApp.status == .enabled
    }
}
