import XCTest
@testable import Sentinel

final class LocalizationTests: XCTestCase {

    private let expectedKeys = [
        "relax_eyes", "check_fingers", "relax_arms",
        "stretch_legs", "fix_posture", "have_water", "breathe"
    ]

    private func loadJSON(for language: String) throws -> LocalizationData {
        let bundle = Bundle(for: type(of: self))

        // Try subdirectory first, then flat
        var url = bundle.url(forResource: language, withExtension: "json", subdirectory: "Localization")
        if url == nil {
            url = bundle.url(forResource: language, withExtension: "json")
        }

        // If not found in test bundle, try main bundle
        if url == nil {
            url = Bundle.main.url(forResource: language, withExtension: "json", subdirectory: "Localization")
        }
        if url == nil {
            url = Bundle.main.url(forResource: language, withExtension: "json")
        }

        guard let finalUrl = url else {
            throw NSError(domain: "LocalizationTests", code: 1,
                         userInfo: [NSLocalizedDescriptionKey: "Could not find \(language).json"])
        }

        let data = try Data(contentsOf: finalUrl)
        return try JSONDecoder().decode(LocalizationData.self, from: data)
    }

    func testEnglishHasAllReminderKeys() throws {
        let data = try loadJSON(for: "en")
        for key in expectedKeys {
            XCTAssertNotNil(data.reminders[key], "Missing English key: \(key)")
            XCTAssertFalse(data.reminders[key]!.title.isEmpty, "Empty title for: \(key)")
            XCTAssertFalse(data.reminders[key]!.description.isEmpty, "Empty description for: \(key)")
        }
    }

    func testSpanishHasAllReminderKeys() throws {
        let data = try loadJSON(for: "es")
        for key in expectedKeys {
            XCTAssertNotNil(data.reminders[key], "Missing Spanish key: \(key)")
            XCTAssertFalse(data.reminders[key]!.title.isEmpty, "Empty title for: \(key)")
            XCTAssertFalse(data.reminders[key]!.description.isEmpty, "Empty description for: \(key)")
        }
    }

    func testFrenchHasAllReminderKeys() throws {
        let data = try loadJSON(for: "fr")
        for key in expectedKeys {
            XCTAssertNotNil(data.reminders[key], "Missing French key: \(key)")
            XCTAssertFalse(data.reminders[key]!.title.isEmpty, "Empty title for: \(key)")
            XCTAssertFalse(data.reminders[key]!.description.isEmpty, "Empty description for: \(key)")
        }
    }

    func testAllLanguagesHaveSameKeys() throws {
        let en = try loadJSON(for: "en")
        let es = try loadJSON(for: "es")
        let fr = try loadJSON(for: "fr")

        let enKeys = Set(en.reminders.keys)
        let esKeys = Set(es.reminders.keys)
        let frKeys = Set(fr.reminders.keys)

        XCTAssertEqual(enKeys, esKeys, "English and Spanish have different reminder keys")
        XCTAssertEqual(enKeys, frKeys, "English and French have different reminder keys")

        let enUIKeys = Set(en.ui.keys)
        let esUIKeys = Set(es.ui.keys)
        let frUIKeys = Set(fr.ui.keys)

        XCTAssertEqual(enUIKeys, esUIKeys, "English and Spanish have different UI keys")
        XCTAssertEqual(enUIKeys, frUIKeys, "English and French have different UI keys")
    }

    func testEnglishKnownTranslations() throws {
        let data = try loadJSON(for: "en")
        XCTAssertEqual(data.reminders["relax_eyes"]?.title, "Relax your eyes")
        XCTAssertEqual(data.reminders["have_water"]?.title, "Have some water")
        XCTAssertEqual(data.reminders["fix_posture"]?.title, "Fix your posture")
        XCTAssertEqual(data.reminders["breathe"]?.title, "Breathe for a moment")
    }

    func testSpanishKnownTranslations() throws {
        let data = try loadJSON(for: "es")
        XCTAssertEqual(data.reminders["relax_eyes"]?.title, "Relaja tus ojos")
        XCTAssertEqual(data.reminders["have_water"]?.title, "Toma un poco de agua")
        XCTAssertEqual(data.reminders["fix_posture"]?.title, "Corrige tu postura")
        XCTAssertEqual(data.reminders["breathe"]?.title, "Respira unos segundos")
    }

    func testFrenchKnownTranslations() throws {
        let data = try loadJSON(for: "fr")
        XCTAssertEqual(data.reminders["relax_eyes"]?.title, "Repose tes yeux")
        XCTAssertEqual(data.reminders["have_water"]?.title, "Bois un peu d'eau")
        XCTAssertEqual(data.reminders["fix_posture"]?.title, "Corrige ta posture")
        XCTAssertEqual(data.reminders["breathe"]?.title, "Respire quelques secondes")
    }

    func testUIStringsExist() throws {
        let requiredUIKeys = ["settings", "add_reminder", "delete", "close", "update",
                              "language", "launch_at_login", "start_minimized", "minutes",
                              "new_reminder", "done", "interval"]

        for lang in ["en", "es", "fr"] {
            let data = try loadJSON(for: lang)
            for key in requiredUIKeys {
                XCTAssertNotNil(data.ui[key], "Missing UI key '\(key)' in \(lang)")
                XCTAssertFalse(data.ui[key]!.isEmpty, "Empty UI value for '\(key)' in \(lang)")
            }
        }
    }

    func testLocalizationDataCodable() throws {
        let data = try loadJSON(for: "en")
        let encoded = try JSONEncoder().encode(data)
        let decoded = try JSONDecoder().decode(LocalizationData.self, from: encoded)

        XCTAssertEqual(data.reminders.count, decoded.reminders.count)
        XCTAssertEqual(data.ui.count, decoded.ui.count)
    }
}
