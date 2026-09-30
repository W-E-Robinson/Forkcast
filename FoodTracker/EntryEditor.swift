import SwiftUI
import SwiftData

/// Sheet for changing an entry that's already in the log. Edits are held in a
/// draft and only written back to SwiftData when Save is tapped.
struct EntryEditor: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @AppStorage("trackCalories") private var trackCalories = true
    @AppStorage("trackProtein") private var trackProtein = true

    let id: UUID

    @State private var draft: EntryDraft
    @FocusState private var focusedField: EntryField?

    init(id: UUID, draft: EntryDraft) {
        self.id = id
        _draft = State(initialValue: draft)
    }

    private func saveEntry() -> Void {
        do {
            try EntryStore.updateEntry(id: id, to: draft, in: context)
        } catch {
            print("Update failed:", error)
        }
        dismiss()
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                EntryFormFields(draft: $draft, focusedField: $focusedField)

                Spacer()
            }
            .padding(.top, 24)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .onTapGesture {
                focusedField = nil
            }
            .navigationTitle("Edit Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        focusedField = nil
                        saveEntry()
                    }
                    .fontWeight(.semibold)
                    .disabled(
                        draft.isSaveDisabled(trackCalories: trackCalories, trackProtein: trackProtein)
                    )
                }
            }
            .tint(draft.category.color)
        }
        .presentationDetents([.medium, .large])
    }
}
