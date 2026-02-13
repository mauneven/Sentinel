import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        let settings = PersistenceService().loadSettings()
        if settings.startMinimized && settings.launchAtLogin {
            DispatchQueue.main.async {
                NSApp.hide(nil)
            }
        }
    }
}

@main
struct SentinelApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var reminderManager = ReminderManager()
    @State private var settingsManager = SettingsManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(reminderManager)
                .environment(settingsManager)
        }
        .windowResizability(.contentSize)
        .windowStyle(.automatic)
        .windowToolbarStyle(.unified)
    }
}
