import Foundation

enum ReminderStyle: String, CaseIterable, Identifiable, Codable {
    case simple
    case kopniak

    var id: Self { self }

    var displayName: String {
        switch self {
        case .simple:
            return "Simple"
        case .kopniak:
            return "Kopniak"
        }
    }
}
