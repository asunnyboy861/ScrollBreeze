import Foundation
import SwiftData

@Model
final class GateEvent {
    var id: UUID
    var date: Date
    var kind: String
    var minutes: Int
    var detail: String

    init(date: Date = Date(), kind: String, minutes: Int = 0, detail: String = "") {
        self.id = UUID()
        self.date = date
        self.kind = kind
        self.minutes = minutes
        self.detail = detail
    }
}
