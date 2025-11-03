# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Kopniak** (Sergeant Kopniak) is a native macOS menu bar utility that reminds users to take breaks from computer work. The app sends periodic reminders with military-themed motivational messages and allows customization of reminder intervals, pause/resume functionality, and launch-at-login behavior.

## Architecture

### Technology Stack

- **SwiftUI** - Application windows and UI views (BriefingView, SettingsView, LaunchAtLoginView)
- **The Composable Architecture (TCA)** - State management and application architecture (all Swift files use TCA reducers)
- **AppKit** - macOS-specific APIs:
  - NSStatusItem and NSMenu for menu bar icon and dropdown menu (StatusItemController)
  - NSPanel for custom floating reminder windows (FloatingWindow)
  - ServiceManagement for launch-at-login functionality
  - NSWorkspace and DistributedNotificationCenter for system idle state monitoring
- **Swift 5.0+** language version
- **Testing frameworks** - Swift Testing (unit tests) and XCTest (UI tests)

### Architectural Pattern: The Composable Architecture (TCA)

The entire app uses TCA's feature-based reducer pattern. Understanding this is essential:

**Core Concepts:**
- Each feature is a `@Reducer` struct with:
  - `@ObservableState var State` - App state for that feature
  - `enum Action` - All possible events (often with nested `Delegate` cases for parent communication)
  - `var body` - Reducer implementation using `Reduce`, `Scope`, and `Emit` operators
- Root feature `AppFeature` orchestrates all child features
- Delegate actions enable parent-child communication (e.g., `ReminderFeature.delegate(.snoozeTapped)` → `RemindersFeature` resets timer)
- `@Shared` state with `AppStorage` for persistence (remindersStatus, reminderInterval, remainingTime, launchAtLoginResponseReceived)

**Feature Hierarchy:**
```
AppFeature (root reducer, manages windows and overall state)
├── AppMenuFeature → menu bar menu (AppKit NSMenu)
├── AppMenuIconFeature → menu bar icon with timer display
├── BriefingFeature → main information window
├── ReminderFeature → reminder popup window
├── RemindersFeature → core timer logic and reminder scheduling
│   └── IdleMonitorFeature → observes system idle state changes
├── SettingsFeature → settings window
└── LaunchAtLoginFeature → launch-at-login prompt
```

**State Flow Example:**
1. `RemindersFeature` timer ticks → updates `remainingTime` in `@Shared` state
2. When timer reaches zero → sends `delegate(.showReminder)` action to AppFeature
3. `AppFeature` handles delegate action → calls `showWindow()` to display reminder window with ReminderFeature
4. User interacts (e.g., snooze) → `ReminderFeature.delegate(.snoozeTapped)` → `AppFeature` → `RemindersFeature` resets timer

**Dependency Injection:**
- Features define dependencies (e.g., `ReminderContentSourceDependency`, `SMAppServiceDependency`)
- Each dependency has `liveValue` and `previewValue` for testability
- Injected via TCA's dependency system

### Directory Structure

```
Kopniak/                           # Main Xcode project directory
├── Kopniak/                       # Source code
│   ├── KopniakApp.swift           # SwiftUI app entry point
│   ├── AppFeature.swift           # Root reducer
│   ├── Assets.xcassets/           # App icons and color assets
│   ├── StatusItem/                # Menu bar icon and menu (AppKit)
│   │   ├── AppMenuFeature.swift   # Menu bar menu feature (TCA reducer)
│   │   ├── AppMenuIconFeature.swift # Menu bar icon state (TCA reducer)
│   │   └── StatusItemController.swift # AppKit NSStatusItem and NSMenu setup
│   ├── Briefing/                  # Main info window feature
│   │   ├── BriefingFeature.swift
│   │   └── BriefingView.swift
│   ├── Reminder/                  # Reminder popup window feature
│   │   ├── ReminderFeature.swift
│   │   ├── ReminderView.swift
│   │   ├── ReminderController.swift # AppKit NSPanel management
│   │   └── Utils/
│   │       └── FloatingWindow.swift # Custom NSPanel for floating window
│   ├── Reminders/                 # Core timer and reminder logic
│   │   └── RemindersFeature.swift # Timer scheduling and idle integration
│   ├── IdleMonitor/               # Idle state monitoring
│   │   └── IdleMonitorFeature.swift # System idle state observation
│   ├── Settings/                  # Settings window feature
│   │   ├── SettingsFeature.swift
│   │   └── SettingsView.swift
│   └── LaunchAtLogin/             # Launch-at-login feature
│       ├── LaunchAtLoginFeature.swift
│       └── LaunchAtLoginView.swift
├── KopniakTests/                  # Unit tests
└── KopniakUITests/                # UI tests
├── Kopniak.xcodeproj/             # Xcode project configuration
├── README.md
└── LICENSE (MIT)
```

