import SwiftUI
import SwiftData

struct EntryInput: View {
    @Environment(\.modelContext) private var context

    @AppStorage("trackCalories") private var trackCalories = true
    @AppStorage("trackProtein") private var trackProtein = true

    @State private var draft = EntryDraft()

    @FocusState private var focusedField: EntryField?

    private func handleAddButtonClick() -> Void {
        EntryStore.addEntry(draft, in: context)
        draft = EntryDraft(category: draft.category)
    }

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            EntryFormFields(draft: $draft, focusedField: $focusedField)

            Button(
                action: {
                    focusedField = nil
                    handleAddButtonClick()
                }
            ) {
                Text("Add")
                    .fontWeight(.semibold)
                    .frame(maxWidth: 200)
            }
            .buttonStyle(.borderedProminent)
            .tint(draft.category.color)
            .controlSize(.large)
            .disabled(
                draft.isSaveDisabled(trackCalories: trackCalories, trackProtein: trackProtein)
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
