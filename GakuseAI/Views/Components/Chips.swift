//
//  Chips.swift
//  GakuseAI
//
//  Created by fe-dev-2 on 2026-03-09.
//

import SwiftUI

// MARK: - Basic Chip
struct Chip: View {
    let text: String
    var style: ChipStyle = .standard
    var isSelected: Bool = false
    var isRemovable: Bool = false
    var onTap: (() -> Void)? = nil
    var onRemove: (() -> Void)? = nil

    @State private var isPressed: Bool = false

    var body: some View {
        HStack(spacing: style == .minimal ? 4 : 6) {
            Text(text)
                .font(style.font)
                .foregroundColor(isSelected ? style.selectedTextColor : style.textColor)
                .lineLimit(1)

            if isRemovable {
                Button(action: {
                    onRemove?()
                    // タップフィードバック
                    let feedback = UIImpactFeedbackGenerator(style: .light)
                    feedback.impactOccurred()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(isSelected ? style.selectedRemoveIconColor : style.removeIconColor)
                        .font(.system(size: 14))
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(style == .minimal ? .horizontal(8) : .horizontal(12), style == .minimal ? .vertical(4) : .vertical(6))
        .background(isSelected ? style.selectedBackgroundColor : style.backgroundColor)
        .cornerRadius(style.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: style.cornerRadius)
                .stroke(style.borderColor, lineWidth: style.borderWidth)
        )
        .shadow(color: style.shadowColor, radius: style.shadowRadius, x: 0, y: style.shadowYOffset)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .onTapGesture {
            onTap?()
            // タップフィードバック
            let feedback = UISelectionFeedbackGenerator()
            feedback.selectionChanged()
        }
        .pressEvents(
            onPressBegin: { isPressed = true },
            onPressEnd: { isPressed = false }
        )
        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isSelected)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(text)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityRole(isRemovable ? .button : .none)
    }
}

// MARK: - Toggle Chip
struct ToggleChip: View {
    let text: String
    var style: ChipStyle = .standard
    @Binding var isSelected: Bool

    var body: some View {
        Chip(
            text: text,
            style: style,
            isSelected: isSelected,
            onTap: {
                isSelected.toggle()
            }
        )
    }
}

// MARK: - Chip Row (Horizontal Scroll)
struct ChipRow: View {
    let chips: [String]
    var style: ChipStyle = .standard
    @Binding var selectedChip: String?
    var spacing: CGFloat = 8
    var isRemovable: Bool = false
    var onRemove: ((String) -> Void)? = nil

    @State private var scrollOffset: CGFloat = 0

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: spacing) {
                ForEach(chips, id: \.self) { chip in
                    Chip(
                        text: chip,
                        style: style,
                        isSelected: selectedChip == chip,
                        isRemovable: isRemovable,
                        onTap: {
                            withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                                selectedChip = chip
                            }
                        },
                        onRemove: isRemovable ? {
                            onRemove?(chip)
                        } : nil
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .background(Color.clear)
        .drawingGroup()
    }
}

// MARK: - Chip Grid
struct ChipGrid: View {
    let chips: [String]
    var style: ChipStyle = .standard
    @Binding var selectedChips: Set<String>
    var columns: Int = 2
    var spacing: CGFloat = 8
    var isRemovable: Bool = false
    var onRemove: ((String) -> Void)? = nil

    private let adaptiveColumns = [
        GridItem(.adaptive(minimum: 80), spacing: 8)
    ]

    var body: some View {
        LazyVGrid(columns: adaptiveColumns, spacing: spacing) {
            ForEach(chips, id: \.self) { chip in
                Chip(
                    text: chip,
                    style: style,
                    isSelected: selectedChips.contains(chip),
                    isRemovable: isRemovable,
                    onTap: {
                        withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                            if selectedChips.contains(chip) {
                                selectedChips.remove(chip)
                            } else {
                                selectedChips.insert(chip)
                            }
                        }
                    },
                    onRemove: isRemovable ? {
                        onRemove?(chip)
                    } : nil
                )
            }
        }
        .padding(16)
        .drawingGroup()
    }
}

// MARK: - Filter Chip (Icon + Text)
struct FilterChip: View {
    let icon: String
    let text: String
    var style: ChipStyle = .standard
    var isSelected: Bool = false
    var onTap: (() -> Void)? = nil

