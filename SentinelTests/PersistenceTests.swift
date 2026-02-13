import XCTest
@testable import Sentinel

final class PersistenceTests: XCTestCase {

    private var service: PersistenceService!
    private var testDefaults: UserDefaults!
    private let suiteName = "com.sentinel.tests.persistence"

    override func setUp() {
        super.setUp()
        testDefaults = UserDefaults(suiteName: suiteName)!
        testDefaults.removePersistentDomain(forName: suiteName)
        service = PersistenceService(defaults: testDefaults)
    }

    override func tearDown() {
        testDefaults.removePersistentDomain(forName: suiteName)
        testDefaults = nil
        service = nil
        super.tearDown()
    }

    func testSaveAndLoadReminders() throws {
        let reminders = [
            Reminder(title: "Test 1", description: "Desc 1", intervalMinutes: 10),
            Reminder(title: "Test 2", description: "Desc 2", intervalMinutes: 20, isEnabled: true),
        ]

        service.saveReminders(reminders)
        let loaded = service.loadReminders()

        XCTAssertNotNil(loaded)
        XCTAssertEqual(loaded?.count, 2)
        XCTAssertEqual(loaded?[0].title, "Test 1")
        XCTAssertEqual(loaded?[1].title, "Test 2")
        XCTAssertEqual(loaded?[0].intervalMinutes, 10)
        XCTAssertEqual(loaded?[1].isEnabled, true)
    }

    func testLoadRemindersReturnsNilWhenEmpty() {
        let loaded = service.loadReminders()
        XCTAssertNil(loaded)
    }

    func testSaveAndLoadSettings() {
        var settings = AppSettings()
        settings.language = .spanish
        settings.launchAtLogin = false
        settings.startMinimized = false
        settings.isMasterEnabled = false

        service.saveSettings(settings)
        let loaded = service.loadSettings()

        XCTAssertEqual(loaded.language, .spanish)
        XCTAssertFalse(loaded.launchAtLogin)
        XCTAssertFalse(loaded.startMinimized)
        XCTAssertFalse(loaded.isMasterEnabled)
    }

    func testLoadSettingsReturnsDefaultsWhenEmpty() {
        let loaded = service.loadSettings()
        let expected = AppSettings()

        XCTAssertEqual(loaded, expected)
        XCTAssertEqual(loaded.language, .english)
        XCTAssertTrue(loaded.launchAtLogin)
        XCTAssertTrue(loaded.startMinimized)
        XCTAssertTrue(loaded.isMasterEnabled)
    }

    func testOverwriteReminders() {
        let first = [Reminder(title: "First", description: "")]
        service.saveReminders(first)

        let second = [Reminder(title: "Second", description: "")]
        service.saveReminders(second)

        let loaded = service.loadReminders()
        XCTAssertEqual(loaded?.count, 1)
        XCTAssertEqual(loaded?[0].title, "Second")
    }

    func testSettingsCodableRoundTrip() throws {
        let settings = AppSettings(
            language: .french,
            launchAtLogin: false,
            startMinimized: true,
            isMasterEnabled: false
        )

        let data = try JSONEncoder().encode(settings)
        let decoded = try JSONDecoder().decode(AppSettings.self, from: data)

        XCTAssertEqual(settings, decoded)
    }
}
