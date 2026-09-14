import SwiftUI
import SwiftData

/// Percentage-based status for metrics you're trying to *reach* a target on.
/// under 80% → under (red), 80–99% → close (amber), ≥100% → met (green).
enum NutrientStatus {
    case under, close, met

    static func forRatio(current: Int, target: Int) -> NutrientStatus {
        guard target > 0 else { return .met }
        let ratio = Double(current) / Double(target)
        if ratio < 0.8 { return .under }
        if ratio < 1.0 { return .close }
        return .met
    }

    var color: Color {
        switch self {
        case .under: return .red
        case .close: return Color(red: 1.0, green: 0.75, blue: 0.0)
        case .met: return .green
        }
    }
}

enum CalorieStatus {
    case within, over

    static func forTotal(_ total: Int, target: Int) -> CalorieStatus {
        total <= target ? .within : .over
    }

    var color: Color {
        switch self {
        case .within: return .green
        case .over: return .red
        }
    }
}

/// Anything that contributes to a day's running totals. `Entry` conforms below,
/// but tests can use a plain stub — no SwiftData container required.
protocol NutrientContributing {
    var calories: Int { get }
    var protein: Int { get }
    var fruitVeg: Int { get }
}

struct DailyTotals: Equatable {
    var calories: Int
    var protein: Int
    var fruitVeg: Int

    init(calories: Int = 0, protein: Int = 0, fruitVeg: Int = 0) {
        self.calories = calories
        self.protein = protein
        self.fruitVeg = fruitVeg
    }

    init<S: Sequence>(_ items: S) where S.Element: NutrientContributing {
        var totals = DailyTotals()
        for item in items {
            totals.calories += item.calories
            totals.protein += item.protein
            totals.fruitVeg += item.fruitVeg
        }
        self = totals
    }
}

extension Entry: NutrientContributing {}

enum EntryValidator {
    /// Whether the Add button should be disabled. An untracked metric is never required.
    static func isAdditionDisabled(
        item: String,
        calories: String,
        protein: String,
        trackCalories: Bool,
        trackProtein: Bool
    ) -> Bool {
        if item.isEmpty { return true }
        if trackCalories && (calories.isEmpty || Int(calories) == nil) { return true }
        if trackProtein && (protein.isEmpty || Int(protein) == nil) { return true }
        return false
    }
}

enum NutrientBar {
    /// Fraction of the bar to fill, clamped to 0...1. Returns 0 for a non-positive limit.
    static func fillFraction(current: Int, limit: Int) -> CGFloat {
        guard limit > 0 else { return 0 }
        return min(CGFloat(current), CGFloat(limit)) / CGFloat(limit)
    }
}

enum EntryGrouping {
    static func byCategory(_ entries: [Entry]) -> [MealCategory: [Entry]] {
        Dictionary(grouping: entries, by: \.category)
    }

    /// Categories that actually have entries, in canonical meal order.
    static func presentCategories(in entries: [Entry]) -> [MealCategory] {
        MealCategory.allCases.filter { category in
            entries.contains { $0.category == category }
        }
    }
}

enum EntryStore {
    /// Removes every entry dated before the start of `day`. Injecting `day` keeps
    /// the daily-reset behaviour deterministic under test.
    static func deleteEntries(before day: Date, in context: ModelContext) throws {
        let startOfDay = Calendar.current.startOfDay(for: day)
        let descriptor = FetchDescriptor<Entry>(
            predicate: #Predicate<Entry> { entry in
                entry.date < startOfDay
            }
        )
        let stale = try context.fetch(descriptor)
        stale.forEach { context.delete($0) }
        try context.save()
    }

    static func deleteEntry(id: UUID, in context: ModelContext) throws {
        let descriptor = FetchDescriptor<Entry>(
            predicate: #Predicate<Entry> { entry in
                entry.id == id
            }
        )
        let matches = try context.fetch(descriptor)
        matches.forEach { context.delete($0) }
        try context.save()
    }
}