    @State private var isPressed: Bool = false

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundColor(isSelected ? style.selectedTextColor : style.textColor)
                .font(.system(size: 12))

            Text(text)
                .font(style.font)
                .foregroundColor(isSelected ? style.selectedTextColor : style.textColor)
                .lineLimit(1)
        }
        .padding(.horizontal(10), .vertical(6))
        .background(isSelected ? style.selectedBackgroundColor : style.backgroundColor)
        .cornerRadius(style.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: style.cornerRadius)
                .stroke(style.borderColor, lineWidth: style.borderWidth)
        )
        .shadow(color: style.shadowColor, radius: style.shadowRadius, x: 0, y: style.shadowYOffset)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .onTapGesture {
            onTap?()
            let feedback = UISelectionFeedbackGenerator()
            feedback.selectionChanged()
        }
        .pressEvents(
            onPressBegin: { isPressed = true },
            onPressEnd: { isPressed = false }
        )
        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isSelected)
    }
}

// MARK: - Chip Style
enum ChipStyle {
    case standard
    case elevated
    case outlined
    case minimal
    case pill

    var font: Font {
        switch self {
        case .standard:
            return .system(size: 14, weight: .medium)
        case .elevated:
            return .system(size: 15, weight: .semibold)
        case .outlined:
            return .system(size: 14, weight: .medium)
        case .minimal:
            return .system(size: 13, weight: .regular)
        case .pill:
            return .system(size: 14, weight: .semibold)
        }
    }

    var backgroundColor: Color {
        switch self {
        case .standard:
            return Color(.systemGray6)
        case .elevated:
            return Color(.systemBackground)
        case .outlined:
            return Color(.systemBackground)
        case .minimal:
            return Color.clear
        case .pill:
            return Color(.systemGray5)
        }
    }

    var selectedBackgroundColor: Color {
        switch self {
        case .standard:
            return Color(.systemBlue)
        case .elevated:
            return Color(.systemBlue)
        case .outlined:
            return Color(.systemBlue)
        case .minimal:
            return Color(.systemBlue)
        case .pill:
            return Color(.systemBlue)
        }
    }

    var textColor: Color {
        switch self {
        case .standard:
            return Color(.label)
        case .elevated:
            return Color(.label)
        case .outlined:
            return Color(.label)
        case .minimal:
            return Color(.secondaryLabel)
        case .pill:
            return Color(.label)
        }
    }

    var selectedTextColor: Color {
        return Color(.white)
    }

    var borderColor: Color {
        switch self {
        case .standard:
            return Color.clear
        case .elevated:
            return Color(.systemGray4)
        case .outlined:
            return Color(.systemGray4)
        case .minimal:
            return Color(.systemGray4)
        case .pill:
            return Color.clear
        }
    }

    var borderWidth: CGFloat {
        switch self {
        case .standard:
            return 0
        case .elevated:
            return 1
        case .outlined:
            return 1
        case .minimal:
            return 1
        case .pill:
            return 0
        }
    }

    var cornerRadius: CGFloat {
        switch self {
        case .standard:
            return 8
        case .elevated:
            return 10
        case .outlined:
            return 8
        case .minimal:
            return 4
        case .pill:
            return 16
        }
    }

    var shadowColor: Color {
        switch self {
        case .standard:
            return Color.black.opacity(0.0)
        case .elevated:
            return Color.black.opacity(0.05)
        case .outlined:
            return Color.black.opacity(0.0)
        case .minimal:
            return Color.black.opacity(0.0)
        case .pill:
            return Color.black.opacity(0.03)
        }
    }

    var shadowRadius: CGFloat {
        switch self {
        case .standard:
            return 0
        case .elevated:
            return 4
        case .outlined:
            return 0
        case .minimal:
            return 0
        case .pill:
            return 2
        }
    }

    var shadowYOffset: CGFloat {
        switch self {
        case .standard:
            return 0
        case .elevated:
            return 2
        case .outlined:
            return 0
        case .minimal:
            return 0
        case .pill:
            return 1
        }
    }

