//
//  TabBar.swift
//  GakuseAI
//
//  Created by fe-dev-2 on 2026-03-09.
//

import SwiftUI

// MARK: - Tab Bar Item
struct TabBarItem: Identifiable, Equatable {
    let id: String = UUID().uuidString
    let icon: String
    let activeIcon: String
    let title: String
    let badge: Int?
    var isHidden: Bool = false

    init(icon: String, activeIcon: String? = nil, title: String, badge: Int? = nil, isHidden: Bool = false) {
        self.icon = icon
        self.activeIcon = activeIcon ?? icon
        self.title = title
        self.badge = badge
        self.isHidden = isHidden
    }

    static func == (lhs: TabBarItem, rhs: TabBarItem) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Custom Tab Bar
struct CustomTabBar: View {
    @Binding var selectedTab: Int
    let items: [TabBarItem]
    var style: TabBarStyle = .standard
    var onTabChange: ((Int) -> Void)? = nil

    @Namespace private var animation

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                if !item.isHidden {
                    TabBarButton(
                        item: item,
                        isSelected: selectedTab == index,
                        style: style,
                        namespace: animation
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTab = index
                            onTabChange?(index)
                        }
                        // タップフィードバック
                        let feedback = UISelectionFeedbackGenerator()
                        feedback.selectionChanged()
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.horizontal, style == .floating ? 20 : 0)
        .padding(.vertical, style == .floating ? 16 : 8)
        .background(tabBarBackground)
        .overlay(
            style == .floating ? nil : Rectangle()
                .fill(Color.separator.opacity(0.5))
                .frame(height: 0.5),
            alignment: .top
        )
        .drawingGroup()
    }

    @ViewBuilder
    private var tabBarBackground: some View {
        if style == .floating {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: -5)
        } else {
            Color(.systemBackground)
        }
    }
}

// MARK: - Tab Bar Button
struct TabBarButton: View {
    let item: TabBarItem
    let isSelected: Bool
    let style: TabBarStyle
    let namespace: Namespace.ID
    let onTap: () -> Void

    @State private var isPressed: Bool = false

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                ZStack {
                    // 背景インジケーター（フローティングスタイルのみ）
                    if style == .floating && isSelected {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.accentColor.opacity(0.15))
                            .frame(width: 44, height: 32)
                    }

                    // アイコン
                    Image(systemName: isSelected ? item.activeIcon : item.icon)
                        .font(.system(size: 22, weight: isSelected ? .semibold : .regular))
                        .foregroundColor(isSelected ? accentColor : inactiveColor)
                        .scaleEffect(isPressed ? 0.9 : 1.0)
                        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)

                    // バッジ
                    if let badge = item.badge, badge > 0 {
                        ZStack {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 18, height: 18)

                            Text(badgeText(badge))
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .offset(x: 12, y: -12)
                    }
                }
                .frame(height: 32)

                // タイトル
                if style != .minimal {
                    Text(item.title)
                        .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
                        .foregroundColor(isSelected ? accentColor : inactiveColor)
                        .lineLimit(1)
                }
            }
            .padding(.vertical, style == .floating ? 8 : 4)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel(item.title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityRole(.tab)
    }

    private var accentColor: Color {
        Color.accentColor
    }

    private var inactiveColor: Color {
        Color(.tertiaryLabel)
    }

    private func badgeText(_ count: Int) -> String {
        count > 99 ? "99+" : "\(count)"
    }
}

// MARK: - Tab Bar Style
enum TabBarStyle {
    case standard
    case floating
    case minimal
}

// MARK: - Bottom Navigation View Wrapper
struct BottomNavigationView<Content: View>: View {
    @Binding var selectedTab: Int
    let items: [TabBarItem]
    let style: TabBarStyle
    let content: Content

    init(
        selectedTab: Binding<Int>,
        items: [TabBarItem],
        style: TabBarStyle = .standard,
        @ViewBuilder content: () -> Content
    ) {
        self._selectedTab = selectedTab
        self.items = items
        self.style = style
        self.content = content()
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            content
                .padding(.bottom, tabBarHeight)

            CustomTabBar(
                selectedTab: $selectedTab,
                items: items,
                style: style
            )
        }
    }

    private var tabBarHeight: CGFloat {
        switch style {
        case .standard:
            return 80
        case .floating:
            return 90
        case .minimal:
            return 60
        }
    }
}

