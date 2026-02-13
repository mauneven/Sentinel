import SwiftUI

struct EditReminderView: View {
    @Environment(ReminderManager.self) private var reminderManager
    @Environment(\.dismiss) private var dismiss

    let originalReminder: Reminder
    let isCreating: Bool
    @State private var editedTitle: String
    @State private var editedDescription: String
    @State private var editedInterval: Double
    private let sliderMarks = [1, 10, 20, 30, 40, 50, 60]

    init(reminder: Reminder, isCreating: Bool = false) {
        self.originalReminder = reminder
        self.isCreating = isCreating
        self._editedTitle = State(initialValue: isCreating ? "" : reminder.title)
        self._editedDescription = State(initialValue: isCreating ? "" : reminder.description)
        self._editedInterval = State(initialValue: Double(min(max(reminder.intervalMinutes, 1), 60)))
    }

    private var hasChanges: Bool {
        if isCreating {
            return !editedTitle.trimmingCharacters(in: .whitespaces).isEmpty
        }
        return editedTitle != originalReminder.title ||
            editedDescription != originalReminder.description ||
            min(max(Int(editedInterval.rounded()), 1), 60) != originalReminder.intervalMinutes
    }

    var body: some View {
        VStack(spacing: 20) {
            Text(isCreating
                 ? reminderManager.localizationService.ui("new_reminder")
                 : reminderManager.localizationService.ui("edit_reminder"))
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .center)

            Divider()

            TextField(reminderManager.localizationService.ui("title_placeholder"), text: $editedTitle)
                .font(.title3)
                .fontWeight(.medium)
                .textFieldStyle(.roundedBorder)

            TextField(reminderManager.localizationService.ui("description_placeholder"), text: $editedDescription, axis: .vertical)
                .lineLimit(3...5)
                .textFieldStyle(.roundedBorder)

            HStack {
                Text(reminderManager.localizationService.ui("interval") + ":")
                IntervalSliderView(
                    value: $editedInterval,
                    range: 1...60,
                    marks: sliderMarks,
                    minuteLabel: reminderManager.localizationService.ui("minutes"),
                    isEnabled: true
                )
            }

            Spacer()

            HStack {
                if !isCreating {
                    Button(action: {
                        reminderManager.deleteReminder(originalReminder)
                        dismiss()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "trash")
                            Text(reminderManager.localizationService.ui("delete"))
                        }
                        .foregroundStyle(.red)
                    }
                    .buttonStyle(.plain)
                }

                Spacer()

                Button(action: {
                    if isCreating {
                        reminderManager.deleteReminder(originalReminder)
                    }
                    dismiss()
                }) {
                    Text(isCreating
                         ? reminderManager.localizationService.ui("cancel")
                         : reminderManager.localizationService.ui("close"))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.gray.opacity(0.3))
                        .foregroundStyle(.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)

                Button(action: {
                    if isCreating {
                        var newReminder = originalReminder
                        newReminder.title = editedTitle.trimmingCharacters(in: .whitespaces)
                        newReminder.description = editedDescription
                        newReminder.intervalMinutes = min(max(Int(editedInterval.rounded()), 1), 60)
                        reminderManager.updateReminder(newReminder)
                    } else if hasChanges {
                        var updated = originalReminder
                        updated.title = editedTitle
                        updated.description = editedDescription
                        updated.intervalMinutes = min(max(Int(editedInterval.rounded()), 1), 60)
                        reminderManager.updateReminder(updated)
                    }
                    dismiss()
                }) {
                    Text(isCreating
                         ? reminderManager.localizationService.ui("create")
                         : reminderManager.localizationService.ui("update"))
                        .fontWeight(.medium)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(hasChanges ? Color.blue : Color.gray.opacity(0.3))
                        .foregroundStyle(hasChanges ? .white : .secondary)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
                .disabled(!hasChanges)
            }
        }
        .padding(24)
        .frame(width: 400, height: 340)
    }
}
