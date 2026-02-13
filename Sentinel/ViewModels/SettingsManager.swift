import Foundation
import ServiceManagement

@Observable
class SettingsManager {
    var settings: AppSettings {
        didSet { save() }
    }

    private let persistenceService: PersistenceService

    init(persistenceService: PersistenceService = PersistenceService()) {
        self.persistenceService = persistenceService
        self.settings = persistenceService.loadSettings()
        syncLaunchAtLogin()
    }

    var launchAtLogin: Bool {
        get { settings.launchAtLogin }
        set {
            settings.launchAtLogin = newValue
            updateLaunchAtLogin(newValue)
            if !newValue {
                settings.startMinimized = false
            }
        }
    }

    var startMinimized: Bool {
        get { settings.startMinimized }
        set { settings.startMinimized = newValue }
    }

    var language: AppLanguage {
        get { settings.language }
        set { settings.language = newValue }
    }

    private func save() {
        persistenceService.saveSettings(settings)
    }

    private func updateLaunchAtLogin(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            print("Launch at login error: \(error)")
        }
    }

    private func syncLaunchAtLogin() {
        let status = SMAppService.mainApp.status
        if status == .enabled && !settings.launchAtLogin {
            settings.launchAtLogin = true
        } else if status == .notRegistered && settings.launchAtLogin {
            updateLaunchAtLogin(true)
        }
    }
}
