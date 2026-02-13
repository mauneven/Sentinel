import SwiftUI
import AppKit

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
        .windowResizability(.automatic)
        .windowStyle(.hiddenTitleBar)

        MenuBarExtra(reminderManager.localizationService.ui("sentinel"), systemImage: "shield") {
            Button(reminderManager.localizationService.ui("open")) {
                NSApp.setActivationPolicy(.regular)
                NSApp.activate(ignoringOtherApps: true)
                if let window = NSApp.windows.first {
                    window.deminiaturize(nil)
                    window.makeKeyAndOrderFront(nil)
                }
            }
            Divider()
            Button(reminderManager.localizationService.ui("quit")) {
                NSApp.terminate(nil)
            }
        }
        .menuBarExtraStyle(.menu)
    }
}
