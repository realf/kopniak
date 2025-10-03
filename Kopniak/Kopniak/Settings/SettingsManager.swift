//
//  SettingsManager.swift
//  Sergeant Kopniak
//
//  Created by alf on 02.10.2025.
//

import Foundation
import AppKit

@MainActor
@Observable
class SettingsManager {
    // MARK: - Properties

    private let userDefaults = UserDefaults.standard

    // MARK: - UserDefaults Keys

    private let reminderIntervalKey = "SettingsManager.reminderInterval"
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

    // MARK: - Initialization

    init() {
        // Load settings from UserDefaults with default values
        self.reminderIntervalMinutes = userDefaults.object(forKey: reminderIntervalKey) as? Int ?? 45
        self.showMainWindowOnLaunch = userDefaults.object(forKey: showMainWindowOnLaunchKey) as? Bool ?? true
    }
}
