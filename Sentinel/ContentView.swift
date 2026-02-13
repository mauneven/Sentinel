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
    @State private var columnVisibility: NavigationSplitViewVisibility = .all

    var body: some View {
        ZStack {
            MacOSBlurBackground()
                .ignoresSafeArea()

            NavigationSplitView(columnVisibility: $columnVisibility) {
                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 12) {
                        Text(reminderManager.localizationService.ui("sentinel"))
                            .font(.system(size: 34, weight: .bold, design: .default))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)

                        Spacer(minLength: 8)

                        Toggle("", isOn: Binding(
                            get: { reminderManager.isMasterEnabled },
                            set: { newValue in
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    reminderManager.isMasterEnabled = newValue
                                }
                            }
                        ))
                        .toggleStyle(.switch)
                        .labelsHidden()
                    }

                    Text(reminderManager.localizationService.ui("sentinel_description"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 2)

                    Spacer(minLength: 12)

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
                .padding(.horizontal, 14)
                .padding(.bottom, 16)
                .padding(.top, 34)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .navigationSplitViewColumnWidth(min: 280, ideal: 295, max: 320)
            } detail: {
                VStack(spacing: 10) {
                    if !reminderManager.upcomingReminders.isEmpty {
                        UpcomingReminderBarView(items: reminderManager.upcomingReminders)
                            .environment(reminderManager)
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                    }

                    ScrollView(.vertical, showsIndicators: true) {
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
                        .padding(.top, 6)
                        .padding(.bottom, 24)
                        .padding(.leading, 4)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .scrollIndicators(.visible)
                }
                .padding(.top, 8)
                .padding(.horizontal, 12)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .navigationSplitViewStyle(.balanced)

            if showInfo {
                InfoPopupView(
                    title: reminderManager.localizationService.ui("info_title"),
                    message: reminderManager.localizationService.ui("info_message"),
                    buttonTitle: reminderManager.localizationService.ui("done"),
                    onClose: { showInfo = false }
                )
                .transition(.scale.combined(with: .opacity))
                .zIndex(1)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showInfo)
        .frame(minWidth: 860, minHeight: 600)
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

private struct InfoPopupView: View {
    let title: String
    let message: String
    let buttonTitle: String
    let onClose: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.title3.weight(.semibold))

            Text(message)
                .font(.body)
                .foregroundStyle(.secondary)

            HStack {
                Spacer()
                Button(buttonTitle, action: onClose)
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding(18)
        .frame(width: 420)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(.white.opacity(0.18), lineWidth: 1)
        )
    }
}
