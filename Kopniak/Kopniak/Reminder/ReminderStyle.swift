import Foundation

enum ReminderStyle: String, CaseIterable, Identifiable, Codable {
    case simple
    case kopniak

    var id: Self { self }

    var displayName: String {
        switch self {
        case .simple:
            return String(localized: "Simple")
        case .kopniak:
            return String(localized: "Kopniak")
        }
    }
}
