import Foundation
import SwiftData
import SwiftUI

@MainActor
final class WeeklyModel: ObservableObject {
    @Published var card: HomeModel.WeeklyCard?
    @Published var isLoading = false

    func generate(context: ModelContext) async {
        isLoading = true
        defer { isLoading = false }

        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let descriptor = FetchDescriptor<GateEvent>(
            predicate: #Predicate { $0.date > weekAgo })
        let events = (try? context.fetch(descriptor)) ?? []

        let reclaimed = events.filter { $0.kind == "giveUp" || $0.kind == "taskPass" || $0.kind == "taskHonor" }
            .reduce(0) { $0 + $1.minutes }
        let giveUps = events.filter { $0.kind == "giveUp" }.count
        let lateNight = events.filter { event in
            let hour = Calendar.current.component(.hour, from: event.date)
            return hour >= 23 || hour < 5
        }.count

        let summary = "This week: \(reclaimed) minutes reclaimed, \(giveUps) conscious pauses, \(lateNight) late-night moments."

        if let sentence = await EdgeAI.weeklyInsight(summary: summary) {
            card = makeCard(from: sentence, summary: summary)
            return
        }
        card = templateCard(reclaimed: reclaimed, giveUps: giveUps, lateNight: lateNight)
    }

    private func makeCard(from sentence: String, summary: String) -> HomeModel.WeeklyCard {
        let parts = sentence.components(separatedBy: ". ")
        let headline = parts.first.map { $0.hasSuffix(".") ? $0 : $0 + "." } ?? sentence
        let suggestion = parts.count > 1 ? parts[1] : nil
        let wantsNightGate = suggestion?.lowercased().contains("night") == true
            || summary.lowercased().contains("late-night")
        return HomeModel.WeeklyCard(
            sentence: headline,
            suggestion: suggestion,
            suggestionAppliesNightGate: wantsNightGate)
    }

    private func templateCard(reclaimed: Int, giveUps: Int, lateNight: Int) -> HomeModel.WeeklyCard {
        var sentence = "You reclaimed \(reclaimed) minutes this week across \(giveUps) mindful pauses."
        if lateNight > 0 {
            sentence += " Late-night scrolling showed up \(lateNight) times."
        }
        let suggestion = lateNight >= 3 ? "Want a night gate for those hours?" : nil
        return HomeModel.WeeklyCard(
            sentence: sentence,
            suggestion: suggestion,
            suggestionAppliesNightGate: suggestion != nil)
    }
}
