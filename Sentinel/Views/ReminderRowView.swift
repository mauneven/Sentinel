import SwiftUI

struct ReminderRowView: View {
    @Environment(ReminderManager.self) private var reminderManager

    let reminder: Reminder
    let onEdit: () -> Void
    let onToggle: () -> Void
    let onIntervalChange: (Int) -> Void
    let isMasterEnabled: Bool
    private let sliderMarks = [1, 10, 20, 30, 40, 50, 60]

    @State private var sliderValue: Double

    init(reminder: Reminder, onEdit: @escaping () -> Void, onToggle: @escaping () -> Void,
         onIntervalChange: @escaping (Int) -> Void, isMasterEnabled: Bool) {
        self.reminder = reminder
        self.onEdit = onEdit
        self.onToggle = onToggle
        self.onIntervalChange = onIntervalChange
        self.isMasterEnabled = isMasterEnabled
        self._sliderValue = State(initialValue: Double(min(max(reminder.intervalMinutes, 1), 60)))
    }

    var body: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                Button(action: onEdit) {
                    HStack(spacing: 6) {
                        Text(reminder.title)
                            .font(.body)
                            .fontWeight(.medium)
                            .lineLimit(1)
                            .truncationMode(.tail)
                        Image(systemName: "pencil")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .buttonStyle(.plain)

                IntervalSliderView(
                    value: $sliderValue,
                    range: 1...60,
                    marks: sliderMarks,
                    minuteLabel: reminderManager.localizationService.ui("minutes"),
                    isEnabled: isMasterEnabled
                )
                .onChange(of: sliderValue) { _, newValue in
                    let clamped = min(max(Int(newValue.rounded()), 1), 60)
                    onIntervalChange(clamped)
                }
                .onChange(of: reminder.intervalMinutes) { _, newValue in
                    let clamped = min(max(newValue, 1), 60)
                    if Int(sliderValue.rounded()) != clamped {
                        sliderValue = Double(clamped)
                    }
                }
            }

            Toggle("", isOn: Binding(
                get: { reminder.isEnabled },
                set: { _ in onToggle() }
            ))
            .toggleStyle(.switch)
            .labelsHidden()
            .tint(.blue)
            .disabled(!isMasterEnabled)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(.white.opacity(0.12), lineWidth: 1)
        )
        .opacity(isMasterEnabled ? 1.0 : 0.5)
    }
}
