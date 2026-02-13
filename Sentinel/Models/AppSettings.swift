import Foundation

enum AppLanguage: String, Codable, CaseIterable, Equatable {
    case english = "en"
    case spanish = "es"
    case french = "fr"

    var displayName: String {
        switch self {
        case .english: return "English"
        case .spanish: return "Español"
        case .french: return "Français"
        }
    }
}

struct AppSettings: Codable, Equatable {
    var language: AppLanguage = .english
    var launchAtLogin: Bool = true
    var startMinimized: Bool = true
    var isMasterEnabled: Bool = true
}
