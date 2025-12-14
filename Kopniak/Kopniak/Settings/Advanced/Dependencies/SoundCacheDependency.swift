//
//  SoundCacheDependency.swift
//  Sergeant Kopniak
//
//  Created by alf on 27.11.2025.
//

import AppKit
import ComposableArchitecture

/// Dependency for caching preloaded NSSound objects to eliminate first-play delay
struct SoundCacheDependency {
    /// Preload a sound by name into the cache
    var preloadSound: @Sendable (String) async -> Void

    /// Retrieve a cached sound by name, returns nil if not cached
    var getCachedSound: @Sendable (String) async -> NSSound?
}

extension SoundCacheDependency: DependencyKey {
    static let liveValue: SoundCacheDependency = {
        let cache = SoundCache()

        return SoundCacheDependency(
            preloadSound: { soundName in
                await cache.preload(soundName: soundName)
            },
            getCachedSound: { soundName in
                await cache.get(soundName: soundName)
            }
        )
    }()

    static let previewValue = SoundCacheDependency(
        preloadSound: { _ in },
        getCachedSound: { _ in nil }
    )
}

extension DependencyValues {
    var soundCache: SoundCacheDependency {
        get { self[SoundCacheDependency.self] }
        set { self[SoundCacheDependency.self] = newValue }
    }
}

// MARK: - Sound Cache Actor

/// Thread-safe actor for managing cached NSSound objects
private actor SoundCache {
    private var cache: [String: NSSound] = [:]

    /// Default sound to use for initializing the audio system
    static let defaultSound = "Ping"

    /// Preload a sound into the cache
    func preload(soundName: String) {
        // Check if already cached
        if cache[soundName] != nil {
            return
        }

        // Load the sound
        guard let sound = NSSound(named: soundName) else {
            NSLog("Failed to preload sound: \(soundName)")
            return
        }

        // Cache it
        cache[soundName] = sound
    }

    /// Retrieve a cached sound
    func get(soundName: String) -> NSSound? {
        return cache[soundName]
    }
}
