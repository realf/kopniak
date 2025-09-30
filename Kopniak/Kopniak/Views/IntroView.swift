//
//  IntroView.swift
//  Kopniak
//
//  Created by alf on 29.05.2025.
//

import SwiftUI

struct IntroView: View {
    var body: some View {
        VStack(spacing: 10) {
            Text("Briefing")
                .font(.headline)
                .bold()
            Text(
                """
                ATTENTION, RECRUIT!

                Look for my sergeant's chevron in your status bar — those twin stripes mean I'm watching. Click it to access your orders.

                MISSION BRIEFING:
                • I'll bark orders every 45 minutes — time for a movement break!
                • When I call, you drop and give me... a stretch!
                • Hit "Yes, sir!" when you've completed your mission
                • Need more time? "At Ease for 10!" buys you 10 minutes
                • Use "Stand Down" to pause me (but don't get too comfortable)
                • "Report for Duty" when you're ready to soldier on

                My job? Keep your spine straight and your circulation flowing. Your chair is NOT a permanent duty station!

                You ready to join the Anti-Slouch Squadron and whip that body back into shape?

                MOVE OUT!
                """
            )
            .multilineTextAlignment(.leading)
        }
        .padding()
    }
}

#Preview {
    IntroView()
}
