import Foundation

struct UpcomingReminderInfo: Identifiable {
    let id: UUID
    let title: String
    let minutesLeft: Int
}

@Observable
class ReminderManager {
    var reminders: [Reminder] = []
    var isMasterEnabled: Bool = true {
        didSet {
            if isMasterEnabled {
                startAllEnabledTimers()
            } else {
                stopAllTimers()
            }
            saveSettings()
        }
    }

    private var timers: [UUID: Timer] = [:]
    private var nextFireDates: [UUID: Date] = [:]
    private let notificationService = NotificationService()
    let persistenceService: PersistenceService
    let localizationService: LocalizationService

    #if DEBUG
    var activeTimerCount: Int { timers.count }
    func hasTimer(for id: UUID) -> Bool { timers[id] != nil }
    #endif

    var upcomingReminders: [UpcomingReminderInfo] {
        guard isMasterEnabled else { return [] }

        let now = Date()
        let enabledWithDates: [(reminder: Reminder, date: Date)] = reminders
            .filter { $0.isEnabled }
            .compactMap { reminder in
                guard let date = nextFireDates[reminder.id] else { return nil }
                return (reminder, date)
            }
            .sorted { $0.date < $1.date }

        guard let first = enabledWithDates.first else { return [] }
        let threshold = first.date.addingTimeInterval(180)

        return enabledWithDates
            .filter { $0.date <= threshold }
            .prefix(6)
            .map { item in
                let minutes = max(1, Int(ceil(item.date.timeIntervalSince(now) / 60)))
                return UpcomingReminderInfo(
                    id: item.reminder.id,
                    title: item.reminder.title,
                    minutesLeft: minutes
                )
            }
    }

    init(persistenceService: PersistenceService = PersistenceService(),
         localizationService: LocalizationService? = nil) {
        self.persistenceService = persistenceService
        let settings = persistenceService.loadSettings()
        self.localizationService = localizationService ?? LocalizationService(language: settings.language)
        self.isMasterEnabled = settings.isMasterEnabled
        loadState()
    }

    // MARK: - CRUD

    @discardableResult
    func addReminder() -> Reminder {
        let reminder = Reminder(
            title: localizationService.ui("new_reminder"),
            description: "",
            intervalMinutes: 30,
            isEnabled: false,
            type: .custom
        )
        reminders.insert(reminder, at: 0)
        save()
        return reminder
    }

    func deleteReminder(_ reminder: Reminder) {
        stopTimer(for: reminder.id)
        reminders.removeAll { $0.id == reminder.id }
        save()
    }

    func updateReminder(_ updated: Reminder) {
        guard let index = reminders.firstIndex(where: { $0.id == updated.id }) else { return }
        let old = reminders[index]
        var newReminder = updated
        newReminder.intervalMinutes = min(max(newReminder.intervalMinutes, 1), 60)

        if updated.type == .default &&
            (old.title != updated.title || old.description != updated.description) {
            newReminder.isModified = true
        }

        reminders[index] = newReminder

        if old.intervalMinutes != newReminder.intervalMinutes && newReminder.isEnabled && isMasterEnabled {
            restartTimer(for: newReminder)
        }

        save()
    }

    // MARK: - Toggle

    func toggleReminder(_ id: UUID) {
        guard let index = reminders.firstIndex(where: { $0.id == id }) else { return }
        reminders[index].isEnabled.toggle()

        if reminders[index].isEnabled && isMasterEnabled {
            startTimer(for: reminders[index])
        } else {
            stopTimer(for: id)
        }
        save()
    }

    // MARK: - Language

    func changeLanguage(to language: AppLanguage) {
        localizationService.loadLanguage(language)

        for i in reminders.indices {
            if reminders[i].type == .default && !reminders[i].isModified,
               let key = reminders[i].localizationKey,
               let localized = localizationService.localizedReminder(for: key) {
                reminders[i].title = localized.title
                reminders[i].description = localized.description
            }
        }
        save()
    }

    // MARK: - Notification Permission

    func requestNotificationPermission() async -> Bool {
        return await notificationService.requestPermission()
    }

    // MARK: - Timer Management

    private func startTimer(for reminder: Reminder) {
        stopTimer(for: reminder.id)

        let interval = TimeInterval(reminder.intervalMinutes * 60)
        nextFireDates[reminder.id] = Date().addingTimeInterval(interval)
        let reminderId = reminder.id
        let timer = Timer.scheduledTimer(
            withTimeInterval: interval,
            repeats: true
        ) { [weak self] _ in
            self?.timerFired(for: reminderId)
        }
        timers[reminder.id] = timer
    }

    private func stopTimer(for id: UUID) {
        timers[id]?.invalidate()
        timers[id] = nil
        nextFireDates[id] = nil
    }

    private func restartTimer(for reminder: Reminder) {
        startTimer(for: reminder)
    }

    private func startAllEnabledTimers() {
        for reminder in reminders where reminder.isEnabled {
            startTimer(for: reminder)
        }
    }

    private func stopAllTimers() {
        for (_, timer) in timers {
            timer.invalidate()
        }
        timers.removeAll()
        nextFireDates.removeAll()
    }

    private func timerFired(for id: UUID) {
        guard let reminder = reminders.first(where: { $0.id == id }) else { return }
        let notificationId = "\(id.uuidString)-\(Date().timeIntervalSince1970)"
        notificationService.sendNotification(
            title: reminder.title,
            body: reminder.description,
            identifier: notificationId
        )

        let interval = TimeInterval(reminder.intervalMinutes * 60)
        nextFireDates[id] = Date().addingTimeInterval(interval)
    }

    // MARK: - Persistence

    private func loadState() {
        if let saved = persistenceService.loadReminders() {
            reminders = saved.map { reminder in
                var normalized = reminder
                normalized.intervalMinutes = min(max(normalized.intervalMinutes, 1), 60)
                return normalized
            }
        } else {
            createDefaultReminders()
        }

        Task {
            await notificationService.requestPermission()
        }

        if isMasterEnabled {
            startAllEnabledTimers()
        }
    }

    private func createDefaultReminders() {
        let defaults: [(key: String, interval: Int)] = [
            ("relax_eyes", 20),
            ("check_fingers", 30),
            ("relax_arms", 25),
            ("stretch_legs", 45),
            ("fix_posture", 15),
            ("have_water", 30),
            ("breathe", 20)
        ]

        reminders = defaults.map { item in
            let localized = localizationService.localizedReminder(for: item.key)
            return Reminder(
                title: localized?.title ?? item.key,
                description: localized?.description ?? "",
                intervalMinutes: item.interval,
                isEnabled: false,
                type: .default,
                isModified: false,
                localizationKey: item.key
            )
        }
        save()
    }

    private func save() {
        persistenceService.saveReminders(reminders)
    }

    private func saveSettings() {
        var settings = persistenceService.loadSettings()
        settings.isMasterEnabled = isMasterEnabled
        persistenceService.saveSettings(settings)
    }
}
