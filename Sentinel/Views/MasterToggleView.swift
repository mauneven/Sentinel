import SwiftUI
import AppKit

struct WindowControlButtons: View {
    var body: some View {
        HStack(spacing: 8) {
            Button(action: {
                AppWindowController.shared.closeToTray()
            }) {
                Circle()
                    .fill(Color(nsColor: .systemRed))
                    .frame(width: 12, height: 12)
            }
            .buttonStyle(.plain)

            Button(action: {
                AppWindowController.shared.minimizeMainWindow()
            }) {
                Circle()
                    .fill(Color(nsColor: .systemYellow))
                    .frame(width: 12, height: 12)
            }
            .buttonStyle(.plain)
        }
    }
}

struct MasterToggleView: View {
    @Environment(ReminderManager.self) private var reminderManager
    @Binding var showSettings: Bool

    var body: some View {
        HStack {
            HStack(spacing: 10) {
                WindowControlButtons()

                Text(reminderManager.localizationService.ui("sentinel"))
                    .font(.title2)
                    .fontWeight(.bold)
            }

            Spacer()

            @Bindable var manager = reminderManager
            Toggle("", isOn: $manager.isMasterEnabled)
                .toggleStyle(.switch)
                .labelsHidden()
                .tint(.blue)

            Button(action: { showSettings = true }) {
                Image(systemName: "gearshape.fill")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
    }
}
