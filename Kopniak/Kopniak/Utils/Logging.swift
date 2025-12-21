//
//  Logging.swift
//  Kopniak
//
//  Created by alf on 20.12.2025.
//

import Foundation
import OSLog

extension Logger {
    static let launchAtLoginLogging = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "Launch At Login")
    static let settingsLogging = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "Settings")
    static let soundsLogging = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "Sounds")
}
