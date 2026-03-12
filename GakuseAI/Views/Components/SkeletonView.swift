//
//  SkeletonView.swift
//  GakuseAI
//
//  Created by OpenGoat on 2026-03-10.
//

import SwiftUI

// MARK: - SkeletonView
/// コンテンツのロード中に表示されるスケルトンローディングビュー
public struct SkeletonView: View {
    // MARK: - Properties
    private let width: CGFloat?
    private let height: CGFloat
    private let cornerRadius: CGFloat
    private let style: SkeletonStyle
    @State private var isAnimating = true

    // MARK: - Style Definition
    public enum SkeletonStyle {
        case standard
        case shimmer
        case pulse
        case gradient

        var animationDuration: Double {
            switch self {
            case .standard, .shimmer: return 1.5
            case .pulse: return 1.0
            case .gradient: return 2.0
            }
        }
    }

    // MARK: - Initializer
    public init(
        width: CGFloat? = nil,
        height: CGFloat,
        cornerRadius: CGFloat = 8,
        style: SkeletonStyle = .shimmer
    ) {
        self.width = width
        self.height = height
        self.cornerRadius = cornerRadius
        self.style = style
    }

    // MARK: - Body
    public var body: some View {
        Group {
            switch style {
            case .standard:
                standardSkeleton
            case .shimmer:
                shimmerSkeleton
            case .pulse:
                pulseSkeleton
            case .gradient:
                gradientSkeleton
            }
        }
        .onAppear {
            isAnimating = true
        }
        .onDisappear {
            isAnimating = false
        }
    }

    @ViewBuilder
    private var standardSkeleton: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Color.secondary.opacity(0.2))
            .frame(width: width, height: height)
            .accessibilityElement()
            .accessibilityLabel("ロード中")
            .accessibility(hidden: true)
    }

    @ViewBuilder
    private var shimmerSkeleton: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Color.secondary.opacity(0.2))
            .frame(width: width, height: height)
            .overlay {
                GeometryReader { geometry in
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.clear,
                                    Color.white.opacity(0.3),
                                    Color.clear
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * 0.5)
                        .offset(x: isAnimating ? geometry.size.width * 1.5 : -geometry.size.width * 0.5)
                        .animation(
                            Animation.linear(duration: style.animationDuration)
                                .repeatForever(autoreverses: false),
                            value: isAnimating
                        )
                }
                .clipped()
            }
            .accessibilityElement()
            .accessibilityLabel("ロード中")
            .accessibility(hidden: true)
    }

    @ViewBuilder
    private var pulseSkeleton: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Color.secondary.opacity(0.2))
            .frame(width: width, height: height)
            .opacity(isAnimating ? 0.5 : 1.0)
            .animation(
                Animation.easeInOut(duration: style.animationDuration)
                    .repeatForever(autoreverses: true),
                value: isAnimating
            )
            .accessibilityElement()
            .accessibilityLabel("ロード中")
            .accessibility(hidden: true)
    }

    @ViewBuilder
    private var gradientSkeleton: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.secondary.opacity(0.1),
                        Color.secondary.opacity(0.3),
                        Color.secondary.opacity(0.1)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: width, height: height)
            .overlay {
                GeometryReader { geometry in
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.clear,
                                    Color.white.opacity(0.2),
                                    Color.clear
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: geometry.size.width)
                        .offset(x: isAnimating ? geometry.size.width : -geometry.size.width)
                        .rotationEffect(.degrees(45))
                        .animation(
                            Animation.linear(duration: style.animationDuration)
                                .repeatForever(autoreverses: false),
                            value: isAnimating
                        )
                }
                .clipped()
            }
            .accessibilityElement()
            .accessibilityLabel("ロード中")
            .accessibility(hidden: true)
    }
}

// MARK: - SkeletonCard
/// カード形式のスケルトンビュー
public struct SkeletonCard: View {
    private let width: CGFloat?
    private let height: CGFloat
    private let style: SkeletonView.SkeletonStyle
    private let hasAvatar: Bool
    private let hasImage: Bool

