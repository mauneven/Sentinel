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
    @State private var searchText = ""

    private var filteredReminders: [Reminder] {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return reminderManager.reminders
        }

        let query = searchText.lowercased()
        return reminderManager.reminders.filter { reminder in
            reminder.title.lowercased().contains(query) ||
            reminder.description.lowercased().contains(query)
        }
    }

    var body: some View {
        ZStack {
            MacOSBlurBackground()
                .ignoresSafeArea()

            NavigationSplitView {
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

                    UpcomingReminderBarView()
                        .environment(reminderManager)

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
                .padding(.top, 14)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .navigationSplitViewColumnWidth(min: 280, ideal: 295, max: 320)
            } detail: {
                VStack(spacing: 0) {
                    ScrollView(.vertical, showsIndicators: true) {
                        LazyVStack(spacing: 14) {
                            ForEach(filteredReminders) { reminder in
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
                        .padding(.top, 12)
                        .padding(.bottom, 24)
                        .padding(.horizontal, 20)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .scrollIndicators(.visible)
                }
                .padding(.top, 0)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .navigationSplitViewStyle(.automatic)
        }
        // Avoid broad root-level animations to prevent layout stutter
        .frame(minWidth: 860, minHeight: 600)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack {
                    Spacer()
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)
                        TextField("Search", text: $searchText)
                            .textFieldStyle(.plain)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .frame(minWidth: 400, maxWidth: 450)
                    Spacer()
                }
            }
        }
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

