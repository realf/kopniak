# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Kopniak** (Sergeant Kopniak) is a native macOS menu bar utility that reminds users to take breaks from computer work. The app sends periodic reminders with military-themed motivational messages and allows customization of reminder intervals, pause/resume functionality, and launch-at-login behavior.

## Directory Structure

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

## Important Notes

1. **Delegate Actions:** When a child feature needs to communicate with parent, use nested `Delegate` cases in `Action` enum. Parent must explicitly handle these delegate actions.

2. **Shared State:** State persisted with `@Shared` syncs to AppStorage automatically. Be careful with mutation - changes trigger re-renders.

3. **Window Management:** `AppFeature.showWindow()` is responsible for opening/closing windows. All window state lives in `AppFeature`, not in child features.

4. **AppKit Setup:** Since this is a menu bar app, all AppKit-level setup (StatusItemController, ReminderController) is in `KopniakApp.swift`.
