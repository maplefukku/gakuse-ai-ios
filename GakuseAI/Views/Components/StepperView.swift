import SwiftUI

// MARK: - Stepper View Component

struct StepperView: View {
    @Binding var value: Int
    let range: ClosedRange<Int>
    let step: Int
    let label: String?
    let icon: String?
    let iconColor: Color
    let onValueChange: ((Int) -> Void)?
    let style: StepperStyle
    @State private var isPressedPlus = false
    @State private var isPressedMinus = false

    enum StepperStyle {
        case standard
        case compact
        case minimal
    }

    init(
        value: Binding<Int>,
        range: ClosedRange<Int> = 0...100,
        step: Int = 1,
        label: String? = nil,
        icon: String? = nil,
        iconColor: Color = .pink,
        onValueChange: ((Int) -> Void)? = nil,
        style: StepperStyle = .standard
    ) {
        self._value = value
        self.range = range
        self.step = step
        self.label = label
        self.icon = icon
        self.iconColor = iconColor
        self.onValueChange = onValueChange
        self.style = style
    }

    var body: some View {
        Group {
            if let label = label {
                stepperRow
            } else {
                stepperCompact
            }
        }
        .drawingGroup() // パフォーマンス最適化
    }

    private var stepperRow: some View {
        HStack(spacing: 12) {
            if let icon = icon {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .font(.title3)
            }

            Text(label!)
                .font(.subheadline)
                .foregroundColor(.primary)

            Spacer()

            stepperCompact
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }

    private var stepperCompact: some View {
        HStack(spacing: 8) {
            minusButton

            Text("\(value)")
                .font(style.valueFont)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .frame(minWidth: style.valueWidth)

            plusButton
        }
    }

    private var minusButton: some View {
        Button(action: decrement) {
            ZStack {
                Circle()
                    .fill(canDecrement ? style.buttonColor : Color(UIColor.systemGray4))
                    .frame(width: style.buttonSize, height: style.buttonSize)

                Image(systemName: "minus")
                    .font(.caption)
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
            }
        }
        .disabled(!canDecrement)
        .buttonStyle(.plain)
        .scaleEffect(isPressedMinus ? 0.9 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressedMinus)
        .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
            withAnimation {
                isPressedMinus = pressing
            }
        }, perform: {})
        .accessibilityLabel("減らす")
        .accessibilityHint("\(step)減らします")
    }

    private var plusButton: some View {
        Button(action: increment) {
            ZStack {
                Circle()
                    .fill(canIncrement ? style.buttonColor : Color(UIColor.systemGray4))
                    .frame(width: style.buttonSize, height: style.buttonSize)

                Image(systemName: "plus")
                    .font(.caption)
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
            }
        }
        .disabled(!canIncrement)
        .buttonStyle(.plain)
        .scaleEffect(isPressedPlus ? 0.9 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressedPlus)
        .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
            withAnimation {
                isPressedPlus = pressing
            }
        }, perform: {})
        .accessibilityLabel("増やす")
        .accessibilityHint("\(step)増やします")
    }

    private var canDecrement: Bool {
        value - step >= range.lowerBound
    }

    private var canIncrement: Bool {
        value + step <= range.upperBound
    }

    private func increment() {
        guard canIncrement else { return }
        withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
            value += step
        }
        onValueChange?(value)
    }

    private func decrement() {
        guard canDecrement else { return }
        withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
            value -= step
        }
        onValueChange?(value)
    }
}

// MARK: - Stepper Style Configuration

extension StepperView.StepperStyle {
    var buttonSize: CGFloat {
        switch self {
        case .standard: return 36
        case .compact: return 32
        case .minimal: return 28
        }
    }

    var buttonColor: Color {
        switch self {
        case .standard: return .pink
        case .compact: return .pink
        case .minimal: return .pink
        }
    }

    var valueFont: Font {
        switch self {
        case .standard: return .title3
        case .compact: return .subheadline
        case .minimal: return .caption
        }
    }

    var valueWidth: CGFloat {
        switch self {
        case .standard: return 40
        case .compact: return 36
        case .minimal: return 32
        }
    }
}

// MARK: - Minimal Stepper (Icon Only)

struct MinimalStepper: View {
    @Binding var value: Int
    let range: ClosedRange<Int>
    let step: Int
    let onValueChange: ((Int) -> Void)?
    @State private var isPressedPlus = false
    @State private var isPressedMinus = false

