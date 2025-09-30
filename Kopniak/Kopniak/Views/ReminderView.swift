import SwiftUI

struct ReminderView: View {
    let title: String
    let message: String
    let onDismiss: () -> Void
    let onSnooze: (() -> Void)

    var body: some View {
        VStack(spacing: 12) {
            Text(title)
                .font(.title2)
                .bold()
            Text(message)
                .multilineTextAlignment(.center)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
            HStack {
                Spacer()
                Button("At Ease for 10!") {
                    onSnooze()
                }
                .buttonStyle(.bordered)
                Button("Yes, sir!") {
                    onDismiss()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .frame(minWidth: 380, minHeight: 100)
        .fixedSize()
    }
}

#Preview {
    ReminderView(
        title: titles.first ?? "Reminder",
        message: messages.first ?? "Time to move!",
        onDismiss: {},
        onSnooze: {}
    )
}
