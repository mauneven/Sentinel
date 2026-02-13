import SwiftUI

struct SettingsView: View {
    @Environment(SettingsManager.self) private var settingsManager
    @Environment(ReminderManager.self) private var reminderManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(reminderManager.localizationService.ui("settings"))
                .font(.title2)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .center)

            Divider()

            @Bindable var sm = settingsManager

            HStack {
                Text(reminderManager.localizationService.ui("language"))
                Spacer()
                Picker("", selection: $sm.language) {
                    ForEach(AppLanguage.allCases, id: \.self) { lang in
                        Text(lang.displayName).tag(lang)
                    }
                }
                .labelsHidden()
                .frame(width: 140)
                .onChange(of: settingsManager.language) { _, newLang in
                    reminderManager.changeLanguage(to: newLang)
                }
            }

            Toggle(reminderManager.localizationService.ui("launch_at_login"),
                   isOn: $sm.launchAtLogin)
                .toggleStyle(.checkbox)

            Toggle(reminderManager.localizationService.ui("start_minimized"),
                   isOn: $sm.startMinimized)
                .toggleStyle(.checkbox)
                .disabled(!settingsManager.launchAtLogin)
                .foregroundStyle(settingsManager.launchAtLogin ? .primary : .secondary)

            Spacer()

            Button(reminderManager.localizationService.ui("done")) { dismiss() }
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(24)
        .frame(width: 300, height: 250)
    }
}
