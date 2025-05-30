//
//  AppPersonalityView.swift
//  Sergeant Kopniak
//
//  Created by alf on 30.05.2025.
//

import SwiftUI

struct AppPersonalityView: View {
    let personality: AppPersonality

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(personality.name)
                .font(.largeTitle)
                .bold()

            Text(personality.title)
                .font(.headline)
                .foregroundColor(.secondary)

            Text("“\(personality.motto)”")
                .font(.body)
                .italic()
                .padding(.top, 8)
        }
        .padding()
    }
}

#Preview {
    AppPersonalityView(personality: AppContext.personality())
}
