import XCTest
@testable import Sentinel

final class ReminderTests: XCTestCase {

    func testReminderCreationWithDefaults() {
        let reminder = Reminder(title: "Test", description: "Desc")
        XCTAssertFalse(reminder.isEnabled)
        XCTAssertEqual(reminder.type, .custom)
        XCTAssertFalse(reminder.isModified)
        XCTAssertNil(reminder.localizationKey)
        XCTAssertEqual(reminder.intervalMinutes, 30)
        XCTAssertEqual(reminder.title, "Test")
        XCTAssertEqual(reminder.description, "Desc")
    }

    func testReminderIntervalClampingLow() {
        let reminder = Reminder(title: "Test", description: "", intervalMinutes: 0)
        XCTAssertEqual(reminder.intervalMinutes, 1)
    }

    func testReminderIntervalClampingNegative() {
        let reminder = Reminder(title: "Test", description: "", intervalMinutes: -5)
        XCTAssertEqual(reminder.intervalMinutes, 1)
    }

    func testReminderIntervalClampingHigh() {
        let reminder = Reminder(title: "Test", description: "", intervalMinutes: 150)
        XCTAssertEqual(reminder.intervalMinutes, 120)
    }

    func testReminderIntervalWithinRange() {
        let reminder = Reminder(title: "Test", description: "", intervalMinutes: 60)
        XCTAssertEqual(reminder.intervalMinutes, 60)
    }

    func testReminderCodableRoundTrip() throws {
        let original = Reminder(
            title: "Relax your eyes",
            description: "Look away from screen",
            intervalMinutes: 20,
            isEnabled: true,
            type: .default,
            isModified: false,
            localizationKey: "relax_eyes"
        )

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Reminder.self, from: data)

        XCTAssertEqual(original, decoded)
    }

    func testReminderEquality() {
        let id = UUID()
        let a = Reminder(id: id, title: "A", description: "B", intervalMinutes: 10)
        let b = Reminder(id: id, title: "A", description: "B", intervalMinutes: 10)
        XCTAssertEqual(a, b)
    }

    func testReminderInequality() {
        let a = Reminder(title: "A", description: "B")
        let b = Reminder(title: "C", description: "D")
        XCTAssertNotEqual(a, b)
    }

    func testReminderTypeDefault() {
        let reminder = Reminder(
            title: "Test", description: "", type: .default, localizationKey: "test_key"
        )
        XCTAssertEqual(reminder.type, .default)
        XCTAssertEqual(reminder.localizationKey, "test_key")
    }

    func testReminderTypeCustom() {
        let reminder = Reminder(title: "Custom", description: "")
        XCTAssertEqual(reminder.type, .custom)
    }

    func testReminderTypeEnumCodable() throws {
        let types: [ReminderType] = [.default, .custom]
        for type in types {
            let data = try JSONEncoder().encode(type)
            let decoded = try JSONDecoder().decode(ReminderType.self, from: data)
            XCTAssertEqual(type, decoded)
        }
    }
}
