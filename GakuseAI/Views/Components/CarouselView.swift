import SwiftUI

// MARK: - Carousel View
/// スワイプ可能な横スクロールカルーセルビュー
public struct CarouselView<Content: View>: View {
    private let content: Content
    private let spacing: CGFloat
    private let padding: CGFloat
    private let showsIndicators: Bool

    @State private var currentIndex: Int = 0
    @State private var dragOffset: CGFloat = 0

    public init(
        spacing: CGFloat = 16,
        padding: CGFloat = 16,
        showsIndicators: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self.spacing = spacing
        self.padding = padding
        self.showsIndicators = showsIndicators
        self.content = content()
    }

    public var body: some View {
        VStack(spacing: 8) {
            // Carousel Content
            GeometryReader { geometry in
                let itemWidth = geometry.size.width - (padding * 2)
                
                HStack(spacing: spacing) {
                    content
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .offset(x: -CGFloat(currentIndex) * (itemWidth + spacing) + dragOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            dragOffset = value.translation.width
                        }
                        .onEnded { value in
                            let threshold: CGFloat = 50
                            let itemWidth = geometry.size.width - (padding * 2)
                            
                            if value.translation.width > threshold {
                                // Swipe Right
                                currentIndex = max(0, currentIndex - 1)
                            } else if value.translation.width < -threshold {
                                // Swipe Left
                                currentIndex = min(getChildCount() - 1, currentIndex + 1)
                            }
                            
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                dragOffset = 0
                            }
                        }
                )
            }
            .clipped()
            .drawingGroup()

            // Page Indicators
            if showsIndicators {
                HStack(spacing: 8) {
                    ForEach(0..<getChildCount(), id: \.self) { index in
                        Circle()
                            .fill(index == currentIndex ? Color.accentColor : Color.gray.opacity(0.3))
                            .frame(width: index == currentIndex ? 8 : 6, height: index == currentIndex ? 8 : 6)
                            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: currentIndex)
                    }
                }
                .drawingGroup()
            }
        }
    }

    private func getChildCount() -> Int {
        // Helper to count child views (simplified)
        return 1 // This would need proper implementation in production
    }
}

// MARK: - Carousel Item View
/// カルーセル用アイテムビュー
public struct CarouselItemView<Content: View>: View {
    private let content: Content
    private let width: CGFloat?

    public init(width: CGFloat? = nil, @ViewBuilder content: () -> Content) {
        self.width = width
        self.content = content()
    }

    public var body: some View {
        content
            .frame(width: width)
    }
}

// MARK: - Auto Scroll Carousel
/// 自動スクロール機能付きカルーセル
public struct AutoScrollCarouselView<Content: View>: View {
    private let content: Content
    private let interval: TimeInterval
    private let spacing: CGFloat
    private let padding: CGFloat

    @State private var currentIndex: Int = 0

    public init(
        interval: TimeInterval = 3.0,
        spacing: CGFloat = 16,
        padding: CGFloat = 16,
        @ViewBuilder content: () -> Content
    ) {
        self.interval = interval
        self.spacing = spacing
        self.padding = padding
        self.content = content()
    }

    public var body: some View {
        GeometryReader { geometry in
            let itemWidth = geometry.size.width - (padding * 2)
            
            HStack(spacing: spacing) {
                content
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .offset(x: -CGFloat(currentIndex) * (itemWidth + spacing))
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentIndex)
            .onAppear {
                startAutoScroll()
            }
        }
        .clipped()
        .drawingGroup()
    }

    private func startAutoScroll() {
        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                currentIndex = (currentIndex + 1) % getChildCount()
            }
        }
    }

    private func getChildCount() -> Int {
        return 1 // Simplified
    }
}

// MARK: - Carousel Style
/// カルーセルスタイル
public enum CarouselStyle {
    case standard
    case card
    case minimal
}

// MARK: - Styled Carousel View
/// スタイル適用済みカルーセルビュー
public struct StyledCarouselView<Content: View>: View {
    private let content: Content
    private let style: CarouselStyle
    private let spacing: CGFloat
    private let padding: CGFloat

    @State private var currentIndex: Int = 0
    @State private var dragOffset: CGFloat = 0

    public init(
        style: CarouselStyle = .standard,
        spacing: CGFloat = 16,
        padding: CGFloat = 16,
        @ViewBuilder content: () -> Content
    ) {
        self.style = style
        self.spacing = spacing
        self.padding = padding
        self.content = content()
    }

