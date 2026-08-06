import SwiftUI
import SwiftData

struct EntryInput: View {
    @Environment(\.modelContext) private var context

    @State private var itemToAdd = ""
    @State private var caloriesToAdd = ""
    @State private var proteinToAdd = ""

    private enum Field {
        case item, calories, protein
    }

    @FocusState private var focusedField: Field?
    
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
    
    var body: some View {
        VStack {
            TextField(
                "Add Item",
                text: $itemToAdd
            )
            .autocorrectionDisabled()
            .multilineTextAlignment(
                .center
            )
            .focused($focusedField, equals: .item)
            .submitLabel(.next)
            .onSubmit {
                focusedField = .calories
            }

            TextField(
                "Add Calories",
                text: $caloriesToAdd
            )
            .autocorrectionDisabled()
            .keyboardType(.numberPad)
            .multilineTextAlignment(
                .center
            )
            .focused($focusedField, equals: .calories)

            TextField(
                "Add Protein",
                text: $proteinToAdd
            )
            .autocorrectionDisabled()
            .keyboardType(.numberPad)
            .multilineTextAlignment(
                .center
            )
            .focused($focusedField, equals: .protein)

            Divider()

            Button(
                "Add",
                action: {
                    focusedField = nil
                    handleAddButtonClick(
                        item: itemToAdd,
                        calories: caloriesToAdd,
                        protein: proteinToAdd,
                    )
                })
            .disabled(
                isAdditionDisabled(item: itemToAdd, calories: caloriesToAdd, protein: proteinToAdd)
            )

            Spacer()
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    focusedField = nil
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            focusedField = nil
        }
    }
}