    init(
        value: Binding<Int>,
        range: ClosedRange<Int> = 0...100,
        step: Int = 1,
        onValueChange: ((Int) -> Void)? = nil
    ) {
        self._value = value
        self.range = range
        self.step = step
        self.onValueChange = onValueChange
    }

    var body: some View {
        HStack(spacing: 16) {
            Button(action: decrement) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(canDecrement ? .pink : Color(UIColor.systemGray3))
            }
            .disabled(!canDecrement)
            .buttonStyle(.plain)
            .scaleEffect(isPressedMinus ? 0.9 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressedMinus)
            .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
                withAnimation {
                    isPressedMinus = pressing
                }
            }, perform: {})

            Text("\(value)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .frame(width: 50)

            Button(action: increment) {
                Image(systemName: "chevron.right")
                    .font(.title2)
                    .foregroundColor(canIncrement ? .pink : Color(UIColor.systemGray3))
            }
            .disabled(!canIncrement)
            .buttonStyle(.plain)
            .scaleEffect(isPressedPlus ? 0.9 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressedPlus)
            .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
                withAnimation {
                    isPressedPlus = pressing
                }
            }, perform: {})
        }
        .drawingGroup() // パフォーマンス最適化
        .accessibilityElement(children: .contain)
        .accessibilityLabel("ステッパー")
        .accessibilityValue("\(value)")
    }

    private var canDecrement: Bool {
        value - step >= range.lowerBound
    }

    private var canIncrement: Bool {
        value + step <= range.upperBound
    }

    private func increment() {
        guard canIncrement else { return }
        withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
            value += step
        }
        onValueChange?(value)
    }

    private func decrement() {
        guard canDecrement else { return }
        withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
            value -= step
        }
        onValueChange?(value)
    }
}

// MARK: - Preview

#Preview("Stepper View - Standard") {
    VStack(spacing: 16) {
        StepperView(
            value: .constant(5),
            range: 0...10,
            label: "数量",
            icon: "cube.fill",
            iconColor: .blue
        )

        StepperView(
            value: .constant(2),
            range: 1...5,
            label: "優先度",
            icon: "star.fill",
            iconColor: .orange
        )

        StepperView(
            value: .constant(30),
            range: 0...60,
            step: 5,
            label: "時間 (分)",
            icon: "clock.fill",
            iconColor: .green
        )
    }
    .padding()
}

#Preview("Stepper View - Compact") {
    VStack(spacing: 16) {
        StepperView(
            value: .constant(3),
            range: 0...10,
            label: "数量",
            style: .compact
        )

        StepperView(
            value: .constant(1),
            range: 1...5,
            label: "優先度",
            style: .compact
        )
    }
    .padding()
}

#Preview("Stepper View - Minimal") {
    VStack(spacing: 16) {
        StepperView(
            value: .constant(5),
            range: 0...10,
            label: "数量",
            style: .minimal
        )

        StepperView(
            value: .constant(2),
            range: 1...5,
            label: "優先度",
            style: .minimal
        )
    }
    .padding()
}

#Preview("Stepper View - No Label") {
    VStack(spacing: 16) {
        HStack {
            Text("数量")
                .font(.subheadline)
            Spacer()
            StepperView(value: .constant(5))
        }

        HStack {
            Text("優先度")
                .font(.subheadline)
            Spacer()
            StepperView(value: .constant(2), range: 1...5)
        }
    }
    .padding()
}

#Preview("Minimal Stepper") {
    VStack(spacing: 16) {
        HStack {
            Text("数量")
                .font(.subheadline)
            Spacer()
            MinimalStepper(value: .constant(5))
        }

        HStack {
            Text("優先度")
                .font(.subheadline)
            Spacer()
            MinimalStepper(value: .constant(2), range: 1...5)
        }

        HStack {
            Text("時間 (分)")
                .font(.subheadline)
            Spacer()
            MinimalStepper(value: .constant(30), range: 0...60, step: 5)
        }
    }
    .padding()
}

#Preview("Stepper View - Edge Cases") {
    VStack(spacing: 16) {
        StepperView(
            value: .constant(0),
            range: 0...10,
            label: "最小値",
            icon: "arrow.down.fill",
            iconColor: .red
        )

        StepperView(
            value: .constant(10),
            range: 0...10,
            label: "最大値",
            icon: "arrow.up.fill",
            iconColor: .green
        )
    }
    .padding()
}
