import Foundation

enum ReminderType: String, Codable, Equatable {
    case `default`
    case custom
}

struct Reminder: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var description: String
    var intervalMinutes: Int
    var isEnabled: Bool
    var type: ReminderType
    var isModified: Bool
    var localizationKey: String?

    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        intervalMinutes: Int = 30,
        isEnabled: Bool = false,
        type: ReminderType = .custom,
        isModified: Bool = false,
        localizationKey: String? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.intervalMinutes = max(1, min(120, intervalMinutes))
        self.isEnabled = isEnabled
        self.type = type
        self.isModified = isModified
        self.localizationKey = localizationKey
    }
}
