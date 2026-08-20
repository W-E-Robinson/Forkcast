import SwiftUI

private struct TargetStepperRow: View {
    let emoji: String
    let label: String
    @Binding var value: Int
    let step: Int
    let range: ClosedRange<Int>
    let color: Color
    @Binding var isTracked: Bool

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("\(emoji) \(label)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Spacer()
                Toggle("Track \(label)", isOn: $isTracked)
                    .labelsHidden()
                    .tint(color)
            }

            HStack(spacing: 20) {
                Button {
                    value = max(range.lowerBound, value - step)
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 30))
                }
                .buttonStyle(.plain)
                .foregroundStyle(color)

                Text("\(value)")
                    .font(.title2.bold())
                    .monospacedDigit()
                    .frame(minWidth: 90)

                Button {
                    value = min(range.upperBound, value + step)
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 30))
                }
                .buttonStyle(.plain)
                .foregroundStyle(color)
            }
            .disabled(!isTracked)
            .opacity(isTracked ? 1 : 0.35)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: statusBarCornerRadius)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

struct TargetSetupView: View {
    @Binding var targetCalories: Int
    @Binding var targetProtein: Int
    @Binding var targetFruitVeg: Int
    @Binding var trackCalories: Bool
    @Binding var trackProtein: Bool
    @Binding var trackFruitVeg: Bool
    let onConfirm: () -> Void

    @State private var calories: Int
    @State private var protein: Int
    @State private var fruitVeg: Int
    @State private var caloriesTracked: Bool
    @State private var proteinTracked: Bool
    @State private var fruitVegTracked: Bool

    init(
        targetCalories: Binding<Int>,
        targetProtein: Binding<Int>,
        targetFruitVeg: Binding<Int>,
        trackCalories: Binding<Bool>,
        trackProtein: Binding<Bool>,
        trackFruitVeg: Binding<Bool>,
        onConfirm: @escaping () -> Void
    ) {
        self._targetCalories = targetCalories
        self._targetProtein = targetProtein
        self._targetFruitVeg = targetFruitVeg
        self._trackCalories = trackCalories
        self._trackProtein = trackProtein
        self._trackFruitVeg = trackFruitVeg
        self.onConfirm = onConfirm
        self._calories = State(initialValue: targetCalories.wrappedValue)
        self._protein = State(initialValue: targetProtein.wrappedValue)
        self._fruitVeg = State(initialValue: targetFruitVeg.wrappedValue)
        self._caloriesTracked = State(initialValue: trackCalories.wrappedValue)
        self._proteinTracked = State(initialValue: trackProtein.wrappedValue)
        self._fruitVegTracked = State(initialValue: trackFruitVeg.wrappedValue)
    }

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer()

                VStack(spacing: 6) {
                    Text("Set Today's Targets")
                        .font(.title2.bold())
                }

                VStack(spacing: 16) {
                    TargetStepperRow(
                        emoji: "🍽️",
                        label: "Calories",
                        value: $calories,
                        step: 100,
                        range: 100...10000,
                        color: .orange,
                        isTracked: $caloriesTracked
                    )
                    TargetStepperRow(
                        emoji: "🥩",
                        label: "Protein",
                        value: $protein,
                        step: 10,
                        range: 10...500,
                        color: .blue,
                        isTracked: $proteinTracked
                    )
                    TargetStepperRow(
                        emoji: "🥕",
                        label: "Fruit & Veg",
                        value: $fruitVeg,
                        step: 1,
                        range: 1...20,
                        color: .green,
                        isTracked: $fruitVegTracked
                    )
                }
                .frame(maxWidth: 280)

                Button {
                    targetCalories = calories
                    targetProtein = protein
                    targetFruitVeg = fruitVeg
                    trackCalories = caloriesTracked
                    trackProtein = proteinTracked
                    trackFruitVeg = fruitVegTracked
                    onConfirm()
                } label: {
                    Text("Confirm")
                        .fontWeight(.semibold)
                        .frame(maxWidth: 200)
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
                .controlSize(.large)

                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    TargetSetupView(
        targetCalories: .constant(2000),
        targetProtein: .constant(120),
        targetFruitVeg: .constant(5),
        trackCalories: .constant(true),
        trackProtein: .constant(true),
        trackFruitVeg: .constant(true),
        onConfirm: {}
    )
}