// MARK: - SwiftUI Previews
#Preview("Standard Tab Bar") {
    VStack {
        Spacer()

        CustomTabBar(
            selectedTab: .constant(0),
            items: [
                TabBarItem(icon: "house", activeIcon: "house.fill", title: "ホーム", badge: 3),
                TabBarItem(icon: "book", activeIcon: "book.fill", title: "学習ログ"),
                TabBarItem(icon: "chart.bar", activeIcon: "chart.bar.fill", title: "統計"),
                TabBarItem(icon: "person", activeIcon: "person.fill", title: "プロフィール"),
            ],
            style: .standard
        )
    }
    .background(Color(.systemGroupedBackground))
}

#Preview("Floating Tab Bar") {
    VStack {
        Spacer()

        CustomTabBar(
            selectedTab: .constant(1),
            items: [
                TabBarItem(icon: "house", activeIcon: "house.fill", title: "ホーム"),
                TabBarItem(icon: "book", activeIcon: "book.fill", title: "学習ログ", badge: 5),
                TabBarItem(icon: "chart.bar", activeIcon: "chart.bar.fill", title: "統計"),
                TabBarItem(icon: "person", activeIcon: "person.fill", title: "プロフィール"),
            ],
            style: .floating
        )
    }
    .background(Color(.systemGroupedBackground))
}

#Preview("Minimal Tab Bar") {
    VStack {
        Spacer()

        CustomTabBar(
            selectedTab: .constant(2),
            items: [
                TabBarItem(icon: "house", activeIcon: "house.fill", title: "ホーム"),
                TabBarItem(icon: "book", activeIcon: "book.fill", title: "学習ログ"),
                TabBarItem(icon: "chart.bar", activeIcon: "chart.bar.fill", title: "統計"),
                TabBarItem(icon: "person", activeIcon: "person.fill", title: "プロフィール"),
            ],
            style: .minimal
        )
    }
    .background(Color(.systemGroupedBackground))
}

#Preview("Bottom Navigation View") {
    let items = [
        TabBarItem(icon: "house", activeIcon: "house.fill", title: "ホーム", badge: 99),
        TabBarItem(icon: "book", activeIcon: "book.fill", title: "学習ログ"),
        TabBarItem(icon: "chart.bar", activeIcon: "chart.bar.fill", title: "統計"),
        TabBarItem(icon: "person", activeIcon: "person.fill", title: "プロフィール"),
    ]

    return BottomNavigationView(
        selectedTab: .constant(0),
        items: items,
        style: .floating
    ) {
        ZStack {
            Color(.systemGroupedBackground)

            VStack {
                Text("ホーム画面")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 100)

                Text("タブバーのプレビュー")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview("Tab Bar with Badge") {
    VStack(spacing: 30) {
        Text("バッジ表示のプレビュー")
            .font(.headline)

        VStack(spacing: 20) {
            // バッジなし
            HStack {
                TabBarButton(
                    item: TabBarItem(icon: "bell", activeIcon: "bell.fill", title: "通知", badge: nil),
                    isSelected: false,
                    style: .standard,
                    namespace: Namespace().wrappedValue
                ) {}
                Text("バッジなし")
            }

            // バッジ1件
            HStack {
                TabBarButton(
                    item: TabBarItem(icon: "bell", activeIcon: "bell.fill", title: "通知", badge: 1),
                    isSelected: false,
                    style: .standard,
                    namespace: Namespace().wrappedValue
                ) {}
                Text("1件")
            }

            // バッジ9件
            HStack {
                TabBarButton(
                    item: TabBarItem(icon: "bell", activeIcon: "bell.fill", title: "通知", badge: 9),
                    isSelected: false,
                    style: .standard,
                    namespace: Namespace().wrappedValue
                ) {}
                Text("9件")
            }

            // バッジ99件
            HStack {
                TabBarButton(
                    item: TabBarItem(icon: "bell", activeIcon: "bell.fill", title: "通知", badge: 99),
                    isSelected: false,
                    style: .standard,
                    namespace: Namespace().wrappedValue
                ) {}
                Text("99件")
            }

            // バッジ100件以上（99+表示）
            HStack {
                TabBarButton(
                    item: TabBarItem(icon: "bell", activeIcon: "bell.fill", title: "通知", badge: 100),
                    isSelected: false,
                    style: .standard,
                    namespace: Namespace().wrappedValue
                ) {}
                Text("100件以上（99+表示）")
            }
        }
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
