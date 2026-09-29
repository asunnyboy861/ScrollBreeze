import Foundation

struct Verdict: Codable {
    let pass: Bool
    let confidence: Double
    let reason: String
}

struct ReclaimTask: Identifiable, Hashable {
    let id: String
    let title: String
    let prompt: String
    let symbol: String
    let emoji: String

    static let all: [ReclaimTask] = [
        ReclaimTask(
            id: "squats",
            title: "10 squats",
            prompt: "A person who just finished about ten squat exercises, standing or mid-workout, athletic posture",
            symbol: "figure.strengthtraining.traditional",
            emoji: "🏋️"),
        ReclaimTask(
            id: "walk",
            title: "5-minute walk",
            prompt: "An outdoor scene taken while walking, such as a street, sidewalk, park path, or view from a walk",
            symbol: "figure.walk",
            emoji: "🚶"),
        ReclaimTask(
            id: "desk",
            title: "Tidy your desk",
            prompt: "A clean, organized desk or tabletop after tidying, with items arranged neatly",
            symbol: "tray.full",
            emoji: "🧹"),
    ]
}
