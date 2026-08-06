import SwiftUI
import Foundation
import SwiftData

private struct NutrientProgressBar: View {
    let current: Int
    let limit: Int
    let limitLabel: String
    let color: Color

    private let barHeight: CGFloat = 18

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let fill = limit > 0
                ? min(CGFloat(current), CGFloat(limit)) / CGFloat(limit) * width
                : 0

            VStack(alignment: .trailing, spacing: 2) {
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: barHeight / 2)
                        .fill(Color.gray.opacity(0.2))

                    RoundedRectangle(cornerRadius: barHeight / 2)
                        .fill(color)
                        .frame(width: max(fill, 0))
                }
                .frame(height: barHeight)

                Text(limitLabel)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(height: barHeight + 14)
    }
}

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

    private let calorieLimit = 2000
    private let proteinTarget = 120

    private var proteinBarColor: Color {
        if totalProtein < 70 {
            return .red
        }
        if totalProtein < 100 {
            return Color(red: 1.0, green: 0.75, blue: 0.0)
        }
        return .green
    }

    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text("Calories")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("\(totalCalories)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    NutrientProgressBar(
                        current: totalCalories,
                        limit: calorieLimit,
                        limitLabel: "\(calorieLimit)",
                        color: totalCalories <= calorieLimit ? .green : .red
                    )
                }

                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text("Protein")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("\(totalProtein)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    NutrientProgressBar(
                        current: totalProtein,
                        limit: proteinTarget,
                        limitLabel: "\(proteinTarget)",
                        color: proteinBarColor
                    )
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)

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
