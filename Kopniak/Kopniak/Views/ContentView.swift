//
//  ContentView.swift
//  Kopniak
//
//  Created by alf on 29.05.2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            AppPersonalityView(personality: AppContext.personality())
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
