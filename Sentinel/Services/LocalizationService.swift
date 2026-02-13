import Foundation

struct LocalizedReminder: Codable {
    let title: String
    let description: String
}

struct LocalizationData: Codable {
    let reminders: [String: LocalizedReminder]
    let ui: [String: String]
}

@Observable
class LocalizationService {
    private(set) var currentLanguage: AppLanguage = .english
    private(set) var data: LocalizationData?

    init(language: AppLanguage = .english) {
        self.currentLanguage = language
        loadLanguage(language)
    }

    func loadLanguage(_ language: AppLanguage) {
        currentLanguage = language

        guard let url = Bundle.main.url(
            forResource: language.rawValue,
            withExtension: "json",
            subdirectory: "Localization"
        ) else {
            // Fallback: try without subdirectory
            guard let flatUrl = Bundle.main.url(
                forResource: language.rawValue,
                withExtension: "json"
            ) else { return }
            loadFromURL(flatUrl)
            return
        }
        loadFromURL(url)
    }

    private func loadFromURL(_ url: URL) {
        guard let jsonData = try? Data(contentsOf: url) else { return }
        data = try? JSONDecoder().decode(LocalizationData.self, from: jsonData)
    }

    func localizedReminder(for key: String) -> LocalizedReminder? {
        return data?.reminders[key]
    }

    func ui(_ key: String) -> String {
        return data?.ui[key] ?? key
    }
}
