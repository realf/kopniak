//
//  KopniakApp.swift
//  Kopniak
//
//  Created by alf on 29.05.2025.
//

import SwiftUI

@main
struct KopniakApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup(AppContext.appName) {
            ContentView()
        }
    }
}
