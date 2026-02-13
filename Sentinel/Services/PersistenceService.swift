import Foundation

class PersistenceService {
    private let remindersKey = "sentinel_reminders"
    private let settingsKey = "sentinel_settings"
    let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func saveReminders(_ reminders: [Reminder]) {
        guard let data = try? JSONEncoder().encode(reminders) else { return }
        defaults.set(data, forKey: remindersKey)
    }

    func loadReminders() -> [Reminder]? {
        guard let data = defaults.data(forKey: remindersKey) else { return nil }
        return try? JSONDecoder().decode([Reminder].self, from: data)
    }

    func saveSettings(_ settings: AppSettings) {
        guard let data = try? JSONEncoder().encode(settings) else { return }
        defaults.set(data, forKey: settingsKey)
    }

    func loadSettings() -> AppSettings {
        guard let data = defaults.data(forKey: settingsKey),
              let settings = try? JSONDecoder().decode(AppSettings.self, from: data)
        else { return AppSettings() }
        return settings
    }
}
