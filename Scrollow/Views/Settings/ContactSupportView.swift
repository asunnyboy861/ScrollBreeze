import SwiftUI

struct ContactSupportView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @FocusState private var messageFocused: Bool

    enum Subject: String, CaseIterable, Identifiable {
        case general = "General"
        case feature = "Feature Suggestion"
        case bug = "Bug Report"
        case usage = "Usage Question"
        case performance = "Performance Issue"
        case ui = "UI Improvement"
        case other = "Other"

        var id: String { rawValue }

        var symbol: String {
            switch self {
            case .general: return "bubble.left.fill"
            case .feature: return "lightbulb.fill"
            case .bug: return "ant.fill"
            case .usage: return "questionmark.circle.fill"
            case .performance: return "gauge.with.dots.needle.67percent"
            case .ui: return "paintpalette.fill"
            case .other: return "ellipsis.circle.fill"
            }
        }
    }

    @State private var subject: Subject = .general
    @State private var customSubject = ""
    @State private var name = ""
    @State private var email = ""
    @State private var message = ""
    @State private var isSubmitting = false
    @State private var successBanner = false
    @State private var errorText: String?

    private let backendURL = URL(string: "https://feedback-board.iocompile67692.workers.dev/api/feedback")!
    private let maxMessageLength = 1000

    private var emailValid: Bool {
        email.contains("@") && email.contains(".") && !email.hasPrefix("@") && !email.hasSuffix(".")
    }

    private var canSubmit: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
            && emailValid
            && (subject != .other || !customSubject.trimmingCharacters(in: .whitespaces).isEmpty)
            && !message.trimmingCharacters(in: .whitespaces).isEmpty
            && !isSubmitting
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    subjectGrid

                    if subject == .other {
                        TextField("Custom subject", text: $customSubject)
                            .padding(14)
                            .background(Theme.card(colorScheme))
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }

                    TextField("Your name", text: $name)
                        .padding(14)
                        .background(Theme.card(colorScheme))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))

                    TextField("yourname@example.com", text: $email)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .autocorrectionDisabled()
                        .padding(14)
                        .background(Theme.card(colorScheme))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))

                    if !email.isEmpty && !emailValid {
                        Text("Please enter a valid email address.")
                            .font(.caption)
                            .foregroundStyle(.orange)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        ZStack(alignment: .topLeading) {
                            if message.isEmpty {
                                Text("Tell us what's on your mind…")
                                    .foregroundStyle(.white.opacity(0.35))
                                    .padding(.top, 8)
                                    .padding(.leading, 5)
                            }
                            TextEditor(text: $message)
                                .focused($messageFocused)
                                .frame(minHeight: 120)
                                .scrollContentBackground(.hidden)
                                .foregroundStyle(.white)
                                .onChange(of: message) { _, value in
                                    if value.count > maxMessageLength {
                                        message = String(value.prefix(maxMessageLength))
                                    }
                                }
                        }
                        .padding(10)
                        .background(Theme.card(colorScheme))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        Text("\(message.count) / \(maxMessageLength)")
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.4))
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }

                    Button {
                        submit()
                    } label: {
                        HStack {
                            if isSubmitting {
                                ProgressView()
                                    .tint(Theme.deepSpace)
                            }
                            Text(isSubmitting ? "Sending…" : "Submit")
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(canSubmit ? Theme.accent : Color.white.opacity(0.12))
                        .foregroundStyle(canSubmit ? Theme.deepSpace : .white.opacity(0.5))
                        .clipShape(Capsule())
                    }
                    .disabled(!canSubmit)
                    .accessibilityLabel("Submit feedback")

                    Text("We only use your email to respond to this feedback.")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.45))

                    if successBanner {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Thank you! Your feedback has been sent.")
                        }
                        .foregroundStyle(Theme.teal)
                        .font(.subheadline)
                    }
                    if let errorText {
                        Text(errorText)
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                }
                .padding(24)
                .frame(maxWidth: 720)
                .frame(maxWidth: .infinity)
            }
            .screenBackground()
            .preferredColorScheme(.dark)
            .navigationTitle("Contact Support")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(.white)
                }
            }
        }
    }

    private var subjectGrid: some View {
        VStack(spacing: 12) {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach([Subject.general, .feature, .bug, .usage, .performance, .ui]) { option in
                    subjectTile(option)
                }
            }
            subjectTile(.other)
        }
    }

    private func subjectTile(_ option: Subject) -> some View {
        Button {
            subject = option
        } label: {
            VStack(spacing: 8) {
                Image(systemName: option.symbol)
                    .font(.title3)
                Text(option.rawValue)
                    .font(.caption.weight(.medium))
                    .multilineTextAlignment(.center)
                if subject == option {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption2)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .padding(.horizontal, 8)
            .background(subject == option ? Theme.accent.opacity(0.9) : Theme.card(colorScheme))
            .foregroundStyle(subject == option ? Theme.deepSpace : .white.opacity(0.75))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(subject == option ? Theme.teal : Color.white.opacity(0.08), lineWidth: 1))
        }
        .buttonStyle(.plain)
        .scaleEffect(subject == option ? 1.02 : 1)
        .animation(.easeOut(duration: 0.15), value: subject)
        .accessibilityLabel("Subject: \(option.rawValue)")
        .accessibilityAddTraits(subject == option ? .isSelected : [])
    }

    private func submit() {
        isSubmitting = true
        errorText = nil
        let payload = FeedbackRequest(
            name: name.trimmingCharacters(in: .whitespaces),
            email: email.trimmingCharacters(in: .whitespaces),
            subject: subject == .other ? customSubject : subject.rawValue,
            message: message,
            app_name: "Scrollow")

        var request = URLRequest(url: backendURL)
        request.httpMethod = "POST"
        request.timeoutInterval = 15
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(payload)

        Task {
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
                    throw URLError(.badServerResponse)
                }
                _ = try? JSONDecoder().decode(FeedbackResponse.self, from: data)
                await MainActor.run {
                    isSubmitting = false
                    successBanner = true
                    Haptics.success()
                    Task {
                        try? await Task.sleep(nanoseconds: 1_500_000_000)
                        dismiss()
                    }
                }
            } catch {
                await MainActor.run {
                    isSubmitting = false
                    errorText = "Something went wrong. Please try again."
                    Haptics.warning()
                }
            }
        }
    }
}

struct FeedbackRequest: Codable {
    let name: String
    let email: String
    let subject: String
    let message: String
    let app_name: String
}

struct FeedbackResponse: Codable {
    let success: Bool?
    let id: Int?
    let error: String?
}
