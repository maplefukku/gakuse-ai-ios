import SwiftUI

// MARK: - Search Bar Component

struct SearchBar: View {
    @Binding var text: String
    var placeholder: String = "検索"
    var prompt: String = "キーワードを入力..."
    @State private var isEditing = false
    @FocusState private var isFocused: Bool
    @State private var isPressed = false

    var body: some View {
        HStack(spacing: 12) {
            // Search Icon
            Image(systemName: "magnifyingglass")
                .foregroundColor(isFocused ? .pink : .secondary)
                .font(.title3)
                .frame(width: 20)

            // TextField
            TextField(placeholder, text: $text, prompt: Text(prompt))
                .focused($isFocused)
                .foregroundColor(.primary)
                .submitLabel(.search)
                .onSubmit {
                    isFocused = false
                }

            // Clear Button
            if !text.isEmpty {
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        text = ""
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                        .font(.title3)
                }
                .scaleEffect(isPressed ? 0.9 : 1.0)
                .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
                .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
                    withAnimation {
                        isPressed = pressing
                    }
                }, perform: {})
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.secondarySystemBackground))
                .shadow(
                    color: .black.opacity(isFocused ? 0.15 : 0.05),
                    radius: isFocused ? 8 : 4,
                    x: 0,
                    y: isFocused ? 2 : 1
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    isFocused ? Color.pink.opacity(0.3) : Color.clear,
                    lineWidth: 2
                )
        )
        .scaleEffect(isFocused ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isFocused)
        .drawingGroup() // パフォーマンス最適化: レイヤー合成を1回にまとめる
        .accessibilityIdentifier("searchBar")
        .accessibilityLabel("検索バー")
        .accessibilityHint("検索キーワードを入力できます")
    }
}

// MARK: - Advanced Search Bar Component

struct AdvancedSearchBar: View {
    @Binding var text: String
    @Binding var showAdvancedOptions: Bool
    var placeholder: String = "検索"
    @FocusState private var isFocused: Bool
    @State private var isPressed = false

    var body: some View {
        VStack(spacing: 12) {
            // Main Search Bar
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(isFocused ? .pink : .secondary)
                    .font(.title3)
                    .frame(width: 20)

                TextField(placeholder, text: $text)
                    .focused($isFocused)
                    .foregroundColor(.primary)
                    .submitLabel(.search)
                    .onSubmit {
                        isFocused = false
                    }

                if !text.isEmpty {
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            text = ""
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .font(.title3)
                    }
                    .scaleEffect(isPressed ? 0.9 : 1.0)
                    .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
                    .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
                        withAnimation {
                            isPressed = pressing
                        }
                    }, perform: {})
                    .transition(.scale.combined(with: .opacity))
                }

                // Advanced Options Toggle Button
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        showAdvancedOptions.toggle()
                    }
                } label: {
                    Image(systemName: "ellipsis.circle.fill")
                        .foregroundColor(.pink)
                        .font(.title3)
                }
                .scaleEffect(isPressed ? 0.9 : 1.0)
                .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
                .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
                    withAnimation {
                        isPressed = pressing
                    }
                }, perform: {})
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.secondarySystemBackground))
                    .shadow(
                        color: .black.opacity(isFocused ? 0.15 : 0.05),
                        radius: isFocused ? 8 : 4,
                        x: 0,
                        y: isFocused ? 2 : 1
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isFocused ? Color.pink.opacity(0.3) : Color.clear,
                        lineWidth: 2
                    )
            )
            .scaleEffect(isFocused ? 1.02 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isFocused)

            // Advanced Options
            if showAdvancedOptions {
                AdvancedSearchOptions()
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.95).combined(with: .opacity),
                        removal: .scale(scale: 0.95).combined(with: .opacity)
                    ))
            }
        }
        .drawingGroup() // パフォーマンス最適化: レイヤー合成を1回にまとめる
        .accessibilityIdentifier("advancedSearchBar")
        .accessibilityLabel("高度な検索バー")
        .accessibilityHint("高度な検索オプションを使用できます")
    }
}

// MARK: - Advanced Search Options

struct AdvancedSearchOptions: View {
    @State private var useAndOperator = false
    @State private var useOrOperator = false
    @State private var useNotOperator = false
    @State private var useRegex = false

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "line.3.horizontal.decrease.circle.fill")
                    .foregroundColor(.pink)
                Text("検索オプション")
                    .font(.headline)
                Spacer()
            }

            Divider()

            VStack(spacing: 12) {
                SearchOptionRow(
                    icon: "link",
                    title: "AND演算子",
                    description: "すべてのキーワードを含む",
                    isOn: $useAndOperator
                )

                SearchOptionRow(
                    icon: "arrow.triangle.branch",
                    title: "OR演算子",
                    description: "いずれかのキーワードを含む",
                    isOn: $useOrOperator
                )

                SearchOptionRow(
                    icon: "minus.circle",
                    title: "NOT演算子",
                    description: "キーワードを除外",
                    isOn: $useNotOperator
                )

                SearchOptionRow(
                    icon: "text.magnifyingglass",
                    title: "正規表現",
                    description: "高度な検索パターン",
                    isOn: $useRegex
                )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.secondarySystemBackground))
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
}

