import SwiftUI

struct ReminderRowView: View {
    @Environment(ReminderManager.self) private var reminderManager

    let reminder: Reminder
    let onEdit: () -> Void
    let onToggle: () -> Void
    let onIntervalChange: (Int) -> Void
    let isMasterEnabled: Bool
    let onMasterDisabledAttempt: () -> Void

    @State private var sliderValue: Double

    init(reminder: Reminder, onEdit: @escaping () -> Void, onToggle: @escaping () -> Void,
         onIntervalChange: @escaping (Int) -> Void, isMasterEnabled: Bool, onMasterDisabledAttempt: @escaping () -> Void) {
        self.reminder = reminder
        self.onEdit = onEdit
        self.onToggle = onToggle
        self.onIntervalChange = onIntervalChange
        self.isMasterEnabled = isMasterEnabled
        self.onMasterDisabledAttempt = onMasterDisabledAttempt
        self._sliderValue = State(initialValue: Double(min(max(reminder.intervalMinutes, 1), 60)))
    }

    private var displayEnabledState: Bool {
        isMasterEnabled && reminder.isEnabled
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 10) {
                    Text(reminder.title)
                        .font(.system(size: 17, weight: .semibold))
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .foregroundStyle(isMasterEnabled ? .primary : .secondary)

                    Spacer(minLength: 110)
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

            HStack(spacing: 10) {
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

                Toggle("", isOn: Binding(
                    get: { displayEnabledState },
                    set: { _ in
                        guard isMasterEnabled else {
                            onMasterDisabledAttempt()
                            return
                        }
                        onToggle()
                    }
                ))
                .toggleStyle(.switch)
                .labelsHidden()
                .tint(.blue)
                .animation(.easeInOut(duration: 0.2), value: isMasterEnabled)
            }
            .padding(.top, 2)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(.white.opacity(0.2), lineWidth: 1)
        )
    }
}
