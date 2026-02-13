import SwiftUI

struct MasterToggleView: View {
    @Environment(ReminderManager.self) private var reminderManager
    @Binding var showSettings: Bool

    var body: some View {
        HStack {
            Text("Sentinel")
                .font(.title2)
                .fontWeight(.bold)

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
