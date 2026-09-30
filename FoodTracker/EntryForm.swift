import SwiftUI

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

enum EntryField {
    case item, calories, protein
}

/// The category picker plus the nutrient fields, shared by the add tab and the
/// edit sheet so both flows look and validate the same way.
struct EntryFormFields: View {
    @AppStorage("trackCalories") private var trackCalories = true
    @AppStorage("trackProtein") private var trackProtein = true
    @AppStorage("trackFruitVeg") private var trackFruitVeg = true

    @Binding var draft: EntryDraft
    @FocusState.Binding var focusedField: EntryField?

    var body: some View {
        VStack(spacing: 24) {
            Picker("Category", selection: $draft.category) {
                ForEach(MealCategory.allCases) { category in
                    Text(category.rawValue).tag(category)
                }
            }
            .pickerStyle(.menu)
            .tint(draft.category.color)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(Color(.secondarySystemBackground))
            )

            VStack(spacing: 14) {
                TextField(
                    "Add Item",
                    text: $draft.item
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
                        text: $draft.calories
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
                        text: $draft.protein
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
                            draft.fruitVeg = max(0, draft.fruitVeg - 1)
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .font(.system(size: 28))
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(draft.category.color)
                        .disabled(draft.fruitVeg == 0)
                        .opacity(draft.fruitVeg == 0 ? 0.3 : 1)

                        Text("🥕 \(draft.fruitVeg)")
                            .font(.body.monospacedDigit())
                            .frame(minWidth: 80)

                        Button {
                            draft.fruitVeg += 1
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 28))
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(draft.category.color)
                    }
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: statusBarCornerRadius)
                            .fill(Color(.secondarySystemBackground))
                    )
                }
            }
            .tint(draft.category.color)
            .frame(maxWidth: 280)
        }
    }
}
