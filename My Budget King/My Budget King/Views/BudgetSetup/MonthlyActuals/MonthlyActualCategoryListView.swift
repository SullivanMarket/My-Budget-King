import SwiftUI
import Foundation

// If needed, declare this struct locally for this view only
struct MonthlyActualItemFinalLocal: Identifiable, Codable {
    var id: UUID
    var name: String
    var budgeted: Double
    var actual: Double
}
