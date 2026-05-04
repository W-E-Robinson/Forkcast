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
    @Query private var entries: [Entry]
    @Environment(\.modelContext) private var context
    
    @State private var itemToAdd = ""
    @State private var caloriesToAdd = ""
    @State private var proteinToAdd = ""
    
    struct FoodDisplay: View {
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
                    "\(item) -"
                )
                Text(
                    "calories: \(calories)"
                )
                Text(
                    "protein: \(protein)"
                )
                Button("Remove") {
                    removeEntry(id: id)
                }
            }
            .padding(
                [.bottom],
                5
            )
        }
    }
    
    private func addEntry(
        item: String,
        calories: Int,
        protein: Int
    ) -> Void {
        let newEntry = Entry(
            item: item ,
            calories: calories ,
            protein: protein
        )
        context.insert(newEntry)
    }
    
    private func handleAddButtonClick(
        item: String,
        calories: String,
        protein: String
    ) -> Void {
        addEntry(
            item: item,
            calories: Int(calories) ?? 0,
            protein: Int(protein) ?? 0,
        )
        itemToAdd = ""
        caloriesToAdd = ""
        proteinToAdd = ""
    }
    
    private func isAdditionDisabled(
        item: String,
        calories: String,
        protein: String
    ) -> Bool{
        if (item.isEmpty){
            return true
        }
        if (calories.isEmpty || Int(calories) == nil){
            return true
        }
        if (protein.isEmpty || Int(protein) == nil){
            return true
        }
        return false
    }
    
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
                "Total - calories: \(totalCalories) protein \(totalProtein)"
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
                        FoodDisplay(
                            id: entry.id,
                            item: entry.item,
                            calories: entry.calories,
                            protein: entry.protein
                        )
                    }
                }
            }
            
            Divider()
            
            TextField(
                "Add Item",
                text: $itemToAdd
            )
            .autocorrectionDisabled()
            .multilineTextAlignment(
                .center
            )
            
            TextField(
                "Add Calories",
                text: $caloriesToAdd
            )
            .autocorrectionDisabled()
            .multilineTextAlignment(
                .center
            )
            
            TextField(
                "Add Protein",
                text: $proteinToAdd
            )
            .autocorrectionDisabled()
            .multilineTextAlignment(
                .center
            )
            
            Divider()
            
            Button(
                "Add",
                action: {
                    handleAddButtonClick(
                        item: itemToAdd,
                        calories: caloriesToAdd,
                        protein: proteinToAdd,
                    )
                })
            .disabled(
                isAdditionDisabled(item: itemToAdd, calories: caloriesToAdd, protein: proteinToAdd)
            )
            // NOTE: will this being at bottom muck with pop up keyboard? = yeah a little bit
        }.task{
            deleteEntriesFromPreviousDays()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Entry.self, inMemory: true)
}
