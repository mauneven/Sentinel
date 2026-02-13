import SwiftUI
import AppKit

struct MacOSBlurBackground: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = .sidebar
        view.blendingMode = .behindWindow
        view.state = .active
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}

struct ContentView: View {
    @Environment(ReminderManager.self) private var reminderManager
    @Environment(SettingsManager.self) private var settingsManager
    @State private var editingReminder: Reminder?
    @State private var creatingReminder: Reminder?
    @State private var showSettings = false

    var body: some View {
        ZStack {
            MacOSBlurBackground()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                MasterToggleView(showSettings: $showSettings)
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 10)

                Divider()

                ScrollView {
                    LazyVStack(spacing: 2) {
                        ForEach(reminderManager.reminders) { reminder in
                            ReminderRowView(
                                reminder: reminder,
                                onEdit: { editingReminder = reminder },
                                onToggle: { reminderManager.toggleReminder(reminder.id) },
                                onIntervalChange: { newInterval in
                                    var updated = reminder
                                    updated.intervalMinutes = newInterval
                                    reminderManager.updateReminder(updated)
                                },
                                isMasterEnabled: reminderManager.isMasterEnabled
                            )
                        }
                    }
                    .padding(.vertical, 4)
                }

                Divider()

                Button(action: {
                    let newReminder = reminderManager.addReminder()
                    creatingReminder = newReminder
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "plus.circle.fill")
                            .font(.body)
                        Text(reminderManager.localizationService.ui("add_reminder"))
                            .font(.body)
                    }
                }
                .buttonStyle(.plain)
                .padding(.vertical, 12)
            }
        }
        .frame(width: 500, height: 560)
        .background(WindowAccessor())
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .environment(reminderManager)
                .environment(settingsManager)
        }
        .sheet(item: $editingReminder) { reminder in
            EditReminderView(reminder: reminder, isCreating: false)
                .environment(reminderManager)
        }
        .sheet(item: $creatingReminder, onDismiss: {
            if let r = creatingReminder,
               let existing = reminderManager.reminders.first(where: { $0.id == r.id }),
               existing.title == reminderManager.localizationService.ui("new_reminder"),
               existing.description.isEmpty {
                reminderManager.deleteReminder(existing)
            }
        }) { reminder in
            EditReminderView(reminder: reminder, isCreating: true)
                .environment(reminderManager)
        }
    }
}
