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
    var category: MealCategory

    init(item: String, calories: Int, protein: Int, category: MealCategory) {
        self.item = item
        self.calories = calories
        self.protein = protein
        self.category = category
    }
}

let calorieLimit = 2000

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @Query private var entries: [Entry]

    private var totalCalories: Int {
        entries.reduce(0) { $0 + $1.calories }
    }

    private var calorieStatusColor: Color {
        totalCalories <= calorieLimit ? .green : .red
    }

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

    private func scheduleRebuildReminder() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
            guard granted else { return }

            let content = UNMutableNotificationContent()
            content.title = "Forkcast"
            content.body = "Re build app"
            content.sound = .default

            var dateComponents = DateComponents()
            dateComponents.weekday = 2 // Monday
            dateComponents.hour = 7
            dateComponents.minute = 00

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(identifier: "weeklyRebuildReminder", content: content, trigger: trigger)
            center.add(request)
        }
    }
    
    var body: some View {
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
        .task {
            deleteEntriesFromPreviousDays()
            scheduleRebuildReminder()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Entry.self, inMemory: true)
}
