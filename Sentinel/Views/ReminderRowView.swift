import SwiftUI

struct ReminderRowView: View {
    @Environment(ReminderManager.self) private var reminderManager

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
        self._sliderValue = State(initialValue: Double(min(max(reminder.intervalMinutes, 1), 60)))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Text(reminder.title)
                    .font(.system(size: 17, weight: .semibold))
                    .lineLimit(1)
                    .truncationMode(.tail)

                Toggle("", isOn: Binding(
                    get: { reminder.isEnabled },
                    set: { _ in onToggle() }
                ))
                .toggleStyle(.switch)
                .labelsHidden()
                .tint(.blue)
                .disabled(!isMasterEnabled)

                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .font(.system(size: 14, weight: .semibold))
                        .frame(width: 28, height: 28)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .stroke(.white.opacity(0.22), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }

            IntervalSliderView(
                value: $sliderValue,
                range: 1...60,
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