// MARK: - Search Option Row

struct SearchOptionRow: View {
    let icon: String
    let title: String
    let description: String
    @Binding var isOn: Bool
    @State private var isPressed = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.pink)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.primary)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(.pink)
                .scaleEffect(isPressed ? 0.9 : 1.0)
                .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
                .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
                    withAnimation {
                        isPressed = pressing
                    }
                }, perform: {})
        }
    }
}

// MARK: - Search History Component

struct SearchHistory: View {
    let history: [String]
    let onSelect: (String) -> Void
    let onClear: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("検索履歴")
                    .font(.headline)
                Spacer()
                Button("クリア") {
                    onClear()
                }
                .font(.caption)
                .foregroundColor(.pink)
            }

            if history.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    Text("検索履歴がありません")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 20)
            } else {
                FlowLayout(spacing: 8) {
                    ForEach(history, id: \.self) { item in
                        SearchHistoryChip(item: item) {
                            onSelect(item)
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.secondarySystemBackground))
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
}

// MARK: - Search History Chip

struct SearchHistoryChip: View {
    let item: String
    let onTap: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Image(systemName: "clock")
                    .font(.caption2)
                Text(item)
                    .font(.caption)
                    .lineLimit(1)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(Color.pink.opacity(0.1))
            )
            .foregroundColor(.pink)
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
            withAnimation {
                isPressed = pressing
            }
        }, perform: {})
    }
}

// MARK: - Saved Searches Component

struct SavedSearches: View {
    let searches: [SavedSearch]
    let onSelect: (SavedSearch) -> Void
    let onDelete: (SavedSearch) -> Void

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("保存済み検索")
                    .font(.headline)
                Spacer()
            }

            if searches.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "bookmark.slash")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    Text("保存済み検索がありません")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 20)
            } else {
                VStack(spacing: 8) {
                    ForEach(searches, id: \.id) { search in
                        SavedSearchRow(search: search) {
                            onSelect(search)
                        } onDelete: {
                            onDelete(search)
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.secondarySystemBackground))
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
}

// MARK: - Saved Search Row

struct SavedSearchRow: View {
    let search: SavedSearch
    let onSelect: () -> Void
    let onDelete: () -> Void
    @State private var isPressed = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "bookmark.fill")
                .foregroundColor(.pink)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(search.name)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                Text(search.query)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            Button {
                onDelete()
            } label: {
                Image(systemName: "trash")
                    .foregroundColor(.secondary)
            }
            .scaleEffect(isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
            .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
                withAnimation {
                    isPressed = pressing
                }
            }, perform: {})
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture {
            onSelect()
        }
    }
}

// MARK: - Saved Search Model

struct SavedSearch: Identifiable {
    let id: UUID
    let name: String
    let query: String
    let createdAt: Date
}

// MARK: - Flow Layout for Chips

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize
        var positions: [CGPoint]

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentPosition: CGPoint = .zero
            var lineHeight: CGFloat = 0
            var positions: [CGPoint] = []

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if currentPosition.x + size.width > maxWidth && currentPosition.x > 0 {
                    currentPosition.x = 0
                    currentPosition.y += lineHeight + spacing
                    lineHeight = 0
                }

                positions.append(currentPosition)
                currentPosition.x += size.width + spacing
                lineHeight = max(lineHeight, size.height)
            }

            self.size = CGSize(width: maxWidth, height: currentPosition.y + lineHeight)
            self.positions = positions
        }
    }
}

#Preview("SearchBar") {
    VStack {
        SearchBar(text: .constant(""), placeholder: "学習ログを検索")
        SearchBar(text: .constant("SwiftUI"), placeholder: "学習ログを検索")
        SearchBar(text: .constant(""), placeholder: "検索", prompt: "キーワードを入力...")
    }
    .padding()
}

#Preview("AdvancedSearchBar") {
    VStack {
        AdvancedSearchBar(
            text: .constant("SwiftUI"),
            showAdvancedOptions: .constant(false),
            placeholder: "学習ログを検索"
        )
        AdvancedSearchBar(
            text: .constant("SwiftUI"),
            showAdvancedOptions: .constant(true),
            placeholder: "学習ログを検索"
        )
    }
    .padding()
}

#Preview("SearchHistory") {
    SearchHistory(
        history: ["SwiftUI", "iOS開発", "MVVM", "Combine"],
        onSelect: { _ in },
        onClear: {}
    )
    .padding()
}

#Preview("SavedSearches") {
    SavedSearches(
        searches: [
            SavedSearch(id: UUID(), name: "SwiftUI検索", query: "SwiftUI", createdAt: Date()),
            SavedSearch(id: UUID(), name: "iOS学習", query: "iOS 開発", createdAt: Date()),
            SavedSearch(id: UUID(), name: "MVVMパターン", query: "MVVM architecture", createdAt: Date())
        ],
        onSelect: { _ in },
        onDelete: { _ in }
    )
    .padding()
}
