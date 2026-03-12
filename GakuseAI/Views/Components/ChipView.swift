//
//  ChipView.swift
//  GakuseAI
//
//  Created by fe-dev-2 on 2026-03-10.
//

import SwiftUI

/// チップコンポーネント（選択可能なタグ）
///
/// 複数のスタイルを提供するタグ/チップUIコンポーネント
///
/// ## 使用例
/// ```swift
/// ChipView(
///     text: "タグ",
///     isSelected: $isSelected,
///     style: .standard
/// )
/// ```
public struct ChipView: View {

    // MARK: - プロパティ

    /// チップテキスト
    private let text: String

    /// 選択状態
    @Binding private var isSelected: Bool

    /// スタイル
    private let style: ChipStyle

    /// アイコン（オプション）
    private let icon: Image?

    /// アイコン位置
    private let iconPosition: IconPosition

    /// カラースキーム
    private let colorScheme: ChipColorScheme

    /// 選択時のコールバック
    private let onTap: (() -> Void)?

    /// 削除可能かどうか
    private let isRemovable: Bool

    /// 削除時のコールバック
    private let onRemove: (() -> Void)?

    // MARK: - 初期化

    /// 標準初期化
    /// - Parameters:
    ///   - text: チップテキスト
    ///   - isSelected: 選択状態
    ///   - style: スタイル
    ///   - icon: アイコン（オプション）
    ///   - iconPosition: アイコン位置（デフォルト: .leading）
    ///   - colorScheme: カラースキーム（デフォルト: .primary）
    ///   - onTap: 選択時のコールバック
    ///   - isRemovable: 削除可能かどうか（デフォルト: false）
    ///   - onRemove: 削除時のコールバック
    public init(
        text: String,
        isSelected: Binding<Bool>,
        style: ChipStyle = ChipStyle.standard,
        icon: Image? = nil,
        iconPosition: IconPosition = .leading,
        colorScheme: ChipColorScheme = ChipColorScheme.primary,
        onTap: (() -> Void)? = nil,
        isRemovable: Bool = false,
        onRemove: (() -> Void)? = nil
    ) {
        self.text = text
        self._isSelected = isSelected
        self.style = style
        self.icon = icon
        self.iconPosition = iconPosition
        self.colorScheme = colorScheme
        self.onTap = onTap
        self.isRemovable = isRemovable
        self.onRemove = onRemove
    }
    
    // MARK: - ボディ
    
    public var body: some View {
        Group {
            switch style {
            case .standard:
                standardChip
            case .filled:
                filledChip
            case .outlined:
                outlinedChip
            case .minimal:
                minimalChip
            case .pill:
                pillChip
            case .rounded:
                roundedChip
            }
        }
        .drawingGroup()
    }
    
    // MARK: - サブビュー
    
