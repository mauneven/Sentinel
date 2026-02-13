import XCTest
@testable import Sentinel

final class ReminderManagerTests: XCTestCase {

    private var manager: ReminderManager!
    private var testDefaults: UserDefaults!
    private let suiteName = "com.sentinel.tests.manager"

    override func setUp() {
        super.setUp()
        testDefaults = UserDefaults(suiteName: suiteName)!
        testDefaults.removePersistentDomain(forName: suiteName)
        let persistence = PersistenceService(defaults: testDefaults)
        manager = ReminderManager(persistenceService: persistence)
    }

    override func tearDown() {
        testDefaults.removePersistentDomain(forName: suiteName)
        testDefaults = nil
        manager = nil
        super.tearDown()
    }

    func testInitialStateHasDefaultReminders() {
        XCTAssertEqual(manager.reminders.count, 7)
        for reminder in manager.reminders {
            XCTAssertEqual(reminder.type, .default)
            XCTAssertFalse(reminder.isModified)
            XCTAssertNotNil(reminder.localizationKey)
            XCTAssertFalse(reminder.isEnabled)
        }
    }

    func testDefaultReminderKeys() {
        let keys = manager.reminders.compactMap { $0.localizationKey }
        let expectedKeys = ["relax_eyes", "check_fingers", "relax_arms",
                           "stretch_legs", "fix_posture", "have_water", "breathe"]
        XCTAssertEqual(Set(keys), Set(expectedKeys))
    }

    func testDefaultReminderIntervals() {
        let expected: [String: Int] = [
            "relax_eyes": 20,
            "check_fingers": 30,
            "relax_arms": 25,
            "stretch_legs": 45,
            "fix_posture": 15,
            "have_water": 30,
            "breathe": 20
        ]

        for reminder in manager.reminders {
            if let key = reminder.localizationKey {
                XCTAssertEqual(reminder.intervalMinutes, expected[key],
                              "Interval mismatch for \(key)")
            }
        }
    }

    func testAddCustomReminder() {
        let initialCount = manager.reminders.count
        manager.addReminder()
        XCTAssertEqual(manager.reminders.count, initialCount + 1)

        let added = manager.reminders.last!
        XCTAssertEqual(added.type, .custom)
        XCTAssertFalse(added.isEnabled)
        XCTAssertEqual(added.intervalMinutes, 30)
    }

    func testDeleteReminder() {
        let initialCount = manager.reminders.count
        let toDelete = manager.reminders[0]
        manager.deleteReminder(toDelete)
        XCTAssertEqual(manager.reminders.count, initialCount - 1)
        XCTAssertFalse(manager.reminders.contains(where: { $0.id == toDelete.id }))
    }

    func testToggleReminderEnables() {
        let reminder = manager.reminders[0]
        XCTAssertFalse(reminder.isEnabled)

        manager.toggleReminder(reminder.id)
        XCTAssertTrue(manager.reminders[0].isEnabled)
    }

    func testToggleReminderDisables() {
        let reminder = manager.reminders[0]
        manager.toggleReminder(reminder.id)
        XCTAssertTrue(manager.reminders[0].isEnabled)

        manager.toggleReminder(reminder.id)
        XCTAssertFalse(manager.reminders[0].isEnabled)
    }

    func testToggleCreatesTimer() {
        let reminder = manager.reminders[0]
        manager.isMasterEnabled = true
        manager.toggleReminder(reminder.id)

        XCTAssertTrue(manager.hasTimer(for: reminder.id))
    }

    func testToggleOffRemovesTimer() {
        let reminder = manager.reminders[0]
        manager.isMasterEnabled = true
        manager.toggleReminder(reminder.id)
        XCTAssertTrue(manager.hasTimer(for: reminder.id))

        manager.toggleReminder(reminder.id)
        XCTAssertFalse(manager.hasTimer(for: reminder.id))
    }

    func testMasterToggleOffStopsAllTimers() {
        manager.isMasterEnabled = true
        manager.toggleReminder(manager.reminders[0].id)
        manager.toggleReminder(manager.reminders[1].id)
        XCTAssertEqual(manager.activeTimerCount, 2)

        manager.isMasterEnabled = false
        XCTAssertEqual(manager.activeTimerCount, 0)
    }

    func testMasterToggleOnStartsEnabledTimers() {
        manager.toggleReminder(manager.reminders[0].id)
        manager.toggleReminder(manager.reminders[1].id)
        manager.isMasterEnabled = false
        XCTAssertEqual(manager.activeTimerCount, 0)

        manager.isMasterEnabled = true
        XCTAssertEqual(manager.activeTimerCount, 2)
    }

    func testUpdateReminderTitle() {
        var reminder = manager.reminders[0]
        let originalTitle = reminder.title
        reminder.title = "New Title"
        manager.updateReminder(reminder)

        XCTAssertEqual(manager.reminders[0].title, "New Title")
        XCTAssertNotEqual(manager.reminders[0].title, originalTitle)
    }

    func testUpdateDefaultReminderMarksModified() {
        var reminder = manager.reminders[0]
        XCTAssertEqual(reminder.type, .default)
        XCTAssertFalse(reminder.isModified)

        reminder.title = "Modified Title"
        manager.updateReminder(reminder)

        XCTAssertTrue(manager.reminders[0].isModified)
    }

    func testUpdateDescriptionMarksModified() {
        var reminder = manager.reminders[0]
        reminder.description = "New description"
        manager.updateReminder(reminder)

        XCTAssertTrue(manager.reminders[0].isModified)
    }

    func testUpdateIntervalDoesNotMarkModified() {
        var reminder = manager.reminders[0]
        reminder.intervalMinutes = 99
        manager.updateReminder(reminder)

        XCTAssertFalse(manager.reminders[0].isModified)
    }

    func testIntervalChangeRestartsTimer() {
        manager.isMasterEnabled = true
        let reminder = manager.reminders[0]
        manager.toggleReminder(reminder.id)
        XCTAssertTrue(manager.hasTimer(for: reminder.id))

        var updated = manager.reminders[0]
        updated.intervalMinutes = 60
        manager.updateReminder(updated)

        XCTAssertTrue(manager.hasTimer(for: reminder.id))
        XCTAssertEqual(manager.reminders[0].intervalMinutes, 60)
    }

    func testDeleteRemovesTimer() {
        manager.isMasterEnabled = true
        let reminder = manager.reminders[0]
        manager.toggleReminder(reminder.id)
        XCTAssertTrue(manager.hasTimer(for: reminder.id))

        manager.deleteReminder(manager.reminders[0])
        XCTAssertFalse(manager.hasTimer(for: reminder.id))
    }

    func testPersistenceAcrossInstances() {
        manager.addReminder()
        let count = manager.reminders.count

        let persistence2 = PersistenceService(defaults: testDefaults)
        let manager2 = ReminderManager(persistenceService: persistence2)
        XCTAssertEqual(manager2.reminders.count, count)
    }

    func testToggleWithMasterOffDoesNotCreateTimer() {
        manager.isMasterEnabled = false
        let reminder = manager.reminders[0]
        manager.toggleReminder(reminder.id)

        XCTAssertTrue(manager.reminders[0].isEnabled)
        XCTAssertFalse(manager.hasTimer(for: reminder.id))
    }
}
