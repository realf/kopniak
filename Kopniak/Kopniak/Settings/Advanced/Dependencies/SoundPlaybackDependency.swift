//
//  SoundPlaybackDependency.swift
//  Sergeant Kopniak
//
//  Created by alf on 12.11.2025.
//

import AppKit
import ComposableArchitecture

struct SoundPlaybackDependency {
    var playSound: (_ soundName: String, _ volume: Double) -> Void
}

// Conform to DependencyKey to provide a live and preview implementation of the interface.
extension SoundPlaybackDependency: DependencyKey {
    static let liveValue = Self { soundName, volume in
        guard let sound = NSSound(named: soundName) else {
            // Sound not available, fall back to beep
            NSLog("Sound not found: \(soundName), playing beep instead")
            NSSound.beep()
            return
        }
        sound.volume = Float(volume)
        sound.play()
    }

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