    /// 標準スタイルチップ
    private var standardChip: some View {
        HStack(spacing: 6) {
            if iconPosition == .leading, let icon = icon {
                icon
                    .font(.system(size: 14))
            }

            Text(text)
                .font(.system(size: 14, weight: .medium))

            if iconPosition == .trailing, let icon = icon {
                icon
                    .font(.system(size: 14))
            }

            // 削除ボタン
            if isRemovable {
                Button(action: {
                    onRemove?()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.secondary)
                        .frame(width: 16, height: 16)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, isRemovable ? 12 : 14)
        .padding(.vertical, 8)
        .background(isSelected ? colorScheme.selectedBackgroundColor : colorScheme.backgroundColor)
        .foregroundColor(isSelected ? colorScheme.selectedTextColor : colorScheme.textColor)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(colorScheme.borderColor, lineWidth: isSelected ? 0 : 1)
        )
        .shadow(color: colorScheme.shadowColor, radius: isSelected ? 2 : 0, x: 0, y: 1)
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isSelected.toggle()
            }
            onTap?()
        }
    }
    
    /// 塗りつぶしスタイルチップ
    private var filledChip: some View {
        HStack(spacing: 6) {
            if iconPosition == .leading, let icon = icon {
                icon
                    .font(.system(size: 14))
            }

            Text(text)
                .font(.system(size: 14, weight: .semibold))

            if iconPosition == .trailing, let icon = icon {
                icon
                    .font(.system(size: 14))
            }

            // 削除ボタン
            if isRemovable {
                Button(action: {
                    onRemove?()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.secondary)
                        .frame(width: 16, height: 16)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, isRemovable ? 14 : 16)
        .padding(.vertical, 10)
        .background(isSelected ? colorScheme.selectedBackgroundColor : colorScheme.backgroundColor)
        .foregroundColor(isSelected ? colorScheme.selectedTextColor : colorScheme.textColor)
        .cornerRadius(20)
        .shadow(color: colorScheme.shadowColor, radius: isSelected ? 3 : 1, x: 0, y: 2)
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isSelected.toggle()
            }
            onTap?()
        }
    }
    
    /// アウトラインスタイルチップ
    private var outlinedChip: some View {
        HStack(spacing: 6) {
            if iconPosition == .leading, let icon = icon {
                icon
                    .font(.system(size: 14))
            }

            Text(text)
                .font(.system(size: 14, weight: .medium))

            if iconPosition == .trailing, let icon = icon {
                icon
                    .font(.system(size: 14))
            }

            // 削除ボタン
            if isRemovable {
                Button(action: {
                    onRemove?()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.secondary)
                        .frame(width: 16, height: 16)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, isRemovable ? 12 : 14)
        .padding(.vertical, 8)
        .background(Color.clear)
        .foregroundColor(isSelected ? colorScheme.selectedTextColor : colorScheme.textColor)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? colorScheme.selectedBackgroundColor : colorScheme.borderColor, lineWidth: 2)
        )
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isSelected.toggle()
            }
            onTap?()
        }
    }
    
    /// ミニマルスタイルチップ
    private var minimalChip: some View {
        HStack(spacing: 6) {
            if iconPosition == .leading, let icon = icon {
                icon
                    .font(.system(size: 12))
            }

            Text(text)
                .font(.system(size: 13))

            if iconPosition == .trailing, let icon = icon {
                icon
                    .font(.system(size: 12))
            }

            // 削除ボタン
            if isRemovable {
                Button(action: {
                    onRemove?()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.secondary)
                        .frame(width: 14, height: 14)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, isRemovable ? 8 : 10)
        .padding(.vertical, 5)
        .background(isSelected ? colorScheme.selectedBackgroundColor.opacity(0.1) : Color.clear)
        .foregroundColor(isSelected ? colorScheme.selectedTextColor : colorScheme.textColor)
        .cornerRadius(4)
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isSelected.toggle()
            }
            onTap?()
        }
    }
    
    /// ピルスタイルチップ
    private var pillChip: some View {
        HStack(spacing: 6) {
            if iconPosition == .leading, let icon = icon {
                icon
                    .font(.system(size: 14))
            }

            Text(text)
                .font(.system(size: 14, weight: .medium))

            if iconPosition == .trailing, let icon = icon {
                icon
                    .font(.system(size: 14))
            }

            // 削除ボタン
            if isRemovable {
                Button(action: {
                    onRemove?()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.secondary)
                        .frame(width: 16, height: 16)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, isRemovable ? 16 : 18)
        .padding(.vertical, 9)
        .background(isSelected ? colorScheme.selectedBackgroundColor : colorScheme.backgroundColor)
        .foregroundColor(isSelected ? colorScheme.selectedTextColor : colorScheme.textColor)
        .clipShape(Capsule())
        .shadow(color: colorScheme.shadowColor, radius: isSelected ? 2 : 0, x: 0, y: 1)
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isSelected.toggle()
            }
            onTap?()
        }
    }
    
    /// 丸角スタイルチップ
    private var roundedChip: some View {
        HStack(spacing: 6) {
            if iconPosition == .leading, let icon = icon {
                icon
                    .font(.system(size: 14))
            }

            Text(text)
                .font(.system(size: 14, weight: .medium))

            if iconPosition == .trailing, let icon = icon {
                icon
                    .font(.system(size: 14))
            }

            // 削除ボタン
            if isRemovable {
                Button(action: {
                    onRemove?()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.secondary)
                        .frame(width: 16, height: 16)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, isRemovable ? 12 : 14)
        .padding(.vertical, 8)
        .background(isSelected ? colorScheme.selectedBackgroundColor : colorScheme.backgroundColor)
        .foregroundColor(isSelected ? colorScheme.selectedTextColor : colorScheme.textColor)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(colorScheme.borderColor, lineWidth: isSelected ? 0 : 1)
        )
        .shadow(color: colorScheme.shadowColor, radius: isSelected ? 2 : 0, x: 0, y: 1)
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isSelected.toggle()
            }
            onTap?()
        }
    }
}

// MARK: - ChipStyle

/// チップスタイル
public enum ChipStyle {
    case standard      // 標準
    case filled        // 塗りつぶし
    case outlined      // アウトライン
    case minimal       // ミニマル
    case pill          // ピル
    case rounded       // 丸角
}

// MARK: - IconPosition

/// アイコン位置
public enum IconPosition {
    case leading       // 左側
    case trailing      // 右側
}

// MARK: - ChipColorScheme

