import SwiftUI

struct UpcomingReminderBarView: View {
    @Environment(ReminderManager.self) private var reminderManager
    let items: [UpcomingReminderInfo]

    private var needsScrolling: Bool {
        items.count > 3
    }

    private var listContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(items) { item in
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
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(reminderManager.localizationService.ui("next_reminders"))
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 10)
                .padding(.top, 10)

            Group {
                if items.isEmpty {
                    Text("there are no next reminders")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, minHeight: 88, alignment: .center)
                        .padding(.horizontal, 10)
                        .padding(.bottom, 10)
                } else if needsScrolling {
                    ScrollView(.vertical, showsIndicators: true) {
                        listContent
                    }
                    .frame(maxHeight: 148)
                    .padding(.horizontal, 10)
                    .padding(.bottom, 10)
                } else {
                    listContent
                        .padding(.horizontal, 10)
                        .padding(.bottom, 10)
                }
            }
        }
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(.white.opacity(0.2), lineWidth: 1)
        )
    }
}
