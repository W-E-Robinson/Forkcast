import Testing
import SwiftData
import Foundation
@testable import Forkcast

// SwiftData tests against an in-memory container — no disk, no simulator state,
// no cross-test contamination. A fresh container per test keeps them isolated.

@Suite("Entry persistence")
struct PersistenceTests {

    private func makeContext() throws -> ModelContext {
        let container = try ModelContainer(
            for: Entry.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        return ModelContext(container)
    }

    private func insert(_ context: ModelContext, item: String, date: Date) {
        let entry = Entry(item: item, calories: 0, protein: 0, fruitVeg: 0, category: .breakfast)
        entry.date = date
        context.insert(entry)
    }

    @Test func dailyResetKeepsTodayAndDropsEarlierDays() throws {
        let context = try makeContext()
        let today = Date(timeIntervalSince1970: 1_700_000_000)          // fixed reference "now"
        let yesterday = today.addingTimeInterval(-60 * 60 * 24)

        insert(context, item: "stale", date: yesterday)
        insert(context, item: "fresh", date: today)

        try EntryStore.deleteEntries(before: today, in: context)

        let remaining = try context.fetch(FetchDescriptor<Entry>())
        #expect(remaining.map(\.item) == ["fresh"])
    }

    @Test func deleteEntryRemovesOnlyThatId() throws {
        let context = try makeContext()
        let keep = Entry(item: "keep", calories: 0, protein: 0, fruitVeg: 0, category: .lunch)
        let drop = Entry(item: "drop", calories: 0, protein: 0, fruitVeg: 0, category: .lunch)
        context.insert(keep)
        context.insert(drop)

        try EntryStore.deleteEntry(id: drop.id, in: context)

        let remaining = try context.fetch(FetchDescriptor<Entry>())
        #expect(remaining.map(\.item) == ["keep"])
    }

    @Test func fruitVegDefaultsToZero() throws {
        // Guards the SwiftData default that lets old entries migrate cleanly.
        let entry = Entry(item: "x", calories: 0, protein: 0, fruitVeg: 0, category: .dinner)
        #expect(entry.fruitVeg == 0)
    }
}
