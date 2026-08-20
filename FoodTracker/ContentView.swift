import SwiftUI
import Foundation
import SwiftData

enum MealCategory: String, Codable, CaseIterable, Identifiable {
    case breakfast = "Breakfast"
    case morningSnack = "Morning Snack"
    case lunch = "Lunch"
    case afternoonSnack = "Afternoon Snack"
    case dinner = "Dinner"

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .breakfast: return .orange
        case .morningSnack: return .teal
        case .lunch: return .blue
        case .afternoonSnack: return .mint
        case .dinner: return .purple
        }
    }
}

@Model
class Entry: Identifiable {
    var id = UUID()
    var date = Date()
    var item: String
    var calories: Int
    var protein: Int
    var fruitVeg: Int = 0
    var category: MealCategory

    init(item: String, calories: Int, protein: Int, fruitVeg: Int, category: MealCategory) {
        self.item = item
        self.calories = calories
        self.protein = protein
        self.fruitVeg = fruitVeg
        self.category = category
    }
}

private let launchEmojis = ["🍎", "🍕", "🍔", "🥑", "🍩", "🍗", "🍜", "🍇", "🥕", "🍉", "🍓", "🌽"]

private struct FloatingEmojiColumn: View {
    let emojis: [String]
    let rowHeight: CGFloat
    let rowCount: Int
    let duration: Double
    let movingUp: Bool

    @State private var offsetY: CGFloat = 0

    private var loopHeight: CGFloat { CGFloat(rowCount) * rowHeight }

    private func emoji(at index: Int) -> String {
        emojis[index % emojis.count]
    }

    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<(rowCount * 2), id: \.self) { index in
                Text(emoji(at: index))
                    .font(.system(size: rowHeight * 0.6))
                    .frame(height: rowHeight)
            }
        }
        .offset(y: offsetY)
        .onAppear {
            offsetY = movingUp ? 0 : -loopHeight
            withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                offsetY = movingUp ? -loopHeight : 0
            }
        }
    }
}

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @Query private var entries: [Entry]

    @AppStorage("targetCalories") private var targetCalories = 2000
    @AppStorage("targetProtein") private var targetProtein = 120
    @AppStorage("targetFruitVeg") private var targetFruitVeg = 5

    @AppStorage("trackCalories") private var trackCalories = true
    @AppStorage("trackProtein") private var trackProtein = true
    @AppStorage("trackFruitVeg") private var trackFruitVeg = true

    private var totalCalories: Int {
        entries.reduce(0) { $0 + $1.calories }
    }

    private var calorieStatusColor: Color {
        guard trackCalories else { return .orange }
        return totalCalories <= targetCalories ? .green : .red
    }

    @State private var showLaunchAnimation = true
    @State private var showTargetSetup = false
    @State private var launchIconScale: CGFloat = 0.6
    @State private var launchIconOpacity: Double = 0
    @State private var launchTitleOpacity: Double = 0

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

    var body: some View {
        ZStack {
            TabView {
                EntriesLog()
                    .tabItem {
                        Label("Log", systemImage: "fork.knife")
                    }
                EntryInput()
                    .tabItem {
                        Label("Add", systemImage: "plus.circle.fill")
                    }
            }
            .tint(calorieStatusColor)
            .opacity(showLaunchAnimation || showTargetSetup ? 0 : 1)
            .task {
                deleteEntriesFromPreviousDays()
            }

            if showTargetSetup {
                TargetSetupView(
                    targetCalories: $targetCalories,
                    targetProtein: $targetProtein,
                    targetFruitVeg: $targetFruitVeg,
                    trackCalories: $trackCalories,
                    trackProtein: $trackProtein,
                    trackFruitVeg: $trackFruitVeg,
                    onConfirm: {
                        withAnimation(.easeOut(duration: 0.4)) {
                            showTargetSetup = false
                        }
                    }
                )
                .transition(.opacity)
            }

            if showLaunchAnimation {
                launchOverlay
            }
        }
    }

    private func rotatedEmojis(by amount: Int) -> [String] {
        let count = launchEmojis.count
        let shift = ((amount % count) + count) % count
        return Array(launchEmojis[shift...] + launchEmojis[..<shift])
    }

    private var emojiBackground: some View {
        GeometryReader { geo in
            let rowHeight: CGFloat = 46
            let rowCount = Int(ceil(geo.size.height / rowHeight)) + 1
            let columnCount = 6
            let columnWidth = geo.size.width / CGFloat(columnCount)

            HStack(spacing: 0) {
                ForEach(0..<columnCount, id: \.self) { column in
                    FloatingEmojiColumn(
                        emojis: rotatedEmojis(by: column * 2),
                        rowHeight: rowHeight,
                        rowCount: rowCount,
                        duration: Double(14 + column * 3),
                        movingUp: column % 2 == 0
                    )
                    .frame(width: columnWidth)
                }
            }
        }
        .opacity(0.16)
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }

    private var launchOverlay: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            emojiBackground

            VStack(spacing: 12) {
                Image(systemName: "fork.knife.circle.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(.orange)
                    .scaleEffect(launchIconScale)
                    .opacity(launchIconOpacity)

                Text("Forkcast")
                    .font(.title2.bold())
                    .opacity(launchTitleOpacity)
            }
        }
        .transition(.opacity)
        .onAppear {
            withAnimation(.spring(response: 1.1, dampingFraction: 0.6)) {
                launchIconScale = 1.0
                launchIconOpacity = 1
            }
            withAnimation(.easeIn(duration: 0.8).delay(0.5)) {
                launchTitleOpacity = 1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.1) {
                withAnimation(.easeOut(duration: 0.8)) {
                    showLaunchAnimation = false
                    showTargetSetup = entries.isEmpty
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Entry.self, inMemory: true)
}
