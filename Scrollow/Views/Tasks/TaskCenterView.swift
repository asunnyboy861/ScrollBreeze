import SwiftUI

struct TaskCenterView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var model = TaskModel()
    @StateObject private var purchaseManager = PurchaseManager.shared
    @State private var selectedTask: ReclaimTask?
    @State private var showCapture = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if purchaseManager.isPro || purchaseManager.byoOwned {
                        taskList
                    } else {
                        upsellCard
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 12)
                .frame(maxWidth: 720)
                .frame(maxWidth: .infinity)
            }
            .screenBackground()
            .preferredColorScheme(.dark)
            .navigationTitle("Earn a window")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(.white)
                }
            }
            .sheet(isPresented: $showCapture) {
                if let task = selectedTask {
                    TaskCaptureView(task: task, model: model)
                }
            }
            .onChange(of: model.stage) { _, stage in
                if case .passed(let minutes) = stage {
                    dismissAfterReward()
                } else if case .honorMode = stage {
                    dismissAfterReward()
                }
            }
        }
    }

    private var taskList: some View {
        ForEach(ReclaimTask.all) { task in
            Button {
                selectedTask = task
                showCapture = true
            } label: {
                HStack(spacing: 16) {
                    Text(task.emoji)
                        .font(.system(size: 34))
                    VStack(alignment: .leading, spacing: 4) {
                        Text(task.title)
                            .font(.headline)
                            .foregroundStyle(.white)
                        Text("Photo check → 30 min window + 💧")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.5))
                    }
                    Spacer()
                    Image(systemName: "camera.fill")
                        .foregroundStyle(Theme.teal)
                }
                .padding(18)
                .background(Theme.card(ColorScheme.dark))
                .clipShape(RoundedRectangle(cornerRadius: 18))
            }
            .accessibilityLabel("Task: \(task.title)")
        }
        .overlay { stageBanner }
    }

    @ViewBuilder
    private var stageBanner: some View {
        switch model.stage {
        case .verifying:
            VStack {
                Spacer()
                HStack {
                    ProgressView()
                        .tint(.white)
                    Text("Checking your photo…")
                        .font(.subheadline)
                        .foregroundStyle(.white)
                }
                .padding(14)
                .background(Theme.indigo.opacity(0.85))
                .clipShape(Capsule())
                Spacer()
            }
        case .failed(let reason):
            VStack {
                Spacer()
                Text(reason)
                    .font(.subheadline)
                    .foregroundStyle(.white)
                    .padding(14)
                    .background(Color.orange.opacity(0.85))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                Spacer()
            }
            .padding(.horizontal, 24)
        default:
            EmptyView()
        }
    }

    private var upsellCard: some View {
        VStack(spacing: 16) {
            Image(systemName: "sparkles")
                .font(.system(size: 44))
                .foregroundStyle(Theme.ringGradient)
            Text("AI-verified tasks are Pro")
                .font(.title3.bold())
                .foregroundStyle(.white)
            Text("Do a real-world task — squats, a walk, tidying — snap a photo, and earn a 30-minute window. \"Earned. Not borrowed.\"")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.6))
                .multilineTextAlignment(.center)
            Text("Breathing unlock stays free forever.")
                .font(.caption)
                .foregroundStyle(Theme.teal)
        }
        .padding(24)
        .background(Theme.card(ColorScheme.dark))
        .clipShape(RoundedRectangle(cornerRadius: 22))
    }

    private func dismissAfterReward() {
        Task {
            try? await Task.sleep(nanoseconds: 1_600_000_000)
            dismiss()
        }
    }
}