/// チップカラースキーム
public enum ChipColorScheme {
    case primary       // プライマリ
    case secondary     // セカンダリ
    case success       // 成功
    case warning       // 警告
    case error         // エラー
    case custom(Color) // カスタム
    
    var backgroundColor: Color {
        switch self {
        case .primary:
            return Color(.systemGray6)
        case .secondary:
            return Color.purple.opacity(0.1)
        case .success:
            return Color.green.opacity(0.1)
        case .warning:
            return Color.orange.opacity(0.1)
        case .error:
            return Color.red.opacity(0.1)
        case .custom(let color):
            return color.opacity(0.1)
        }
    }
    
    var selectedBackgroundColor: Color {
        switch self {
        case .primary:
            return .blue
        case .secondary:
            return .purple
        case .success:
            return .green
        case .warning:
            return .orange
        case .error:
            return .red
        case .custom(let color):
            return color
        }
    }
    
    var textColor: Color {
        switch self {
        case .primary:
            return .primary
        case .secondary:
            return .purple
        case .success:
            return .green
        case .warning:
            return .orange
        case .error:
            return .red
        case .custom(let color):
            return color
        }
    }
    
    var selectedTextColor: Color {
        switch self {
        case .primary, .secondary, .success, .warning, .error:
            return .white
        case .custom(_):
            return .white
        }
    }
    
    var borderColor: Color {
        switch self {
        case .primary:
            return Color(.systemGray4)
        case .secondary:
            return Color.purple.opacity(0.3)
        case .success:
            return Color.green.opacity(0.3)
        case .warning:
            return Color.orange.opacity(0.3)
        case .error:
            return Color.red.opacity(0.3)
        case .custom(let color):
            return color.opacity(0.3)
        }
    }
    
    var shadowColor: Color {
        switch self {
        case .primary, .secondary:
            return Color.black.opacity(0.1)
        case .success:
            return Color.green.opacity(0.2)
        case .warning:
            return Color.orange.opacity(0.2)
        case .error:
            return Color.red.opacity(0.2)
        case .custom(let color):
            return color.opacity(0.2)
        }
    }
}

// MARK: - SimpleChip

/// シンプル版チップ
public struct SimpleChip: View {
    @Binding private var isSelected: Bool
    private let text: String
    
    public init(
        text: String,
        isSelected: Binding<Bool>
    ) {
        self.text = text
        self._isSelected = isSelected
    }
    
    public var body: some View {
        ChipView(
            text: text,
            isSelected: $isSelected,
            style: .minimal
        )
    }
}

// MARK: - ChipGroup

/// チップグループ（複数のチップを管理）
public struct ChipGroup: View {
    
    // MARK: - プロパティ
    
    /// チップデータ
    private let chips: [ChipData]
    
    /// 選択されたチップ
    @Binding private var selectedChips: Set<String>
    
    /// 複数選択可能か
    private let allowsMultipleSelection: Bool
    
    /// スタイル
    private let style: ChipStyle
    
    /// カラースキーム
    private let colorScheme: ChipColorScheme
    
    /// 選択時のコールバック
    private let onChange: ((Set<String>) -> Void)?
    
    // MARK: - ChipData
    
    /// チップデータ
    public struct ChipData: Identifiable {
        public let id: String
        public let text: String
        public let icon: Image?
        
        public init(
            id: String,
            text: String,
            icon: Image? = nil
        ) {
            self.id = id
            self.text = text
            self.icon = icon
        }
    }
    
    // MARK: - 初期化
    
    public init(
        chips: [ChipData],
        selectedChips: Binding<Set<String>>,
        allowsMultipleSelection: Bool = true,
        style: ChipStyle = .standard,
        colorScheme: ChipColorScheme = .primary,
        onChange: ((Set<String>) -> Void)? = nil
    ) {
        self.chips = chips
        self._selectedChips = selectedChips
        self.allowsMultipleSelection = allowsMultipleSelection
        self.style = style
        self.colorScheme = colorScheme
        self.onChange = onChange
    }
    
    // MARK: - ボディ
    
    public var body: some View {
        LazyVGrid(
            columns: [
                GridItem(.adaptive(minimum: 80))
            ],
            spacing: 8
        ) {
            ForEach(chips) { chip in
                ChipView(
                    text: chip.text,
                    isSelected: Binding(
                        get: { selectedChips.contains(chip.id) },
                        set: { newValue in
                            if newValue {
                                if allowsMultipleSelection {
                                    selectedChips.insert(chip.id)
                                } else {
                                    selectedChips = [chip.id]
                                }
                            } else {
                                selectedChips.remove(chip.id)
                            }
                            onChange?(selectedChips)
                        }
                    ),
                    style: style,
                    icon: chip.icon,
                    colorScheme: colorScheme
                )
            }
        }
        .drawingGroup()
    }
}

