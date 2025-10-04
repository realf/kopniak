//
//  OnboardingManager.swift
//  Sergeant Kopniak
//
//  Created by alf on 03.10.2025.
//

import Foundation
import SwiftUI
import ServiceManagement

enum LaunchAtLoginDialogResponse {
    case enable
    case disable
    case askLater
}

@MainActor
@Observable
class OnboardingManager {
    // MARK: - Properties

    private let settingsManager: SettingsManager
    private let reminderManager: ReminderManager
    private let openWindow: OpenWindowAction
    private let userDefaults = UserDefaults.standard

    // MARK: - UserDefaults Keys

    private let launchAtLoginDialogShownKey = "OnboardingManager.launchAtLoginDialogShown"
    private let nextDialogAtCountKey = "OnboardingManager.nextDialogAtCount"

    // MARK: - Dialog Tracking Properties

    private(set) var launchAtLoginDialogShown: Bool {
        get { userDefaults.bool(forKey: launchAtLoginDialogShownKey) }
        set { userDefaults.set(newValue, forKey: launchAtLoginDialogShownKey) }
    }

    private(set) var nextDialogAtCount: Int {
        get { userDefaults.integer(forKey: nextDialogAtCountKey) }
        set { userDefaults.set(newValue, forKey: nextDialogAtCountKey) }
    }

    // MARK: - Initialization

    init(settingsManager: SettingsManager, reminderManager: ReminderManager, openWindow: OpenWindowAction) {
        self.settingsManager = settingsManager
        self.reminderManager = reminderManager
        self.openWindow = openWindow

        // If launch at login is already enabled, no need to show dialog
        if SMAppService.mainApp.status == .enabled {
            launchAtLoginDialogShown = true
            nextDialogAtCount = 0
        } else {
            // Start observing for changes
            setupObservation()
        }
    }

    // MARK: - Public Methods

    func handleLaunchAtLoginDialogResponse(_ response: LaunchAtLoginDialogResponse) {
        launchAtLoginDialogShown = true

        switch response {
        case .enable:
            settingsManager.launchAtLogin = true
            // Clear the "ask later" tracking
            nextDialogAtCount = 0
        case .disable:
            settingsManager.launchAtLogin = false
            // Clear the "ask later" tracking
            nextDialogAtCount = 0
        case .askLater:
            // User selected "Ask Later" - set to ask again after 3 more activations
            let currentCount = reminderManager.reportForDutyActivationCount
            nextDialogAtCount = currentCount + 3
        }
    }

    // MARK: - Private Methods

    private func setupObservation() {
        // Use Swift's observation tracking to reactively observe changes
        withObservationTracking {
            // Observe activation count changes
            let currentCount = reminderManager.reportForDutyActivationCount
            let launchAtLoginEnabled = SMAppService.mainApp.status == .enabled

            // If user manually enabled launch at login, mark dialog as handled
            if launchAtLoginEnabled {
                launchAtLoginDialogShown = true
                nextDialogAtCount = 0
            }

            // Check if we should show the dialog
            if shouldShowLaunchAtLoginDialog(for: currentCount) {
                openWindow(id: "launch-at-login-dialog")
            }
        } onChange: {
            // Re-register observation when change is detected
            Task { @MainActor in
                self.setupObservation()
            }
        }
    }

    private func shouldShowLaunchAtLoginDialog(for activationCount: Int) -> Bool {
        // Don't show if count is less than 3
        guard activationCount > 3 else { return false }

        // Never shown before, show it
        if !launchAtLoginDialogShown {
            return true
        }

        // "Ask Later" was selected, check if we've hit the threshold
        if activationCount >= nextDialogAtCount && nextDialogAtCount > 0 {
            return true
        }

        return false
    }
}
