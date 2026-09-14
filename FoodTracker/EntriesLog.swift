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
            let fill = NutrientBar.fillFraction(current: current, limit: limit) * width

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
                try EntryStore.deleteEntry(id: id, in: context)
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
        EntryGrouping.byCategory(entries)
    }

    private var categories: [MealCategory] {
        EntryGrouping.presentCategories(in: entries)
    }

    private var totals: DailyTotals {
        DailyTotals(entries)
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
                            Text("\(totals.calories)")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                        NutrientProgressBar(
                            current: totals.calories,
                            limit: calorieLimit,
                            limitLabel: "\(calorieLimit)",
                            color: CalorieStatus.forTotal(totals.calories, target: calorieLimit).color
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
                            Text("\(totals.protein)")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                        NutrientProgressBar(
                            current: totals.protein,
                            limit: proteinTarget,
                            limitLabel: "\(proteinTarget)",
                            color: NutrientStatus.forRatio(current: totals.protein, target: proteinTarget).color
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
                            Text("\(totals.fruitVeg)")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                        NutrientProgressBar(
                            current: totals.fruitVeg,
                            limit: fruitVegTarget,
                            limitLabel: "\(fruitVegTarget)",
                            color: NutrientStatus.forRatio(current: totals.fruitVeg, target: fruitVegTarget).color
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
