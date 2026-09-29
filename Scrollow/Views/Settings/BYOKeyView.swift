import SwiftUI

struct BYOKeyView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var keyInput = ""
    @State private var saved = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Use your own AI key")
                        .font(.title3.bold())
                        .foregroundStyle(.white)
                    Text("Paste a Z.ai or BigModel API key to run AI task verification with your own balance — unlimited, and Scrollow never sees your calls beyond the request itself.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.6))

                    SecureField(text: $keyInput) {
                        Text("sk-…")
                    }
                    .padding(14)
                        .background(Theme.card(colorScheme))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))

                    if AppGroupStore.hasBYOKey {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Key configured — stored in your device Keychain")
                        }
                        .font(.caption)
                        .foregroundStyle(Theme.teal)
                    }

                    Button {
                        let trimmed = keyInput.trimmingCharacters(in: .whitespaces)
                        guard !trimmed.isEmpty else { return }
                        Secrets.saveBYOKey(trimmed)
                        saved = true
                        Haptics.success()
                        Task {
                            try? await Task.sleep(nanoseconds: 900_000_000)
                            dismiss()
                        }
                    } label: {
                        Text("Save key")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(keyInput.isEmpty ? Color.white.opacity(0.12) : Theme.accent)
                            .foregroundStyle(keyInput.isEmpty ? .white.opacity(0.5) : Theme.deepSpace)
                            .clipShape(Capsule())
                    }
                    .disabled(keyInput.isEmpty)
                    .accessibilityLabel("Save API key")

                    if AppGroupStore.hasBYOKey {
                        Button(role: .destructive) {
                            Secrets.deleteBYOKey()
                            keyInput = ""
                        } label: {
                            Text("Remove key")
                        }
                    }

                    Text("Your key is stored in the iOS Keychain, never in iCloud or backups of app data.")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.4))
                }
                .padding(24)
            }
            .screenBackground()
            .preferredColorScheme(.dark)
            .navigationTitle("Custom API Key")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(.white)
                }
            }
        }
    }
}
