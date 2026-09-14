import SwiftUI
import SwiftData

private struct InputBarTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: statusBarCornerRadius)
                    .fill(Color(.secondarySystemBackground))
            )
    }
}

private extension TextFieldStyle where Self == InputBarTextFieldStyle {
    static var inputBar: InputBarTextFieldStyle { InputBarTextFieldStyle() }
}

struct EntryInput: View {
    @Environment(\.modelContext) private var context

    @AppStorage("trackCalories") private var trackCalories = true
    @AppStorage("trackProtein") private var trackProtein = true
    @AppStorage("trackFruitVeg") private var trackFruitVeg = true

    @State private var itemToAdd = ""
    @State private var caloriesToAdd = ""
    @State private var proteinToAdd = ""
    @State private var fruitVegToAdd = 0
    @State private var categoryToAdd: MealCategory = .breakfast

    private enum Field {
        case item, calories, protein
    }

    @FocusState private var focusedField: Field?

    private func addEntry(
        item: String,
        calories: Int,
        protein: Int,
        fruitVeg: Int,
        category: MealCategory
    ) -> Void {
        let newEntry = Entry(
            item: item ,
            calories: calories ,
            protein: protein,
            fruitVeg: fruitVeg,
            category: category
        )
        context.insert(newEntry)
    }

    private func handleAddButtonClick(
        item: String,
        calories: String,
        protein: String,
        fruitVeg: Int,
        category: MealCategory
    ) -> Void {
        addEntry(
            item: item,
            calories: Int(calories) ?? 0,
            protein: Int(protein) ?? 0,
            fruitVeg: fruitVeg,
            category: category
        )
        itemToAdd = ""
        caloriesToAdd = ""
        proteinToAdd = ""
        fruitVegToAdd = 0
    }
    
    private func isAdditionDisabled(
        item: String,
        calories: String,
        protein: String
    ) -> Bool{
        EntryValidator.isAdditionDisabled(
            item: item,
            calories: calories,
            protein: protein,
            trackCalories: trackCalories,
            trackProtein: trackProtein
        )
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
            .tint(categoryToAdd.color)
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
                .textFieldStyle(.inputBar)

                if trackCalories {
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
                    .textFieldStyle(.inputBar)
                }

                if trackProtein {
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
                    .textFieldStyle(.inputBar)
                }

                if trackFruitVeg {
                    HStack(spacing: 20) {
                        Button {
                            fruitVegToAdd = max(0, fruitVegToAdd - 1)
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .font(.system(size: 28))
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(categoryToAdd.color)
                        .disabled(fruitVegToAdd == 0)
                        .opacity(fruitVegToAdd == 0 ? 0.3 : 1)

                        Text("🥕 \(fruitVegToAdd)")
                            .font(.body.monospacedDigit())
                            .frame(minWidth: 80)

                        Button {
                            fruitVegToAdd += 1
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 28))
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(categoryToAdd.color)
                    }
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: statusBarCornerRadius)
                            .fill(Color(.secondarySystemBackground))
                    )
                }
            }
            .tint(categoryToAdd.color)
            .frame(maxWidth: 280)

            Button(
                action: {
                    focusedField = nil
                    handleAddButtonClick(
                        item: itemToAdd,
                        calories: caloriesToAdd,
                        protein: proteinToAdd,
                        fruitVeg: fruitVegToAdd,
                        category: categoryToAdd
                    )
                }
            ) {
                Text("Add")
                    .fontWeight(.semibold)
                    .frame(maxWidth: 200)
            }
            .buttonStyle(.borderedProminent)
            .tint(categoryToAdd.color)
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
