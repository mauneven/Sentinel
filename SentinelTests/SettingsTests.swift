import XCTest
@testable import Sentinel

final class SettingsTests: XCTestCase {

    func testDefaultSettings() {
        let settings = AppSettings()
        XCTAssertEqual(settings.language, .english)
        XCTAssertTrue(settings.launchAtLogin)
        XCTAssertTrue(settings.startMinimized)
        XCTAssertTrue(settings.isMasterEnabled)
    }

    func testSettingsCodableRoundTrip() throws {
        let original = AppSettings(
            language: .french,
            launchAtLogin: false,
            startMinimized: false,
            isMasterEnabled: false
        )
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(AppSettings.self, from: data)
        XCTAssertEqual(original, decoded)
    }

    func testSettingsEquality() {
        let a = AppSettings()
        let b = AppSettings()
        XCTAssertEqual(a, b)
    }

    func testSettingsInequality() {
        var a = AppSettings()
        var b = AppSettings()
        b.language = .spanish
        XCTAssertNotEqual(a, b)

        a = AppSettings()
        b = AppSettings()
        b.isMasterEnabled = false
        XCTAssertNotEqual(a, b)
    }

    func testAppLanguageRawValues() {
        XCTAssertEqual(AppLanguage.english.rawValue, "en")
        XCTAssertEqual(AppLanguage.spanish.rawValue, "es")
        XCTAssertEqual(AppLanguage.french.rawValue, "fr")
    }

    func testAppLanguageDisplayNames() {
        XCTAssertEqual(AppLanguage.english.displayName, "English")
        XCTAssertEqual(AppLanguage.spanish.displayName, "Español")
        XCTAssertEqual(AppLanguage.french.displayName, "Français")
    }

    func testAppLanguageCaseIterable() {
        let allCases = AppLanguage.allCases
        XCTAssertEqual(allCases.count, 3)
        XCTAssertTrue(allCases.contains(.english))
        XCTAssertTrue(allCases.contains(.spanish))
        XCTAssertTrue(allCases.contains(.french))
    }

    func testAppLanguageCodableRoundTrip() throws {
        for lang in AppLanguage.allCases {
            let data = try JSONEncoder().encode(lang)
            let decoded = try JSONDecoder().decode(AppLanguage.self, from: data)
            XCTAssertEqual(lang, decoded)
        }
    }
}