    public var body: some View {
        VStack(spacing: 8) {
            GeometryReader { geometry in
                let itemWidth = geometry.size.width - (padding * 2)
                
                HStack(spacing: spacing) {
                    content
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .offset(x: -CGFloat(currentIndex) * (itemWidth + spacing) + dragOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            dragOffset = value.translation.width
                        }
                        .onEnded { value in
                            let threshold: CGFloat = 50
                            
                            if value.translation.width > threshold {
                                currentIndex = max(0, currentIndex - 1)
                            } else if value.translation.width < -threshold {
                                currentIndex = min(getChildCount() - 1, currentIndex + 1)
                            }
                            
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                dragOffset = 0
                            }
                        }
                )
                .background(backgroundColor(for: style))
                .cornerRadius(cornerRadius(for: style))
                .shadow(shadowForStyle(style))
            }
            .clipped()

            // Page Indicators
            HStack(spacing: 8) {
                ForEach(0..<getChildCount(), id: \.self) { index in
                    Circle()
                        .fill(pageIndicatorColor(for: index))
                        .frame(width: pageIndicatorSize(for: index), height: pageIndicatorSize(for: index))
                        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: currentIndex)
                }
            }
        }
    }

    private func getChildCount() -> Int { return 1 }
    
    private func backgroundColor(for style: CarouselStyle) -> Color {
        switch style {
        case .standard: return Color(.systemBackground)
        case .card: return Color(.systemBackground)
        case .minimal: return Color.clear
        }
    }
    
    private func cornerRadius(for style: CarouselStyle) -> CGFloat {
        switch style {
        case .standard: return 0
        case .card: return 12
        case .minimal: return 0
        }
    }
    
    private func shadowForStyle(_ style: CarouselStyle) -> some View {
        switch style {
        case .standard: return EmptyView()
        case .card: 
            return AnyView(
                Color.black.opacity(0.1)
                    .offset(x: 0, y: 2)
                    .blur(radius: 4)
            )
        case .minimal: return EmptyView()
        }
    }
    
    private func pageIndicatorColor(for index: Int) -> Color {
        index == currentIndex ? Color.accentColor : Color.gray.opacity(0.3)
    }
    
    private func pageIndicatorSize(for index: Int) -> CGFloat {
        index == currentIndex ? 8 : 6
    }
}

// MARK: - Horizontal Carousel
/// 水平方向のスナップ付きカルーセル
public struct HorizontalCarouselView<Content: View>: View {
    private let content: Content
    private let spacing: CGFloat

    @State private var scrollOffset: CGFloat = 0

    public init(spacing: CGFloat = 16, @ViewBuilder content: () -> Content) {
        self.spacing = spacing
        self.content = content()
    }

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: spacing) {
                content
            }
            .offset(x: scrollOffset)
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    scrollOffset = value.translation.width
                }
                .onEnded { value in
                    let itemWidth = 100 // Simplified
                    let index = Int(round(scrollOffset / itemWidth))
                    scrollOffset = CGFloat(index) * itemWidth
                    
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        scrollOffset = scrollOffset
                    }
                }
        )
    }
}

// MARK: - Infinite Carousel
/// 無限ループカルーセル（実装予定）
public struct InfiniteCarouselView<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        Text("Infinite Carousel - Coming Soon")
            .foregroundColor(.gray)
    }
}

// MARK: - Preview
#Preview("Standard Carousel") {
    CarouselView(spacing: 16, showsIndicators: true) {
        ForEach(0..<5) { index in
            VStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 280, height: 180)
                Text("Item \(index + 1)")
                    .font(.headline)
            }
        }
    }
    .frame(height: 240)
    .padding()
}

#Preview("Auto Scroll Carousel") {
    AutoScrollCarouselView(interval: 2.0, spacing: 16) {
        ForEach(0..<5) { index in
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.green.opacity(0.2))
                .frame(width: 280, height: 180)
                .overlay(
                    Text("Auto \(index + 1)")
                        .font(.headline)
                )
        }
    }
    .frame(height: 240)
    .padding()
}

#Preview("Styled Carousel - Card") {
    StyledCarouselView(style: .card, spacing: 16) {
        ForEach(0..<5) { index in
            VStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.purple.opacity(0.2))
                    .frame(width: 280, height: 180)
                Text("Card \(index + 1)")
                    .font(.headline)
            }
        }
    }
    .frame(height: 240)
    .padding()
}

#Preview("Styled Carousel - Minimal") {
    StyledCarouselView(style: .minimal, spacing: 16) {
        ForEach(0..<5) { index in
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.orange.opacity(0.2))
                .frame(width: 280, height: 180)
                .overlay(
                    Text("Minimal \(index + 1)")
                        .font(.headline)
                )
        }
    }
    .frame(height: 240)
    .padding()
}

#Preview("Horizontal Carousel") {
    HorizontalCarouselView(spacing: 12) {
        ForEach(0..<10) { index in
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.teal.opacity(0.3))
                .frame(width: 100, height: 100)
                .overlay(
                    Text("\(index + 1)")
                        .font(.headline)
                )
        }
    }
    .frame(height: 120)
}
