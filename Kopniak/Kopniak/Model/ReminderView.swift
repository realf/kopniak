import SwiftUI

struct ReminderView: View {
    let title: String
    let message: String
    let onDismiss: () -> Void

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
                Button("Yes, sir!") {
                    onDismiss()
                }
            }
        }
        .padding()
        .frame(width: 360)
    }
}

#Preview {
    ReminderView(
        title: titles.first ?? "Reminder",
        message: messages.first ?? "Time to move!",
        onDismiss: {}
    )
}
