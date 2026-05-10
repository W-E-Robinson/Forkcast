import SwiftUI
import Foundation
import SwiftData

struct EntriesLog: View {
    @Query private var entries: [Entry]
    @Environment(\.modelContext) private var context
    
    struct EntryDisplay: View {
        @Environment(\.modelContext) private var context
        
        let id: UUID
        let item: String
        let calories: Int
        let protein: Int
        
        private func removeEntry(
            id: UUID,
        ) -> Void {
            do {
                let descriptor = FetchDescriptor<Entry>(
                    predicate: #Predicate { entry in
                        entry.id == id
                    }
                )
                
                let oldEntries = try context.fetch(descriptor)
                oldEntries.forEach { context.delete($0) }
                try context.save()
            } catch {
                print("Removal failed:", error)
            }
        }
        
        var body: some View {
            HStack {
                Text(
                    "\(item),"
                )
                Text(
                    "calories: \(calories)"
                )
                Text(
                    "protein: \(protein)"
                )
                Button("—") {
                    removeEntry(id: id)
                }
            }
            .padding(
                [.bottom],
                5
            )
        }
    }
    
    private var totalCalories: Int {
        entries
            .reduce(
                0
            ) {
                $0 + $1.calories
            }
    }
    
    private var totalProtein: Int {
        entries
            .reduce(
                0
            ) {
                $0 + $1.protein
            }
    }
    
    var body: some View {
        VStack{
            Text(
                "Total, calories: \(totalCalories) protein: \(totalProtein)"
            )
            
            Divider()
            
            ScrollView(
                .vertical,
                showsIndicators: false
            ) {
                VStack {
                    ForEach(
                        entries,
                        id: \.id
                    ) { entry in
                        EntryDisplay(
                            id: entry.id,
                            item: entry.item,
                            calories: entry.calories,
                            protein: entry.protein
                        )
                    }
                }
            }
        }
    }
}
