//
//  SoundPlaybackDependency.swift
//  Sergeant Kopniak
//
//  Created by alf on 12.11.2025.
//

import AppKit
import ComposableArchitecture

struct SoundPlaybackDependency {
    var playSound: (_ soundName: String, _ volume: Double) async -> Void
}

// Conform to DependencyKey to provide a live and preview implementation of the interface.
extension SoundPlaybackDependency: DependencyKey {
    static let liveValue: SoundPlaybackDependency = {
        @Dependency(\.soundCache) var soundCache

        return Self { soundName, volume in
            // First, try to get cached sound
            if let cachedSound = await soundCache.getCachedSound(soundName) {
                cachedSound.volume = Float(volume)
                cachedSound.play()
                return
            }

            // Fall back to creating new NSSound if not cached
            guard let sound = NSSound(named: soundName) else {
                // Sound not available, fall back to beep
                NSLog("Sound not found: \(soundName), playing beep instead")
                NSSound.beep()
                return
            }
            sound.volume = Float(volume)
            sound.play()
        }
    }()

    static let previewValue = Self { soundName, volume in
        print("Playing sound: \(soundName) at volume: \(Int(volume * 100))%")
    }
}

// Register the dependency within DependencyValues.
extension DependencyValues {
    var soundPlayback: SoundPlaybackDependency {
        get { self[SoundPlaybackDependency.self] }
        set { self[SoundPlaybackDependency.self] = newValue }
    }
}
