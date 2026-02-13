import SwiftUI

struct ReminderRowView: View {
    @Environment(ReminderManager.self) private var reminderManager

    let reminder: Reminder
    let onEdit: () -> Void
    let onToggle: () -> Void
    let onIntervalChange: (Int) -> Void
    let isMasterEnabled: Bool

    @State private var sliderValue: Double
    @State private var wigglePhase: CGFloat = 0

    init(reminder: Reminder, onEdit: @escaping () -> Void, onToggle: @escaping () -> Void,
         onIntervalChange: @escaping (Int) -> Void, isMasterEnabled: Bool) {
        self.reminder = reminder
        self.onEdit = onEdit
        self.onToggle = onToggle
        self.onIntervalChange = onIntervalChange
        self.isMasterEnabled = isMasterEnabled
        self._sliderValue = State(initialValue: Double(min(max(reminder.intervalMinutes, 1), 60)))
    }

    private var displayEnabledState: Bool {
        isMasterEnabled && reminder.isEnabled
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Text(reminder.title)
                    .font(.system(size: 17, weight: .semibold))
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .foregroundStyle(isMasterEnabled ? .primary : .secondary)

                Toggle("", isOn: Binding(
                    get: { displayEnabledState },
                    set: { _ in
                        guard isMasterEnabled else {
                            withAnimation(.easeInOut(duration: 0.42)) {
                                wigglePhase += 1
                            }
                            return
                        }
                        onToggle()
                    }
                ))
                .toggleStyle(.switch)
                .labelsHidden()
                .tint(.blue)
                .animation(.easeInOut(duration: 0.2), value: isMasterEnabled)
                .modifier(WiggleEffect(progress: wigglePhase))

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
                .stroke(.white.opacity(0.2), lineWidth: 1)
        )
    }
}

private struct WiggleEffect: GeometryEffect {
    var progress: CGFloat

    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        let amplitude: CGFloat = 4
        let translation = amplitude * sin(progress * .pi * 6)
        return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
    }
}
