//
//  main.swift
//  Kopniak
//
//  Created by alf on 30.09.2025.
//

import Cocoa

// Create and configure the application
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate

// Run the application
_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)