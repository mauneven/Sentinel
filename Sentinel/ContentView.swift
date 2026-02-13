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
    @State private var showInfo = false

    var body: some View {
        ZStack {
            MacOSBlurBackground()
                .ignoresSafeArea()

            HStack(alignment: .top, spacing: 20) {
                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 12) {
                        Text(reminderManager.localizationService.ui("sentinel"))
                            .font(.system(size: 34, weight: .bold, design: .default))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)

                        Spacer(minLength: 8)

                        @Bindable var manager = reminderManager
                        Toggle("", isOn: $manager.isMasterEnabled)
                            .toggleStyle(.switch)
                            .labelsHidden()
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(.white.opacity(0.18), lineWidth: 1)
                    )

                    Text(reminderManager.localizationService.ui("sentinel_description"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 4)
                        .padding(.bottom, 2)

                    Spacer()

                    Button(action: {
                        let newReminder = reminderManager.addReminder()
                        creatingReminder = newReminder
                    }) {
                        Label(reminderManager.localizationService.ui("add"), systemImage: "plus")
                            .font(.body.weight(.semibold))
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)

                    Button(action: {
                        showInfo = true
                    }) {
                        Label(reminderManager.localizationService.ui("info"), systemImage: "info.circle")
                            .font(.body)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)

                    Button(action: {
                        showSettings = true
                    }) {
                        Label(reminderManager.localizationService.ui("settings"), systemImage: "gearshape")
                            .font(.body)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }
                .padding(14)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(.white.opacity(0.14), lineWidth: 1)
                )
                .frame(width: 290)

                ScrollView {
                    LazyVStack(spacing: 14) {
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
                    .padding(.vertical, 8)
                    .padding(.horizontal, 4)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding(20)
        }
        .frame(width: 860, height: 600)
        .alert(reminderManager.localizationService.ui("info_title"), isPresented: $showInfo) {
            Button(reminderManager.localizationService.ui("done"), role: .cancel) {}
        } message: {
            Text(reminderManager.localizationService.ui("info_message"))
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .environment(reminderManager)
                .environment(settingsManager)
        }
        .sheet(item: $editingReminder) { reminder in
            EditReminderView(reminder: reminder, isCreating: false)
                .environment(reminderManager)
        }
        .sheet(item: $creatingReminder) { reminder in
            EditReminderView(reminder: reminder, isCreating: true)
                .environment(reminderManager)
        }
    }
}