## Common Development Commands

### Building
```bash
# Build via Xcode
xcodebuild build -scheme Kopniak

# Build and run from command line
xcodebuild run -scheme Kopniak
```

### Running Tests
```bash
# Run all tests (both unit and UI)
xcodebuild test -scheme Kopniak

# Run unit tests only
xcodebuild test -scheme Kopniak -only-testing KopniakTests

# Run UI tests only
xcodebuild test -scheme Kopniak -only-testing KopniakUITests

# Run single test from command line
xcodebuild test -scheme Kopniak -only-testing "KopniakTests/TestClassName/testMethodName"
```

### Running in Xcode
- **Build & Run:** Cmd+R
- **Run Tests:** Cmd+U
- **Build Only:** Cmd+B

## Key Implementation Details

### Menu Bar Implementation (StatusItem)
- **StatusItemController** is the AppKit-based controller managing the NSStatusItem and NSMenu
  - Located in `StatusItem/StatusItemController.swift`
  - Created and activated in `KopniakApp.swift` during app startup
  - Manages both the menu bar icon (with timer display) and the dropdown menu
- **Icon Setup** (`setupIcon()` method):
  - Updates icon image based on `remindersStatus` (active/inactive chevron icons)
  - Displays countdown timer formatted as MM:SS when reminders are active
  - Uses monospaced digit font (13pt) for consistent timer display
  - Subscribed to `remainingTime` and `remindersStatus` from `@Shared` state
- **Menu Setup** (`setupMenu()` method):
  - Creates NSMenu with items mirroring the original SwiftUI AppMenuView structure
  - Menu items include icons (SF Symbols) and keyboard shortcuts (Cmd+B, Cmd+R, etc.)
  - Dynamically rebuilds menu when `remindersStatus` changes to show context-appropriate actions
  - Actions dispatch delegate actions to `AppMenuFeature` for parent handling

### Floating Reminder Window
- Custom `FloatingWindow` utility (extends NSPanel) creates floating, non-activating reminder window
- Located in `Reminder/Utils/FloatingWindow.swift`
- Shows reminder popup without stealing focus from user's current task

### Timer Logic
- `RemindersFeature.swift` contains all timer scheduling and reminder generation
- Uses `Effect` operators for continuous timer emission
- Respects `remindersStatus` state (.off, .on, .paused)
- `reminderInterval` is user-configurable (stored in AppStorage)

### Idle State Monitoring
- `IdleMonitorFeature` observes system events indicating the computer is idle or active
- Observations include:
  - **Screen lock/unlock** via `DistributedNotificationCenter` (`com.apple.screenIsLocked`, `com.apple.screenIsUnlocked`)
  - **Display sleep/wake** via `NSWorkspace.shared.notificationCenter` (per Apple documentation)
  - **System sleep/wake** via `NSWorkspace.shared.notificationCenter`
  - **Session resign/become active** via `NSWorkspace.shared.notificationCenter` (for fast user switching)
- Behavior:
  - When computer enters idle state and `remindersStatus == .on` → timer is **cancelled** (paused)
  - When computer exits idle state and `remindersStatus == .on` → timer is **restarted**
  - **Important**: Idle state never modifies `remindersStatus` itself—only timer control
- Idle observation lifecycle is tied to `remindersStatus`:
  - `remindersStatus == .on` → idle observation is active
  - `remindersStatus == .off` or `.paused` → idle observation is stopped
- Uses `AsyncStream`-based dependency injection for testability with `liveValue` and `previewValue`

### State Persistence
- Key state persisted via `@Shared` + `AppStorage`:
  - `remindersStatus` - current state of reminders
  - `reminderInterval` - time between reminders (seconds)
  - `remainingTime` - countdown display
  - `launchAtLoginResponseReceived` - UI dialog state
- AppStorage automatically syncs to UserDefaults

### Launch-at-Login
- `LaunchAtLoginFeature` wraps macOS ServiceManagement API via `SMAppServiceDependency`
- Uses dependency injection for testability
- Shows confirmation dialog after enabling/disabling

### Reminder Content
- Military-themed motivational messages provided by `ReminderContentSourceDependency`
- Messages rotate through available quotes
- Injected as a dependency for easy testing and customization

## Working with TCA in This Codebase

### When Adding a New Feature

