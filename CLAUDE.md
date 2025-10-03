# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Kopniak (Sergeant Kopniak) is a macOS app that provides military-themed break reminders to prevent prolonged computer use. The app runs in the menu bar and shows floating reminder windows at configurable intervals.

## Build and Test Commands

```bash
# Build the app
xcodebuild -project Kopniak/Kopniak.xcodeproj -scheme Kopniak -configuration Debug build

# Build for release
xcodebuild -project Kopniak/Kopniak.xcodeproj -scheme Kopniak -configuration Release build

# Run tests
xcodebuild test -project Kopniak/Kopniak.xcodeproj -scheme Kopniak -destination 'platform=macOS'

# Build and run (or open in Xcode)
open Kopniak/Kopniak.xcodeproj
```

## Architecture

### Core Components

**KopniakApp** (`KopniakApp.swift:12`)
- Main app entry point with three scenes: main window, menu bar extra, and settings
- Uses SwiftUI's `@Observable` environment pattern for state management
- Critical: `ReminderManager` requires `SettingsManager` dependency at initialization (both must be initialized together in `init()` to avoid dependency issues)

**State Management Pattern**
- Two `@Observable` managers: `SettingsManager` and `ReminderManager`
- Injected via `.environment()` to all views
- `ReminderManager` depends on `SettingsManager` and must be initialized with it

**ReminderManager** (`Reminders/ReminderManager.swift:14`)
- Orchestrates reminder scheduling and presentation using Timer-based intervals
- Maintains reminder state persistence via UserDefaults
- Manages anti-repetition logic with recent titles/messages tracking (last 10)
- Controls reminder window lifecycle through `ReminderController`

**ReminderController** (`Reminders/ReminderController.swift:12`)
- NSWindowController wrapper for FloatingWindow
- Bridges AppKit (NSPanel) with SwiftUI (ReminderView via NSHostingView)
- Handles window animations and lifecycle

**FloatingWindow** (`Utils/FloatingWindow.swift:11`)
- Custom NSPanel configured as non-activating, floating above all apps
- Appears on all spaces, doesn't steal focus
- Lives across all desktop spaces (`.canJoinAllSpaces`)

**SettingsManager** (`Settings/SettingsManager.swift:13`)
- Manages user preferences with UserDefaults persistence
- Provides reactive properties for interval timing and launch behavior

### Window Architecture

Three distinct window types:
1. **Main Window**: Optional launch window (suppressible via settings)
2. **Menu Bar Extra**: Always-visible status bar item with dropdown menu
3. **Floating Panel**: Non-activating reminder window (via FloatingWindow)

The floating panel is intentionally non-activating to avoid disrupting user workflow while being visible and interactable.

### Key Patterns

- All managers use `@MainActor` to ensure UI updates happen on main thread
- State persistence pattern: changes to `@Observable` properties automatically sync to UserDefaults via `didSet`
- Dependency injection: managers passed through SwiftUI environment rather than singletons
