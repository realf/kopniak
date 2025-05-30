//
//  AppContext.swift
//  Kopniak
//
//  Created by alf on 30.05.2025.
//

import Foundation

struct AppContext {
    static let appName = "Sergeant Kopniak"
    static func personality() -> AppPersonality {
        personalities[0]
    }
    
    static func notificationTimeInterval() -> TimeInterval {
        45 * 60
    }
    
    static let personalities: [AppPersonality] = [
        AppPersonality(
            name: "🎖️ Sergeant Kopniak",
            title: "Your personal drill sergeant for better breaks.",
            motto: "Discipline! Order! Regular breaks or else, recruit!"
        ),
        AppPersonality(
            name: "💁‍♀️ Sarcastic Coach",
            title: "The coach who’s never impressed by your excuses.",
            motto: "You’re not fooling me — get up and wiggle those legs!"
        ),
        AppPersonality(
            name: "🧘‍♂️ Zen Guru",
            title: "Calm your mind and body with mindful pauses.",
            motto: "Take a mindful break, grasshopper."
        ),
        AppPersonality(
            name: "☕️ Caffeine Addict Buddy",
            title: "Your hyperactive pal who knows breaks matter too.",
            motto: "A quick stretch is as important as your next coffee."
        )
    ]
}

struct AppPersonality {
    let name: String      // Personality name, e.g. "🎖️ Sergeant Kopniak"
    let title: String     // Written in the main window for context, e.g. "Your personal drill sergeant for better breaks."
    let motto: String     // This is so the user better understands the personality. "Discipline! Order! Regular breaks or else, recruit!"
}
