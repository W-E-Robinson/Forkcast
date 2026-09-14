import Testing
import Foundation
@testable import Forkcast

// Pure-logic tests. No SwiftData container, no simulator state — these run in
// milliseconds because everything under test is a plain function or value type.

@Suite("Nutrient status bands (goal metrics)")
struct NutrientStatusTests {
    // under 80% → under (red), 80–99% → close (amber), ≥100% → met (green)
    @Test(arguments: [
        (0, 5, NutrientStatus.under),   // 0%
        (3, 5, .under),                 // 60%
        (4, 5, .close),                 // 80% — lower amber edge
        (5, 5, .met),                   // 100% — lower green edge
        (7, 5, .met),                   // 140% — over target still met
        (119, 120, .close),             // 99%-ish protein
        (120, 120, .met),               // exactly on protein target
    ])
    func band(current: Int, target: Int, expected: NutrientStatus) {
        #expect(NutrientStatus.forRatio(current: current, target: target) == expected)
    }

    @Test func zeroOrNegativeTargetIsTreatedAsMet() {
        #expect(NutrientStatus.forRatio(current: 0, target: 0) == .met)
    }
}

@Suite("Calorie status (limit metric)")
struct CalorieStatusTests {
    @Test(arguments: [
        (0, 2000, CalorieStatus.within),
        (2000, 2000, .within),   // exactly on the limit is still within
        (2001, 2000, .over),
    ])
    func status(total: Int, target: Int, expected: CalorieStatus) {
        #expect(CalorieStatus.forTotal(total, target: target) == expected)
    }
}

@Suite("Daily totals")
struct DailyTotalsTests {
    // A plain stub — proves the totals logic needs no SwiftData.
    private struct Stub: NutrientContributing {
        var calories: Int
        var protein: Int
        var fruitVeg: Int
    }

    @Test func sumsEachNutrientIndependently() {
        let items = [
            Stub(calories: 500, protein: 30, fruitVeg: 2),
            Stub(calories: 250, protein: 10, fruitVeg: 3),
        ]
        #expect(DailyTotals(items) == DailyTotals(calories: 750, protein: 40, fruitVeg: 5))
    }

    @Test func emptyIsAllZero() {
        #expect(DailyTotals([Stub]()) == DailyTotals())
    }
}

@Suite("Add-entry validation")
struct EntryValidatorTests {
    @Test func emptyItemIsAlwaysDisabled() {
        #expect(EntryValidator.isAdditionDisabled(
            item: "", calories: "100", protein: "10",
            trackCalories: true, trackProtein: true) == true)
    }

    @Test func validFullyTrackedEntryIsEnabled() {
        #expect(EntryValidator.isAdditionDisabled(
            item: "Apple", calories: "100", protein: "1",
            trackCalories: true, trackProtein: true) == false)
    }

    @Test func untrackedMetricIsNotRequired() {
        // Protein untracked → a blank protein field must not block the add.
        #expect(EntryValidator.isAdditionDisabled(
            item: "Apple", calories: "100", protein: "",
            trackCalories: true, trackProtein: false) == false)
    }

    @Test func nonNumericTrackedCaloriesIsDisabled() {
        #expect(EntryValidator.isAdditionDisabled(
            item: "Apple", calories: "lots", protein: "1",
            trackCalories: true, trackProtein: true) == true)
    }
}

@Suite("Progress bar geometry")
struct NutrientBarTests {
    @Test func fillIsClampedToOne() {
        #expect(NutrientBar.fillFraction(current: 300, limit: 100) == 1.0)
    }

    @Test func partialFillIsProportional() {
        #expect(NutrientBar.fillFraction(current: 50, limit: 100) == 0.5)
    }

    @Test func nonPositiveLimitFillsNothing() {
        #expect(NutrientBar.fillFraction(current: 10, limit: 0) == 0)
    }
}

@Suite("Entry grouping")
struct EntryGroupingTests {
    private func entry(_ category: MealCategory) -> Entry {
        Entry(item: "x", calories: 0, protein: 0, fruitVeg: 0, category: category)
    }

    @Test func presentCategoriesAreInMealOrderAndOnlyNonEmpty() {
        let entries = [entry(.dinner), entry(.breakfast)]
        #expect(EntryGrouping.presentCategories(in: entries) == [.breakfast, .dinner])
    }

    @Test func groupsByCategory() {
        let entries = [entry(.lunch), entry(.lunch), entry(.dinner)]
        let grouped = EntryGrouping.byCategory(entries)
        #expect(grouped[.lunch]?.count == 2)
        #expect(grouped[.dinner]?.count == 1)
    }
}
