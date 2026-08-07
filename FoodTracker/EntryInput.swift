import SwiftUI
import SwiftData

struct EntryInput: View {
    @Environment(\.modelContext) private var context

    @State private var itemToAdd = ""
    @State private var caloriesToAdd = ""
    @State private var proteinToAdd = ""
    @State private var categoryToAdd: MealCategory = .breakfast

    private enum Field {
        case item, calories, protein
    }

    @FocusState private var focusedField: Field?
    
    private func addEntry(
        item: String,
        calories: Int,
        protein: Int,
        category: MealCategory
    ) -> Void {
        let newEntry = Entry(
            item: item ,
            calories: calories ,
            protein: protein,
            category: category
        )
        context.insert(newEntry)
    }

    private func handleAddButtonClick(
        item: String,
        calories: String,
        protein: String,
        category: MealCategory
    ) -> Void {
        addEntry(
            item: item,
            calories: Int(calories) ?? 0,
            protein: Int(protein) ?? 0,
            category: category
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
        VStack(spacing: 24) {
            Spacer()

            Picker("Category", selection: $categoryToAdd) {
                ForEach(MealCategory.allCases) { category in
                    Text(category.rawValue).tag(category)
                }
            }
            .pickerStyle(.menu)
            .tint(.primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(Color(.secondarySystemBackground))
            )

            VStack(spacing: 14) {
                TextField(
                    "Add Item",
                    text: $itemToAdd
                )
                .textInputAutocapitalization(.words)
                .multilineTextAlignment(
                    .center
                )
                .focused($focusedField, equals: .item)
                .submitLabel(.next)
                .onSubmit {
                    focusedField = .calories
                }
                .textFieldStyle(.roundedBorder)

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
                .textFieldStyle(.roundedBorder)

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
                .textFieldStyle(.roundedBorder)
            }
            .frame(maxWidth: 280)

            Button(
                action: {
                    focusedField = nil
                    handleAddButtonClick(
                        item: itemToAdd,
                        calories: caloriesToAdd,
                        protein: proteinToAdd,
                        category: categoryToAdd
                    )
                }
            ) {
                Text("Add")
                    .fontWeight(.semibold)
                    .frame(maxWidth: 200)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(
                isAdditionDisabled(item: itemToAdd, calories: caloriesToAdd, protein: proteinToAdd)
            )

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            focusedField = nil
        }
    }
}