    public init(
        width: CGFloat? = nil,
        height: CGFloat = 120,
        style: SkeletonView.SkeletonStyle = .shimmer,
        hasAvatar: Bool = true,
        hasImage: Bool = false
    ) {
        self.width = width
        self.height = height
        self.style = style
        self.hasAvatar = hasAvatar
        self.hasImage = hasImage
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if hasImage {
                SkeletonView(width: .infinity, height: 80, style: style)
            }

            HStack(spacing: 12) {
                if hasAvatar {
                    SkeletonView(width: 40, height: 40, cornerRadius: 20, style: style)
                }

                VStack(alignment: .leading, spacing: 8) {
                    SkeletonView(width: 120, height: 12, cornerRadius: 6, style: style)
                    SkeletonView(width: 80, height: 10, cornerRadius: 5, style: style)
                }

                Spacer()
            }

            SkeletonView(width: .infinity, height: 10, cornerRadius: 5, style: style)
            SkeletonView(width: 180, height: 10, cornerRadius: 5, style: style)
        }
        .padding(16)
        .frame(width: width)
        .background(Color.secondary.opacity(0.05))
        .cornerRadius(12)
        .drawingGroup()
        .accessibilityElement()
        .accessibilityLabel("ロード中")
        .accessibility(hidden: true)
    }
}

// MARK: - SkeletonRow
/// リスト行形式のスケルトンビュー
public struct SkeletonRow: View {
    private let hasAvatar: Bool
    private let hasIcon: Bool
    private let style: SkeletonView.SkeletonStyle

    public init(
        hasAvatar: Bool = true,
        hasIcon: Bool = false,
        style: SkeletonView.SkeletonStyle = .shimmer
    ) {
        self.hasAvatar = hasAvatar
        self.hasIcon = hasIcon
        self.style = style
    }

    public var body: some View {
        HStack(spacing: 12) {
            if hasAvatar {
                SkeletonView(width: 40, height: 40, cornerRadius: 20, style: style)
            } else if hasIcon {
                SkeletonView(width: 32, height: 32, cornerRadius: 8, style: style)
            }

            VStack(alignment: .leading, spacing: 8) {
                SkeletonView(width: 140, height: 12, cornerRadius: 6, style: style)
                SkeletonView(width: 200, height: 10, cornerRadius: 5, style: style)
            }

            Spacer()

            SkeletonView(width: 24, height: 24, cornerRadius: 12, style: style)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .drawingGroup()
        .accessibilityElement()
        .accessibilityLabel("ロード中")
        .accessibility(hidden: true)
    }
}

// MARK: - SkeletonList
/// リスト形式のスケルトンビュー
public struct SkeletonList: View {
    private let rowCount: Int
    private let style: SkeletonView.SkeletonStyle
    private let hasAvatar: Bool

    public init(
        rowCount: Int = 5,
        style: SkeletonView.SkeletonStyle = .shimmer,
        hasAvatar: Bool = true
    ) {
        self.rowCount = rowCount
        self.style = style
        self.hasAvatar = hasAvatar
    }

    public var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<rowCount, id: \.self) { index in
                SkeletonRow(hasAvatar: hasAvatar, style: style)

                if index < rowCount - 1 {
                    Divider()
                        .background(Color.secondary.opacity(0.2))
                }
            }
        }
        .background(Color.secondary.opacity(0.05))
        .cornerRadius(12)
        .drawingGroup()
        .accessibilityElement()
        .accessibilityLabel("ロード中")
        .accessibility(hidden: true)
    }
}

// MARK: - SkeletonGrid
/// グリッド形式のスケルトンビュー
public struct SkeletonGrid: View {
    private let columns: Int
    private let rows: Int
    private let style: SkeletonView.SkeletonStyle
    private let spacing: CGFloat

    public init(
        columns: Int = 2,
        rows: Int = 3,
        style: SkeletonView.SkeletonStyle = .shimmer,
        spacing: CGFloat = 16
    ) {
        self.columns = columns
        self.rows = rows
        self.style = style
        self.spacing = spacing
    }

    public var body: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: spacing), count: columns),
            spacing: spacing
        ) {
            ForEach(0..<(columns * rows), id: \.self) { _ in
                SkeletonCard(style: style)
            }
        }
        .padding(16)
        .drawingGroup()
        .accessibilityElement()
        .accessibilityLabel("ロード中")
        .accessibility(hidden: true)
    }
}

// MARK: - SkeletonContainer
/// コンテンツ全体をスケルトンで覆うラッパー
public struct SkeletonContainer<Content: View>: View {
    private let isLoading: Bool
    private let style: SkeletonView.SkeletonStyle
    private let content: Content

    public init(
        isLoading: Bool,
        style: SkeletonView.SkeletonStyle = .shimmer,
        @ViewBuilder content: () -> Content
    ) {
        self.isLoading = isLoading
        self.style = style
        self.content = content()
    }

    public var body: some View {
        ZStack {
            content
                .opacity(isLoading ? 0 : 1)
                .disabled(isLoading)

            if isLoading {
                content
                    .redacted(reason: .placeholder)
                    .overlay {
                        Rectangle()
                            .fill(Color.secondary.opacity(0.3))
                    }
            }
        }
        .drawingGroup()
    }
}

