import SwiftUI

struct UpcomingReminderBarView: View {
    @Environment(ReminderManager.self) private var reminderManager
    let items: [UpcomingReminderInfo]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(reminderManager.localizationService.ui("next_reminders"))
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 2) {
                ForEach(items.prefix(3)) { item in
                    VStack(spacing: 2) {
                        Text(item.title)
                            .font(.caption)
                            .lineLimit(1)
                            .foregroundStyle(.primary)
                        Text("\(reminderManager.localizationService.ui("less_than")) \(item.minutesLeft) \(reminderManager.localizationService.ui("minutes"))")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.accentColor.opacity(0.18))
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(.white.opacity(0.12), lineWidth: 1)
            )
        }
    }
}
