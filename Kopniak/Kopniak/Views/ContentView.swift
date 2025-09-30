//
//  ContentView.swift
//  Kopniak
//
//  Created by alf on 29.05.2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 10) {
            Text("Briefing")
                .font(.headline)
                .bold()
            Text(
                """
                Listen up, recruit! I’m Sergeant Kopniak, and my mission is to keep your spine straight, your mind sharp, and your butt out of that chair.

                I’ll be sending you regular orders to stand up, stretch, and move. Don’t ignore them — that’s a direct order!

                You ready to join the Posture Platoon and whip that body back into shape?

                Good. Let’s do this!
                """
            )
            .multilineTextAlignment(.leading)
        }
        .padding()
        .frame(minWidth: 400, minHeight: 300)
    }
}

#Preview {
    ContentView()
}
