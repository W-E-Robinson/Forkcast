<h1 align="center">Forkcast</h1>

<p align="center">
<img width="90" height="86" alt="forkcast_logo" src="https://github.com/user-attachments/assets/8ee6fb27-5f54-47cd-b157-9f7093358af9" />
</p>

A simple app to track calories, protein, and fruit & veg intake when on a cut. Log food for Breakfast, Morning Snack, Lunch, Afternoon Snack, and Dinner. On app start, any data from previous days is removed.

## Features
- 🍳 Colour coded meal sections: Breakfast, Morning Snack, Lunch, Afternoon Snack, Dinner.
- 🔥 Live calorie, protein & fruit and veg bars that shift colour as you close in on targets.
- 🌙 Auto resets each day, no manual cleanup required.
- 🎯 Confirm your targets at the start of each day (when app is opened with no data inputted yet).
- 🥦 Fruit & veg portion tracking, with every metric optional, track only the ones you care about.
- ✏️ <b>Latest feature</b>: Edit any logged entry, tap the pencil on a row to change its item, numbers, or meal.

## Video
<div align="center">
  <video
    src="https://github.com/user-attachments/assets/832731aa-8693-4846-a9f2-e8c087f4b34c"
    controls
    alt="Demo video of the Forkcast app"
  </video>
</div>

## Testing

Run the full suite from the repo root:

```bash
make test
```

Tests live in `FoodTrackerTests/` and use [Swift Testing](https://developer.apple.com/documentation/testing):

- `DomainLogicTests.swift` covers the pure logic in `FoodTracker/Domain.swift`, the status colour bands, daily totals, entry validation and drafts, progress bar geometry, and meal grouping. No simulator state, no database.
- `PersistenceTests.swift` covers the SwiftData operations (daily reset, entry creation, editing, and deletion) against an in-memory container, so nothing touches disk.

## Run it on your iPhone

Requires Xcode 26.4+ and a device on iOS 26.4+.

1. Open `FoodTracker.xcodeproj`.
2. Under the **FoodTracker** target → **Signing & Capabilities**, select your own team and change the bundle identifier to something unique.
3. Pick your connected iPhone as the destination and hit Run (`⌘R`).

Or pick a simulator and skip step 2.
