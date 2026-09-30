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

    @Test func updateEntryOverwritesOnlyThatEntrysFields() throws {
        let context = try makeContext()
        let target = Entry(item: "Toast", calories: 200, protein: 6, fruitVeg: 0, category: .breakfast)
        let other = Entry(item: "Apple", calories: 80, protein: 0, fruitVeg: 1, category: .lunch)
        context.insert(target)
        context.insert(other)

        try EntryStore.updateEntry(
            id: target.id,
            to: EntryDraft(item: "Toast & Jam", calories: "260", protein: "7", fruitVeg: 1, category: .morningSnack),
            in: context
        )

        let updated = try #require(
            try context.fetch(FetchDescriptor<Entry>()).first { $0.id == target.id }
        )
        #expect(updated.item == "Toast & Jam")
        #expect(updated.calories == 260)
        #expect(updated.protein == 7)
        #expect(updated.fruitVeg == 1)
        #expect(updated.category == .morningSnack)
        #expect(other.item == "Apple")
        #expect(other.calories == 80)
    }

    @Test func updateEntryKeepsIdAndDate() throws {
        let context = try makeContext()
        let entry = Entry(item: "Toast", calories: 200, protein: 6, fruitVeg: 0, category: .breakfast)
        let originalDate = Date(timeIntervalSince1970: 1_700_000_000)
        entry.date = originalDate
        context.insert(entry)

        try EntryStore.updateEntry(
            id: entry.id,
            to: EntryDraft(item: "Bagel", calories: "300", protein: "9", fruitVeg: 0, category: .breakfast),
            in: context
        )

        let stored = try #require(try context.fetch(FetchDescriptor<Entry>()).first)
        #expect(stored.id == entry.id)
        #expect(stored.date == originalDate)
    }

    @Test func addEntryCoercesDraftNumbers() throws {
        let context = try makeContext()

        EntryStore.addEntry(
            EntryDraft(item: "Salad", calories: "150", protein: "", fruitVeg: 3, category: .lunch),
            in: context
        )
        try context.save()

        let stored = try #require(try context.fetch(FetchDescriptor<Entry>()).first)
        #expect(stored.item == "Salad")
        #expect(stored.calories == 150)
        #expect(stored.protein == 0)   // untracked/blank protein lands as zero
        #expect(stored.fruitVeg == 3)
        #expect(stored.category == .lunch)
    }

    @Test func fruitVegDefaultsToZero() throws {
        // Guards the SwiftData default that lets old entries migrate cleanly.
        let entry = Entry(item: "x", calories: 0, protein: 0, fruitVeg: 0, category: .dinner)
        #expect(entry.fruitVeg == 0)
    }
}
