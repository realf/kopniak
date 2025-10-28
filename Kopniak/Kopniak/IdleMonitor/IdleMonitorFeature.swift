//
//  IdleMonitorFeature.swift
//  Sergeant Kopniak
//
//  Created by Claude Code on 25.10.2025.
//

import AppKit
import ComposableArchitecture
import Foundation

// MARK: - Notification Observer Dependency

struct IdleNotificationObserverDependency: DependencyKey {
    var observeScreenLock: @Sendable () async -> AsyncStream<Void>
    var observeScreenUnlock: @Sendable () async -> AsyncStream<Void>

    static let liveValue = Self(
        observeScreenLock: {
            AsyncStream { continuation in
                let observer = DistributedNotificationCenter.default().addObserver(
                    forName: NSNotification.Name("com.apple.screenIsLocked"),
                    object: nil,
                    queue: nil
                ) { _ in
                    continuation.yield()
                }
                continuation.onTermination = { _ in
                    DistributedNotificationCenter.default().removeObserver(observer)
                }
            }
        },
        observeScreenUnlock: {
            AsyncStream { continuation in
                let observer = DistributedNotificationCenter.default().addObserver(
                    forName: NSNotification.Name("com.apple.screenIsUnlocked"),
                    object: nil,
                    queue: nil
                ) { _ in
                    continuation.yield()
                }
                continuation.onTermination = { _ in
                    DistributedNotificationCenter.default().removeObserver(observer)
                }
            }
        }
    )

    static let previewValue = Self(
        observeScreenLock: { AsyncStream { _ in } },
        observeScreenUnlock: { AsyncStream { _ in } }
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
                    observeScreenUnlock()
                )

            case .stopObserving:
                guard state.isObserving else {
                    return .none
                }
                state.isObserving = false
                return .merge(
                    .cancel(id: ObservationID.screenLock),
                    .cancel(id: ObservationID.screenUnlock)
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

    nonisolated enum ObservationID: Hashable {
        case screenLock
        case screenUnlock
    }
}
