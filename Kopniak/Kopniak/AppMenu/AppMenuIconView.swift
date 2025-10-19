//
//  AppMenuIconView.swift
//  Sergeant Kopniak
//
//  Created by alf on 19.10.2025.
//

import ComposableArchitecture
import SwiftUI

struct AppMenuIconView: View {
    let store: StoreOf<AppFeature>

    private var menuBarIcon: String {
        if store.remindersStatus != .off {
            return "chevron.up.2"
        } else {
            return "chevron.up.dotted.2"
        }
    }

    var body: some View {
        Image(systemName: menuBarIcon)
            .onAppear {
                store.send(.onAppear)
            }
    }
}

#Preview {
    AppMenuIconView(
        store: Store(
            initialState: AppFeature.State(),
            reducer: {
                AppFeature()._printChanges()
            }
        )
    )
    .frame(width: 400, height: 300)
}
