# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Kopniak** (Sergeant Kopniak) is a native macOS menu bar utility that reminds users to take breaks from computer work. The app sends periodic reminders with military-themed motivational messages and allows customization of reminder intervals, pause/resume functionality, and launch-at-login behavior.

## Architecture

### Technology Stack

- **SwiftUI** - All UI implementation (modern declarative framework)
- **The Composable Architecture (TCA)** - State management and application architecture (16/20 Swift files use this)
- **AppKit** - macOS-specific APIs (menu bar, ServiceManagement for launch-at-login, custom NSPanel for floating windows)
- **Swift 5.0** language version
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
├── AppMenuFeature → menu bar menu
├── AppMenuIconFeature → menu bar icon with timer display
├── BriefingFeature → main information window
├── ReminderFeature → reminder popup window
├── RemindersFeature → core timer logic and reminder scheduling
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
│   ├── AppFeature.swift           # Root reducer (324 lines)
│   ├── Assets.xcassets/           # App icons and color assets
│   ├── AppMenu/                   # Menu bar menu feature
│   │   ├── AppMenuFeature.swift
│   │   └── AppMenuView.swift
│   ├── AppMenuIcon/               # Menu bar icon feature (separate from menu)
│   │   ├── AppMenuIconFeature.swift
│   │   └── AppMenuIconView.swift
│   ├── Briefing/                  # Main info window feature
│   │   ├── BriefingFeature.swift
│   │   └── BriefingView.swift
│   ├── Reminder/                  # Reminder popup window feature
│   │   ├── ReminderFeature.swift
│   │   ├── ReminderView.swift
│   │   ├── ReminderController.swift
│   │   └── Utils/
│   │       └── FloatingWindow.swift # Custom NSPanel for floating window
│   ├── Reminders/                 # Core timer and reminder logic
│   │   └── RemindersFeature.swift (243 lines)
│   ├── Settings/                  # Settings window feature
│   │   ├── SettingsFeature.swift
│   │   └── SettingsView.swift
│   └── LaunchAtLogin/             # Launch-at-login feature
│       ├── LaunchAtLoginFeature.swift
│       └── LaunchAtLoginView.swift
├── KopniakTests/                  # Unit tests (mostly stubs)
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

### Menu Bar Implementation
- `AppMenuIconFeature` manages the menu bar icon with live timer countdown display
- Icon updates via `remainingTime` state from `@Shared` (persisted across app restarts)
- Menu managed by `AppMenuFeature` with standard macOS menu items

### Floating Reminder Window
- Custom `FloatingWindow` utility (extends NSPanel) creates floating, non-activating reminder window
- Located in `Reminder/Utils/FloatingWindow.swift`
- Shows reminder popup without stealing focus from user's current task

### Timer Logic
- `RemindersFeature.swift` contains all timer scheduling and reminder generation
- Uses `Effect` operators for continuous timer emission
- Respects `remindersStatus` state (.off, .on, .paused)
- `reminderInterval` is user-configurable (stored in AppStorage)

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
struct MyDependency {
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

- Currently on branch `feature/tca-transition` - indicates recent or ongoing migration to TCA
- Recent commits focus on:
  - TCA migration and reducer refactoring
  - Feature renaming
  - UI/copy improvements
  - Timer logic fixes

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

6. **Menu Bar Icon:** The icon displays the remaining time. This requires frequent state updates via `@Shared` - it's intentional and performant.

## Debugging Tips

- Use Xcode's debugger with breakpoints on actions in reducers
- Print state changes in reducer's `Reduce` block for debugging
- Use TCA's `.debugActions()` effect to log all actions in development
- AppKit windows (reminder, briefing) can be debugged with Xcode's View Hierarchy debugger