// MARK: - Preview
#Preview("SkeletonView - Standard") {
    VStack(spacing: 16) {
        SkeletonView(width: 200, height: 20, style: .standard)
        SkeletonView(width: .infinity, height: 100, cornerRadius: 12, style: .standard)
        SkeletonView(width: 150, height: 150, cornerRadius: 75, style: .standard)
    }
    .padding()
}

#Preview("SkeletonView - Shimmer") {
    VStack(spacing: 16) {
        SkeletonView(width: 200, height: 20, style: .shimmer)
        SkeletonView(width: .infinity, height: 100, cornerRadius: 12, style: .shimmer)
        SkeletonView(width: 150, height: 150, cornerRadius: 75, style: .shimmer)
    }
    .padding()
}

#Preview("SkeletonView - Pulse") {
    VStack(spacing: 16) {
        SkeletonView(width: 200, height: 20, style: .pulse)
        SkeletonView(width: .infinity, height: 100, cornerRadius: 12, style: .pulse)
        SkeletonView(width: 150, height: 150, cornerRadius: 75, style: .pulse)
    }
    .padding()
}

#Preview("SkeletonView - Gradient") {
    VStack(spacing: 16) {
        SkeletonView(width: 200, height: 20, style: .gradient)
        SkeletonView(width: .infinity, height: 100, cornerRadius: 12, style: .gradient)
        SkeletonView(width: 150, height: 150, cornerRadius: 75, style: .gradient)
    }
    .padding()
}

#Preview("SkeletonCard") {
    ScrollView {
        VStack(spacing: 16) {
            SkeletonCard(style: .shimmer)
            SkeletonCard(style: .shimmer, hasAvatar: false)
            SkeletonCard(style: .shimmer, hasImage: true)
        }
        .padding()
    }
}

#Preview("SkeletonRow") {
    ScrollView {
        VStack(spacing: 0) {
            SkeletonRow(style: .shimmer)
            Divider()
            SkeletonRow(style: .shimmer)
            Divider()
            SkeletonRow(hasAvatar: false, hasIcon: true, style: .shimmer)
            Divider()
            SkeletonRow(style: .shimmer)
        }
        .background(Color.secondary.opacity(0.05))
        .cornerRadius(12)
    }
    .padding()
}

#Preview("SkeletonList") {
    SkeletonList(rowCount: 5, style: .shimmer)
        .padding()
}

#Preview("SkeletonGrid") {
    ScrollView {
        SkeletonGrid(columns: 2, rows: 3, style: .shimmer)
    }
}

#Preview("SkeletonContainer") {
    @Previewable @State var isLoading = true

    return VStack {
        Toggle("Loading", isOn: $isLoading)

        SkeletonContainer(isLoading: isLoading, style: .shimmer) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 40, height: 40)

                    VStack(alignment: .leading) {
                        Text("Title")
                            .font(.headline)
                        Text("Subtitle")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()
                }

                Text("Description text goes here. This is some placeholder content.")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(Color.secondary.opacity(0.05))
            .cornerRadius(12)
        }
    }
    .padding()
}

#Preview("Gallery") {
    SwiftUI.TabView {
        ScrollView {
            VStack(spacing: 16) {
                Text("Standard Style")
                    .font(.headline)
                SkeletonView(width: 200, height: 20, style: .standard)
                SkeletonView(width: .infinity, height: 100, cornerRadius: 12, style: .standard)
            }
            .padding()
        }
        .tabItem {
            Label("Standard", systemImage: "square")
        }

        ScrollView {
            VStack(spacing: 16) {
                Text("Shimmer Style")
                    .font(.headline)
                SkeletonView(width: 200, height: 20, style: .shimmer)
                SkeletonView(width: .infinity, height: 100, cornerRadius: 12, style: .shimmer)
            }
            .padding()
        }
        .tabItem {
            Label("Shimmer", systemImage: "sparkles")
        }

        ScrollView {
            VStack(spacing: 16) {
                Text("Pulse Style")
                    .font(.headline)
                SkeletonView(width: 200, height: 20, style: .pulse)
                SkeletonView(width: .infinity, height: 100, cornerRadius: 12, style: .pulse)
            }
            .padding()
        }
        .tabItem {
            Label("Pulse", systemImage: "waveform.path")
        }

        ScrollView {
            VStack(spacing: 16) {
                Text("Gradient Style")
                    .font(.headline)
                SkeletonView(width: 200, height: 20, style: .gradient)
                SkeletonView(width: .infinity, height: 100, cornerRadius: 12, style: .gradient)
            }
            .padding()
        }
        .tabItem {
            Label("Gradient", systemImage: "gradient")
        }
    }
}
