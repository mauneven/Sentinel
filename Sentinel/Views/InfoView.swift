import SwiftUI

struct InfoView: View {
    @Environment(ReminderManager.self) private var reminderManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 8) {
                if let appIcon = NSImage(named: NSImage.applicationIconName) ?? NSApp.applicationIconImage {
                    Image(nsImage: appIcon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 72, height: 72)
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                }
                
                Text(reminderManager.localizationService.ui("info_title"))
                    .font(.system(size: 24, weight: .bold, design: .default))
                
                Text(reminderManager.localizationService.ui("sentinel_description"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 16)
            .padding(.bottom, 24)
            
            Divider()
            
            // Content
            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading, spacing: 24) {
                    
                    InfoSection(
                        icon: "bolt.heart.fill",
                        iconColor: .pink,
                        title: reminderManager.localizationService.ui("info_how_it_works_title"),
                        description: reminderManager.localizationService.ui("info_how_it_works_desc")
                    )
                    
                    InfoSection(
                        icon: "brain.head.profile",
                        iconColor: .purple,
                        title: reminderManager.localizationService.ui("info_why_matters_title"),
                        description: reminderManager.localizationService.ui("info_why_matters_desc")
                    )
                    
                    InfoSection(
                        icon: "lightbulb.max.fill",
                        iconColor: .yellow,
                        title: reminderManager.localizationService.ui("info_tips_title"),
                        description: reminderManager.localizationService.ui("info_tips_desc")
                    )
                }
                .padding(24)
            }
            
            Divider()
            
            // Footer
            HStack {
                Text("\(reminderManager.localizationService.ui("version")) 1.0.0")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                
                Spacer()
                
                Button(action: {
                    dismiss()
                }) {
                    Text(reminderManager.localizationService.ui("done"))
                        .frame(minWidth: 80)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
            .padding(16)
            .background(Color(NSColor.windowBackgroundColor).opacity(0.5))
        }
        .frame(width: 480, height: 600)
    }
}

private struct InfoSection: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(iconColor)
                .frame(width: 32, alignment: .center)
                .padding(.top, 2)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .lineSpacing(4)
            }
        }
    }
}
