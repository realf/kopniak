//
//  LaunchAtLoginView.swift
//  Sergeant Kopniak
//
//  Created by alf on 03.10.2025.
//

import ComposableArchitecture
import SwiftUI

struct LaunchAtLoginView: View {
    var store: StoreOf<LaunchAtLoginFeature>

    var body: some View {
        VStack(spacing: 20) {
            // Message
            Text(
                """
                Want to open Kopniak at login?
                """
            )
            .font(.largeTitle)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)

            // Buttons
            HStack(spacing: 12) {
                Spacer()

                Button {
                    store.send(.noTapped)
                } label: {
                    Text("Not now")
                        .frame(width: 200, height: 32)
                }

                Button {
                    store.send(.yesTapped)
                } label: {
                    Text("Yes")
                        .frame(width: 200, height: 32)
                }
                .keyboardShortcut(.defaultAction)
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(30)
        .frame(width: 520)
    }
}

#Preview {
    LaunchAtLoginView(
        store: Store(
            initialState: LaunchAtLoginFeature.State(),
            reducer: {
                LaunchAtLoginFeature()
            }
        )
    )
}
