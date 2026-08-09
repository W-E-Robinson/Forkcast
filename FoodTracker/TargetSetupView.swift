import SwiftUI

private struct TargetStepperRow: View {
    let emoji: String
    let label: String
    @Binding var value: Int
    let step: Int
    let range: ClosedRange<Int>
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Text("\(emoji) \(label)")
                .font(.footnote)
                .foregroundStyle(.secondary)

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
    let onConfirm: () -> Void

    @State private var calories: Int
    @State private var protein: Int

    init(targetCalories: Binding<Int>, targetProtein: Binding<Int>, onConfirm: @escaping () -> Void) {
        self._targetCalories = targetCalories
        self._targetProtein = targetProtein
        self.onConfirm = onConfirm
        self._calories = State(initialValue: targetCalories.wrappedValue)
        self._protein = State(initialValue: targetProtein.wrappedValue)
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
                        color: .orange
                    )
                    TargetStepperRow(
                        emoji: "🥩",
                        label: "Protein",
                        value: $protein,
                        step: 10,
                        range: 10...500,
                        color: .blue
                    )
                }
                .frame(maxWidth: 280)

                Button {
                    targetCalories = calories
                    targetProtein = protein
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
    TargetSetupView(targetCalories: .constant(2000), targetProtein: .constant(120), onConfirm: {})
}
