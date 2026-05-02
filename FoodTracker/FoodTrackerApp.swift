import SwiftUI
import SwiftData

@main
struct FoodTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Entry.self)
    }
}
