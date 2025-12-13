//
//  IdleMonitorFeature.swift
//  Sergeant Kopniak
//
//  Created by alf on 25.10.2025.
//

import AppKit
import ComposableArchitecture
import Foundation

// MARK: - Notification Observer Dependency

struct IdleNotificationObserverDependency: DependencyKey {
    var observeScreenLock: @Sendable () async -> AsyncStream<Void>
    var observeScreenUnlock: @Sendable () async -> AsyncStream<Void>
    var observeSessionDidResignActive: @Sendable () async -> AsyncStream<Void>
    var observeSessionDidBecomeActive: @Sendable () async -> AsyncStream<Void>
    var observeWillSleep: @Sendable () async -> AsyncStream<Void>
    var observeDidWake: @Sendable () async -> AsyncStream<Void>

    private static let workspaceCenter = NSWorkspace.shared
        .notificationCenter
    private static let distributedCenter =
        DistributedNotificationCenter.default()

    static let liveValue = Self(
        observeScreenLock: {
            AsyncStream { continuation in
                let observer = distributedCenter.addObserver(
                    forName: NSNotification.Name(
                        "com.apple.screenIsLocked"
                    ),
                    object: nil,
                    queue: nil
                ) { _ in
                    continuation.yield()
                }
                continuation.onTermination = { _ in
                    distributedCenter.removeObserver(observer)
                }
            }
        },
        observeScreenUnlock: {
            AsyncStream { continuation in
                let observer = distributedCenter.addObserver(
                    forName: NSNotification.Name(
                        "com.apple.screenIsUnlocked"
                    ),
                    object: nil,
                    queue: nil
                ) { _ in
                    continuation.yield()
                }
                continuation.onTermination = { _ in
                    distributedCenter.removeObserver(observer)
                }
            }
        },
        observeSessionDidResignActive: {
            AsyncStream { continuation in
                let observer = workspaceCenter.addObserver(
                    forName: NSWorkspace.sessionDidResignActiveNotification,
                    object: nil,
                    queue: nil
                ) { _ in
                    continuation.yield()
                }
                continuation.onTermination = { _ in
                    workspaceCenter.removeObserver(observer)
                }
            }
        },
        observeSessionDidBecomeActive: {
            AsyncStream { continuation in
                let observer = workspaceCenter.addObserver(
                    forName: NSWorkspace.sessionDidBecomeActiveNotification,
                    object: nil,
                    queue: nil
                ) { _ in
                    continuation.yield()
                }
                continuation.onTermination = { _ in
                    workspaceCenter.removeObserver(observer)
                }
            }
        },
        observeWillSleep: {
            AsyncStream { continuation in
                let observer = workspaceCenter.addObserver(
                    forName: NSWorkspace.willSleepNotification,
                    object: nil,
                    queue: nil
                ) { _ in
                    continuation.yield()
                }
                continuation.onTermination = { _ in
                    workspaceCenter.removeObserver(observer)
                }
            }
        },
        observeDidWake: {
            AsyncStream { continuation in
                let observer = workspaceCenter.addObserver(
                    forName: NSWorkspace.didWakeNotification,
                    object: nil,
                    queue: nil
                ) { _ in
                    continuation.yield()
                }
                continuation.onTermination = { _ in
                    workspaceCenter.removeObserver(observer)
                }
            }
        }
    )

    static let previewValue = Self(
        observeScreenLock: { AsyncStream { _ in } },
        observeScreenUnlock: { AsyncStream { _ in } },
        observeSessionDidResignActive: { AsyncStream { _ in } },
        observeSessionDidBecomeActive: { AsyncStream { _ in } },
        observeWillSleep: { AsyncStream { _ in } },
        observeDidWake: { AsyncStream { _ in } }
    )
}

extension DependencyValues {
    var idleNotificationObserver: IdleNotificationObserverDependency {
        get { self[IdleNotificationObserverDependency.self] }
        set { self[IdleNotificationObserverDependency.self] = newValue }
    }
}

// MARK: - IdleMonitorFeature

@Reducer
struct IdleMonitorFeature {
    @Dependency(\.idleNotificationObserver) var notificationObserver

    @ObservableState
    struct State {
        var isObserving: Bool = false
    }

    enum Action {
        case startObserving
        case stopObserving
        case delegate(Delegate)

        enum Delegate {
            case screenDidLock
            case screenDidUnlock
            case sessionDidBecomeActive
            case sessionDidResignActive
            case systemWillSleep
            case systemDidWake
        }
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .startObserving:
                guard !state.isObserving else {
                    return .none
                }
                state.isObserving = true
                return .merge(
                    observeScreenLock(),
                    observeScreenUnlock(),
                    observeSessionDidBecomeActive(),
                    observeSessionDidResignActive(),
                    observeDidWake(),
                    observeWillSleep()
                )

            case .stopObserving:
                guard state.isObserving else {
                    return .none
                }
                state.isObserving = false
                return .merge(
                    .cancel(id: ObservationID.screenLock),
                    .cancel(id: ObservationID.screenUnlock),
                    .cancel(id: ObservationID.sessionDidBecomeActive),
                    .cancel(id: ObservationID.sessionDidResignActive),
                    .cancel(id: ObservationID.systemDidWake),
                    .cancel(id: ObservationID.systemWillSleep)
                )

            case .delegate:
                return .none
            }
        }
    }

    private func observeScreenLock() -> Effect<Action> {
        .run { send in
            for await _ in await notificationObserver.observeScreenLock() {
                await send(.delegate(.screenDidLock))
            }
        }
        .cancellable(id: ObservationID.screenLock)
    }

    private func observeScreenUnlock() -> Effect<Action> {
        .run { send in
            for await _ in await notificationObserver.observeScreenUnlock() {
                await send(.delegate(.screenDidUnlock))
            }
        }
        .cancellable(id: ObservationID.screenUnlock)
    }

    private func observeSessionDidBecomeActive() -> Effect<Action> {
        .run { send in
            for await _
                in await notificationObserver.observeSessionDidBecomeActive()
            {
                await send(.delegate(.sessionDidBecomeActive))
            }
        }
        .cancellable(id: ObservationID.sessionDidBecomeActive)
    }

    private func observeSessionDidResignActive() -> Effect<Action> {
        .run { send in
            for await _
                in await notificationObserver.observeSessionDidResignActive()
            {
                await send(.delegate(.sessionDidResignActive))
            }
        }
        .cancellable(id: ObservationID.sessionDidResignActive)
    }

    private func observeWillSleep() -> Effect<Action> {
        .run { send in
            for await _
                in await notificationObserver.observeWillSleep()
            {
                await send(.delegate(.systemWillSleep))
            }
        }
        .cancellable(id: ObservationID.systemWillSleep)
    }

    private func observeDidWake() -> Effect<Action> {
        .run { send in
            for await _
                in await notificationObserver.observeDidWake()
            {
                await send(.delegate(.systemDidWake))
            }
        }
        .cancellable(id: ObservationID.systemDidWake)
    }

    enum ObservationID: Hashable {
        case screenLock
        case screenUnlock
        case sessionDidBecomeActive
        case sessionDidResignActive
        case systemDidWake
        case systemWillSleep
    }
}
