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

struct ContentView: View {
    @Environment(\.modelContext) private var context
    
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
        TabView{
            EntriesLog()
            EntryInput()
        }.task{
            deleteEntriesFromPreviousDays()
            scheduleRebuildReminder()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Entry.self, inMemory: true)
}
