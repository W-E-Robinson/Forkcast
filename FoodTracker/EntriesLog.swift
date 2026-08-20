import SwiftUI
import Foundation
import SwiftData

let statusBarCornerRadius: CGFloat = 9

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
                    Color.gray.opacity(0.15)

                    LinearGradient(
                        colors: [color.opacity(0.75), color],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: max(fill, 0))
                }
                .frame(height: barHeight)
                .clipShape(RoundedRectangle(cornerRadius: statusBarCornerRadius))
                .shadow(color: color.opacity(fill > 0 ? 0.35 : 0), radius: 3, y: 1)

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

    @AppStorage("targetCalories") private var calorieLimit = 2000
    @AppStorage("targetProtein") private var proteinTarget = 120
    @AppStorage("targetFruitVeg") private var fruitVegTarget = 5

    @AppStorage("trackCalories") private var trackCalories = true
    @AppStorage("trackProtein") private var trackProtein = true
    @AppStorage("trackFruitVeg") private var trackFruitVeg = true
    
    struct EntryDisplay: View {
        @Environment(\.modelContext) private var context

        @AppStorage("trackCalories") private var trackCalories = true
        @AppStorage("trackProtein") private var trackProtein = true

        let id: UUID
        let item: String
        let calories: Int
        let protein: Int
        let fruitVeg: Int
        let category: MealCategory

        @State private var showingDeleteConfirmation = false

        private func removeEntry(
            id: UUID
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
                RoundedRectangle(cornerRadius: 2)
                    .fill(category.color)
                    .frame(width: 4)

                Text(item)
                Spacer()
                if trackCalories {
                    Text("🍽️ \(calories)")
                }
                if trackProtein {
                    Text("🥩 \(protein)")
                }
                if fruitVeg > 0 {
                    Text("🥕 \(fruitVeg)")
                }

                ZStack(alignment: .trailing) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showingDeleteConfirmation = true
                        }
                    } label: {
                        Image(systemName: "trash")
                            .foregroundStyle(.red)
                    }
                    .buttonStyle(.plain)
                    .opacity(showingDeleteConfirmation ? 0 : 1)

                    if showingDeleteConfirmation {
                        Button {
                            removeEntry(id: id)
                        } label: {
                            Text("Sure?")
                                .font(.caption.bold())
                                .foregroundStyle(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.red)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                    }
                }
            }
            .padding(
                [.bottom],
                5
            )
            .contentShape(Rectangle())
            .onTapGesture {
                if showingDeleteConfirmation {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showingDeleteConfirmation = false
                    }
                }
            }
        }
    }

    private var entriesByCategory: [MealCategory: [Entry]] {
        Dictionary(grouping: entries, by: \.category)
    }

    private var categories: [MealCategory] {
        MealCategory.allCases.filter { category in
            entries.contains { $0.category == category }
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

    private var totalFruitVeg: Int {
        entries
            .reduce(
                0
            ) {
                $0 + $1.fruitVeg
            }
    }

    private var proteinBarColor: Color {
        if totalProtein < 70 {
            return .red
        }
        if totalProtein < 100 {
            return Color(red: 1.0, green: 0.75, blue: 0.0)
        }
        return .green
    }

    private var fruitVegBarColor: Color {
        guard fruitVegTarget > 0 else { return .green }
        let ratio = Double(totalFruitVeg) / Double(fruitVegTarget)
        if ratio < 0.8 {
            return .red
        }
        if ratio < 1.0 {
            return Color(red: 1.0, green: 0.75, blue: 0.0)
        }
        return .green
    }

    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 12) {
                if trackCalories {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            Text("🍽️ Calories")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("\(totalCalories)")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                        NutrientProgressBar(
                            current: totalCalories,
                            limit: calorieLimit,
                            limitLabel: "\(calorieLimit)",
                            color: totalCalories <= calorieLimit ? .green : .red
                        )
                    }
                }

                if trackProtein {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            Text("🥩 Protein")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("\(totalProtein)")
                                .font(.footnote)
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

                if trackFruitVeg {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            Text("🥕 Fruit & Veg")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("\(totalFruitVeg)")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                        NutrientProgressBar(
                            current: totalFruitVeg,
                            limit: fruitVegTarget,
                            limitLabel: "\(fruitVegTarget)",
                            color: fruitVegBarColor
                        )
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)

            Divider()

            List {
                ForEach(categories) { category in
                    Section {
                        ForEach(
                            entriesByCategory[category] ?? [],
                            id: \.id
                        ) { entry in
                            EntryDisplay(
                                id: entry.id,
                                item: entry.item,
                                calories: entry.calories,
                                protein: entry.protein,
                                fruitVeg: entry.fruitVeg,
                                category: entry.category
                            )
                        }
                    } header: {
                        Text(category.rawValue)
                            .foregroundStyle(category.color)
                    }
                }
            }
            .listSectionSpacing(.compact)
        }
    }
}
