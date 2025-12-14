//
//  SystemSoundsDependency.swift
//  Sergeant Kopniak
//
//  Created by alf on 12.11.2025.
//

import AppKit
import ComposableArchitecture
import Foundation

struct SystemSoundsDependency {
    var availableSounds: @Sendable () -> [String]
}

// Conform to DependencyKey to provide a live and preview implementation of the interface.
extension SystemSoundsDependency: DependencyKey {
    static let liveValue = Self {
        getAvailableSystemSounds()
    }

    static let previewValue = Self {
        // Preview with sounds that are commonly available
        [
            "Basso",
            "Blow",
            "Bottle",
            "Frog",
            "Funk",
            "Glass",
            "Hero",
            "Morse",
            "Ping",
            "Pop",
            "Purr",
            "Sosumi",
            "Submarine",
            "Tink",
        ]
    }
}

// Register the dependency within DependencyValues.
extension DependencyValues {
    var systemSounds: SystemSoundsDependency {
        get { self[SystemSoundsDependency.self] }
        set { self[SystemSoundsDependency.self] = newValue }
    }
}

// MARK: - Helper function to get available system sounds

private func getAvailableSystemSounds() -> [String] {
    var availableSounds: [String] = []
    let fileManager = FileManager.default

    // Search in standard macOS system sound directory
    let soundDirectory = "/System/Library/Sounds"

    do {
        let files = try fileManager.contentsOfDirectory(atPath: soundDirectory)
        for file in files {
            // Get the filename without extension
            let soundName = (file as NSString).deletingPathExtension

            // Verify the sound can be loaded
            if NSSound(named: soundName) != nil {
                availableSounds.append(soundName)
            }
        }
    } catch {
        NSLog("Error reading system sounds directory: \(error)")
    }

    // Sort alphabetically for consistent display
    return availableSounds.sorted()
}
