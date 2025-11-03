//
//  AppMenuIconView.swift
//  Sergeant Kopniak
//
//  Created by alf on 19.10.2025.
//

import ComposableArchitecture
import SwiftUI

struct AppMenuIconView: View {
    let store: StoreOf<AppMenuIconFeature>
    let reminderController: ReminderController

    init(
        store: StoreOf<AppMenuIconFeature>,
        reminderController: ReminderController
    ) {
        self.store = store
        self.reminderController = reminderController
    }

    private var menuBarIcon: String {
        if store.remindersStatus == .on {
            return "chevron.up.2"
        } else {
            return "chevron.up.dotted.2"
        }
    }

    private func formatted(remainingTime: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: remainingTime) ?? "00:00"
    }

    var body: some View {
        HStack {
            Image(systemName: menuBarIcon)
            if store.remindersStatus != .off {
                Text(formatted(remainingTime: store.remainingTime))
                    .font(.system(.body, design: .monospaced))
            }
        }
//        .onAppear {
//            store.send(.delegate(.onAppear))
//        }
    }
}

#Preview {
    let status = Shared<RemindersStatus>(value: .on)
    AppMenuIconView(
        store: Store(
            initialState: AppMenuIconFeature.State(
                remindersStatus: status,
                remainingTime: Shared(value: 90.0)
            )
        ) {
            AppMenuIconFeature()
        },
        reminderController: ReminderController(
            store:
                Store(
                    initialState: ReminderFeature.State(
                        title: "Title",
                        message: "Message"
                    ),
                    reducer: {
                        ReminderFeature()
                    }
                )
        )
    )
    .frame(width: 400, height: 300)
}