1. Create a new feature file (e.g., `MyFeature.swift`)
2. Define the `@Reducer` struct with `@ObservableState State`
3. Define `enum Action` with nested `Delegate` cases if communicating with parent
4. Implement `var body` using `Reduce` to handle state changes
5. Use `Scope` to compose child features
6. Register in parent feature's reducer (usually `AppFeature`)
7. Create corresponding `MyView.swift` for SwiftUI implementation

### Dependency Injection Pattern

```swift
// Define dependency
struct MyDependency: DependencyKey {
    var getValue: @Sendable () -> String

    static let liveValue = Self(
        getValue: { /* real implementation */ }
    )

    static let previewValue = Self(
        getValue: { "preview" }
    )
}

// Extend DependencyValues
extension DependencyValues {
    var myDependency: MyDependency {
        get { self[MyDependency.self] }
        set { self[MyDependency.self] = newValue }
    }
}

// Use in feature
@Dependency(\.myDependency) var myDep
```

**AsyncStream-based Dependency Example** (used in `IdleMonitorFeature`):
```swift
struct IdleNotificationObserverDependency: DependencyKey {
    var observeScreenLock: @Sendable () async -> AsyncStream<Void>

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
        }
    )

    static let previewValue = Self(
        observeScreenLock: { AsyncStream { _ in } }
    )
}
```

### Handling Async Operations

- Use `Effect` and `.run` for async work in reducers
- Emit actions from async tasks to update state
- Use `withDependencies` to inject dependencies into async contexts

## Testing Notes

- Unit tests currently exist as stubs in `KopniakTests.swift`
- UI tests in `KopniakUITests/` directory
- TCA makes testing easier via dependency injection (swap `liveValue` with `testValue`)
- No linting or formatting tools currently configured (consider SwiftLint/SwiftFormat for future)

## Git Context

- Main development branch uses TCA (The Composable Architecture) throughout
- Recent feature branches focus on:
  - Idle state monitoring integration (pauses reminders when computer is idle)
  - Timer logic optimization
  - State management improvements
- Key recent commits:
  - `observe more idle state notifications` - comprehensive idle event observation
  - `add IdleMonitorFeature to track idle state` - new idle monitoring feature

## Platform Specifics

- **macOS 15.0+** deployment target for the app
- **macOS 26.0+** deployment target for tests (beta/latest)
- Xcode project uses modern file system-synchronized build configuration
- No cross-platform considerations

## Gotchas and Tips

1. **Delegate Actions:** When a child feature needs to communicate with parent, use nested `Delegate` cases in `Action` enum. Parent must explicitly handle these delegate actions.

2. **Shared State:** State persisted with `@Shared` syncs to AppStorage automatically. Be careful with mutation - changes trigger re-renders.

3. **Timer State:** The countdown timer in `AppMenuIconFeature` updates frequently. Performance is good but be mindful when adding computed properties that depend on `remainingTime`.

4. **Window Management:** `AppFeature.showWindow()` is responsible for opening/closing windows. All window state lives in `AppFeature`, not in child features.

5. **macOS App Delegate:** Since this is a menu bar app with no dock icon (typically), ensure any AppKit-level setup is in `KopniakApp.swift`.

6. **Menu Bar Implementation:** The menu bar is implemented using AppKit's NSStatusItem and NSMenu (via StatusItemController) instead of SwiftUI's MenuBarExtra. This allows for:
   - Fixed-width menu bar item (no variable width issues)
   - Full control over menu appearance and behavior
   - Direct integration with TCA reducer state
   - More reliable keyboard shortcuts and menu updates
   - The controller subscribes to state changes and rebuilds the menu dynamically

7. **Menu Bar Icon:** The icon displays the remaining time (MM:SS). This requires frequent state updates via `@Shared` - it's intentional and performant. Uses monospaced font for consistent timer display.

8. **Idle State Handling:** Idle monitoring only pauses/resumes timers, never modifies `remindersStatus`. The observation lifecycle is tied to `remindersStatus == .on`—when reminders are off or paused, idle monitoring is not active. This keeps idle state separate from user intent for reminder status.

9. **Notification Centers:** Always use the notification center documented by Apple for each notification type:
   - `DistributedNotificationCenter` for system-wide notifications (e.g., screen lock/unlock)
   - `NSWorkspace.shared.notificationCenter` for workspace events (e.g., display sleep, system sleep, session changes)
   - Using the correct center ensures reliable delivery to background menu bar apps

## Debugging Tips

- Use Xcode's debugger with breakpoints on actions in reducers
- Print state changes in reducer's `Reduce` block for debugging
- Use TCA's `.debugActions()` effect to log all actions in development
- AppKit windows (reminder, briefing) can be debugged with Xcode's View Hierarchy debugger
