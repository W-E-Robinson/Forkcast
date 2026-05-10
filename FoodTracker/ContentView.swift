import SwiftUI
import Foundation
import SwiftData

@Model
class Entry: Identifiable {
    var id = UUID()
    var date = Date()
    var item: String
    var calories: Int
    var protein: Int
    
    init(item: String, calories: Int, protein: Int) {
        self.item = item
        self.calories = calories
        self.protein = protein
    }
}

struct ContentView: View {
    @Environment(\.modelContext) private var context
    
    private func deleteEntriesFromPreviousDays( ) -> Void{
        do {
            let today = Calendar.current.startOfDay(for: Date())
            
            let descriptor = FetchDescriptor<Entry>(
                predicate: #Predicate { entry in
                    entry.date < today
                }
            )
            
            let oldEntries = try context.fetch(descriptor)
            oldEntries.forEach { context.delete($0) }
            try context.save()
        } catch {
            print("Delete failed:", error)
        }
    }
    
    var body: some View {
        TabView{
            EntriesLog()
            EntryInput()
        }.task{
            deleteEntriesFromPreviousDays()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Entry.self, inMemory: true)
}