    var removeIconColor: Color {
        switch self {
        case .standard:
            return Color(.systemGray)
        case .elevated:
            return Color(.systemGray)
        case .outlined:
            return Color(.systemGray)
        case .minimal:
            return Color(.systemGray)
        case .pill:
            return Color(.systemGray)
        }
    }

    var selectedRemoveIconColor: Color {
        return Color.white.opacity(0.8)
    }
}

// MARK: - Press Events Modifier
struct PressEventsModifier: ViewModifier {
    var onPressBegin: () -> Void
    var onPressEnd: () -> Void

    @State private var isPressed = false

    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isPressed {
                            isPressed = true
                            onPressBegin()
                        }
                    }
                    .onEnded { _ in
                        isPressed = false
                        onPressEnd()
                    }
            )
    }
}

extension View {
    func pressEvents(
        onPressBegin: @escaping () -> Void = {},
        onPressEnd: @escaping () -> Void = {}
    ) -> some View {
        modifier(PressEventsModifier(onPressBegin: onPressBegin, onPressEnd: onPressEnd))
    }
}

// MARK: - SwiftUI Previews
#Preview("Basic Chips") {
    VStack(spacing: 20) {
        // Standard Chips
        HStack(spacing: 8) {
            Chip(text: "SwiftUI")
            Chip(text: "iOS", style: .elevated)
            Chip(text: "Python", style: .outlined)
            Chip(text: "JavaScript", style: .minimal)
            Chip(text: "Go", style: .pill)
        }

        // Selected Chips
        HStack(spacing: 8) {
            Chip(text: "SwiftUI", isSelected: true)
            Chip(text: "iOS", style: .elevated, isSelected: true)
            Chip(text: "Python", style: .outlined, isSelected: true)
        }

        // Removable Chips
        HStack(spacing: 8) {
            Chip(text: "Tag 1", isRemovable: true)
            Chip(text: "Tag 2", isRemovable: true)
            Chip(text: "Tag 3", isRemovable: true)
        }
    }
    .padding()
}

#Preview("Toggle Chips") {
    VStack(spacing: 20) {
        HStack(spacing: 8) {
            ToggleChip(text: "Option A", style: .standard, isSelected: .constant(true))
            ToggleChip(text: "Option B", style: .standard, isSelected: .constant(false))
            ToggleChip(text: "Option C", style: .standard, isSelected: .constant(false))
        }

        HStack(spacing: 8) {
            ToggleChip(text: "Option A", style: .pill, isSelected: .constant(true))
            ToggleChip(text: "Option B", style: .pill, isSelected: .constant(false))
        }
    }
    .padding()
}

#Preview("Chip Row") {
    ChipRow(
        chips: ["SwiftUI", "iOS", "Python", "JavaScript", "Go", "Rust", "Kotlin", "Flutter"],
        selectedChip: .constant("SwiftUI"),
        isRemovable: false
    )
}

#Preview("Chip Row with Remove") {
    ChipRow(
        chips: ["Tag 1", "Tag 2", "Tag 3", "Tag 4", "Tag 5"],
        selectedChip: .constant("Tag 1"),
        isRemovable: true,
        onRemove: { chip in
            print("Remove: \(chip)")
        }
    )
}

#Preview("Chip Grid") {
    ChipGrid(
        chips: ["SwiftUI", "iOS", "Python", "JavaScript", "Go", "Rust", "Kotlin", "Flutter", "React", "Vue"],
        selectedChips: .constant(["SwiftUI", "iOS"]),
        columns: 2,
        isRemovable: false
    )
}

#Preview("Filter Chips") {
    VStack(spacing: 20) {
        HStack(spacing: 8) {
            FilterChip(icon: "flame", text: "Hot", isSelected: true)
            FilterChip(icon: "clock", text: "Recent", isSelected: false)
            FilterChip(icon: "star", text: "Popular", isSelected: false)
        }

        HStack(spacing: 8) {
            FilterChip(icon: "heart", text: "Favorite", style: .pill, isSelected: true)
            FilterChip(icon: "bookmark", text: "Saved", style: .pill, isSelected: false)
        }
    }
    .padding()
}
