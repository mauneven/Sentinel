import SwiftUI

struct UpcomingReminderBarView: View {
    @Environment(ReminderManager.self) private var reminderManager

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { _ in
            let items = Array(reminderManager.upcomingReminders.prefix(6))

            VStack(alignment: .leading, spacing: 11) {
                Text(reminderManager.localizationService.ui("next_reminders"))
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.secondary)

                if items.isEmpty {
                    Text("there are no next reminders")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, minHeight: 88, alignment: .center)
                } else {
                    VStack(alignment: .leading, spacing: 11) {
                        ForEach(items) { item in
                            reminderItem(item)
                        }
                    }
                }
            }
        }
    }

    private func reminderItem(_ item: UpcomingReminderInfo) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(item.title)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
                .foregroundStyle(.primary)

            Text("\(reminderManager.localizationService.ui("less_than")) \(item.minutesLeft) \(reminderManager.localizationService.ui("minutes"))")
                .font(.caption2)
                .lineLimit(1)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(.white.opacity(0.2), lineWidth: 1)
        )
    }
}