// MARK: - Preview

#Preview("Standard") {
    ChipView(
        text: "タグ",
        isSelected: .constant(true),
        style: ChipStyle.standard
    )
}

#Preview("Filled") {
    ChipView(
        text: "タグ",
        isSelected: .constant(true),
        style: ChipStyle.filled
    )
}

#Preview("Outlined") {
    ChipView(
        text: "タグ",
        isSelected: .constant(true),
        style: ChipStyle.outlined
    )
}

#Preview("Minimal") {
    ChipView(
        text: "タグ",
        isSelected: .constant(false),
        style: ChipStyle.minimal
    )
}

#Preview("Pill") {
    ChipView(
        text: "タグ",
        isSelected: .constant(true),
        style: ChipStyle.pill
    )
}

#Preview("Rounded") {
    ChipView(
        text: "タグ",
        isSelected: .constant(true),
        style: ChipStyle.rounded
    )
}

#Preview("With Icon") {
    HStack(spacing: 16) {
        ChipView(
            text: "スタディ",
            isSelected: .constant(true),
            style: .standard,
            icon: Image(systemName: "book.fill"),
            iconPosition: .leading
        )
        
        ChipView(
            text: "仕事",
            isSelected: .constant(false),
            style: .filled,
            icon: Image(systemName: "briefcase.fill"),
            iconPosition: .trailing
        )
    }
}

#Preview("ChipGroup") {
    ChipGroup(
        chips: [
            ChipGroup.ChipData(id: "1", text: "SwiftUI", icon: Image(systemName: "swift")),
            ChipGroup.ChipData(id: "2", text: "iOS", icon: Image(systemName: "iphone")),
            ChipGroup.ChipData(id: "3", text: "Android", icon: Image(systemName: "android")),
            ChipGroup.ChipData(id: "4", text: "Web", icon: Image(systemName: "globe")),
            ChipGroup.ChipData(id: "5", text: "UI/UX", icon: Image(systemName: "paintbrush")),
            ChipGroup.ChipData(id: "6", text: "Backend", icon: Image(systemName: "server")),
        ],
        selectedChips: .constant(["1", "3"]),
        allowsMultipleSelection: true
    )
}

#Preview("Gallery") {
    ScrollView {
        VStack(spacing: 32) {
            Text("Chip Styles")
                .font(.title)
                .padding(.bottom)
            
            HStack(spacing: 12) {
                ChipView(text: "Standard", isSelected: .constant(true), style: .standard)
                ChipView(text: "Filled", isSelected: .constant(true), style: .filled)
                ChipView(text: "Outlined", isSelected: .constant(true), style: .outlined)
                ChipView(text: "Minimal", isSelected: .constant(false), style: .minimal)
                ChipView(text: "Pill", isSelected: .constant(true), style: .pill)
                ChipView(text: "Rounded", isSelected: .constant(true), style: .rounded)
            }
            
            Divider()
            
            Text("Color Schemes")
                .font(.title2)
                .padding(.bottom)
            
            VStack(spacing: 12) {
                ChipView(text: "Primary", isSelected: .constant(true), colorScheme: .primary)
                ChipView(text: "Secondary", isSelected: .constant(true), colorScheme: .secondary)
                ChipView(text: "Success", isSelected: .constant(true), colorScheme: .success)
                ChipView(text: "Warning", isSelected: .constant(true), colorScheme: .warning)
                ChipView(text: "Error", isSelected: .constant(true), colorScheme: .error)
            }
            
            Divider()
            
            Text("ChipGroup")
                .font(.title2)
                .padding(.bottom)
            
            ChipGroup(
                chips: [
                    ChipGroup.ChipData(id: "swift", text: "SwiftUI", icon: Image(systemName: "swift")),
                    ChipGroup.ChipData(id: "ios", text: "iOS", icon: Image(systemName: "iphone")),
                    ChipGroup.ChipData(id: "android", text: "Android", icon: Image(systemName: "android")),
                    ChipGroup.ChipData(id: "web", text: "Web", icon: Image(systemName: "globe")),
                    ChipGroup.ChipData(id: "ui", text: "UI/UX", icon: Image(systemName: "paintbrush")),
                    ChipGroup.ChipData(id: "backend", text: "Backend", icon: Image(systemName: "server")),
                    ChipGroup.ChipData(id: "database", text: "Database", icon: Image(systemName: "database")),
                    ChipGroup.ChipData(id: "api", text: "API", icon: Image(systemName: "cloud")),
                ],
                selectedChips: .constant(["swift", "ios", "web"]),
                allowsMultipleSelection: true
            )
        }
        .padding()
    }
}
