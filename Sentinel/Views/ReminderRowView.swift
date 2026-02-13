import SwiftUI

struct ReminderRowView: View {
    let reminder: Reminder
    let onEdit: () -> Void
    let onToggle: () -> Void
    let onIntervalChange: (Int) -> Void
    let isMasterEnabled: Bool

    @State private var sliderValue: Double

    init(reminder: Reminder, onEdit: @escaping () -> Void, onToggle: @escaping () -> Void,
         onIntervalChange: @escaping (Int) -> Void, isMasterEnabled: Bool) {
        self.reminder = reminder
        self.onEdit = onEdit
        self.onToggle = onToggle
        self.onIntervalChange = onIntervalChange
        self.isMasterEnabled = isMasterEnabled
        self._sliderValue = State(initialValue: Double(reminder.intervalMinutes))
    }

    var body: some View {
        HStack(spacing: 12) {
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

                HStack(spacing: 8) {
                    Slider(value: $sliderValue, in: 1...120, step: 1)
                        .onChange(of: sliderValue) { _, newValue in
                            onIntervalChange(Int(newValue))
                        }
                        .disabled(!isMasterEnabled)
                    Text("\(Int(sliderValue)) min")
                        .font(.callout)
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                        .frame(width: 50, alignment: .trailing)
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
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .opacity(isMasterEnabled ? 1.0 : 0.5)
    }
}
