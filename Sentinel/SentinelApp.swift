import SwiftUI
import AppKit

final class AppWindowController: NSObject, NSWindowDelegate {
    static let shared = AppWindowController()

    private weak var mainWindow: NSWindow?

    func configure(window: NSWindow) {
        guard mainWindow !== window else { return }
        mainWindow = window
        window.delegate = self
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.styleMask.remove(.resizable)
        window.isMovableByWindowBackground = true

        window.standardWindowButton(.closeButton)?.isHidden = true
        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
        window.standardWindowButton(.zoomButton)?.isHidden = true
    }

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        closeToTray()
        return false
    }

    func closeToTray() {
        NSApp.hide(nil)
    }

    func minimizeMainWindow() {
        mainWindow?.miniaturize(nil)
    }

    func openMainWindow() {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        if let mainWindow {
            mainWindow.deminiaturize(nil)
            mainWindow.makeKeyAndOrderFront(nil)
        }
    }
}

struct WindowAccessor: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            if let window = view.window {
                AppWindowController.shared.configure(window: window)
            }
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async {
            if let window = nsView.window {
                AppWindowController.shared.configure(window: window)
            }
        }
    }
}

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
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified)

        MenuBarExtra(reminderManager.localizationService.ui("sentinel"), systemImage: "shield") {
            Button(reminderManager.localizationService.ui("open")) {
                AppWindowController.shared.openMainWindow()
            }
            Divider()
            Button(reminderManager.localizationService.ui("quit")) {
                NSApp.terminate(nil)
            }
        }
        .menuBarExtraStyle(.menu)
    }
}
