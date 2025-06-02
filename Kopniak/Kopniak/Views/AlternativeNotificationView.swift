//
//  AlternativeNotificationView.swift
//  Sergeant Kopniak
//
//  Created by alf on 02.06.2025.
//

import SwiftUI

struct AlternativeNotificationView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.8))
            Text("🧘‍♂️ Time to stretch!")
                .font(.title)
                .foregroundColor(.white)
                .padding()
        }
        .frame(width: 300, height: 100)
    }
}

#Preview {
    AlternativeNotificationView()
}
