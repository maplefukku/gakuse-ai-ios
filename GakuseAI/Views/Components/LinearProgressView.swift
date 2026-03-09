import SwiftUI

// MARK: - Linear Progress View
/// 線形プログレスバービュー
public struct LinearProgressView: View {
    private let progress: Double
    private let style: ProgressStyle
    private let height: CGFloat
    private let backgroundColor: Color
    private let foregroundColor: Color
    private let showsPercentage: Bool

    @State private var animatedProgress: Double = 0

    public enum ProgressStyle {
        case standard
        case striped
        case glow
        case minimal
    }

    public init(
        progress: Double,
        style: ProgressStyle = .standard,
        height: CGFloat = 8,
        backgroundColor: Color = Color.gray.opacity(0.2),
        foregroundColor: Color = .accentColor,
        showsPercentage: Bool = false
    ) {
        self.progress = max(0, min(1, progress))
        self.style = style
        self.height = height
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.showsPercentage = showsPercentage
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if showsPercentage {
                Text("\(Int(animatedProgress * 100))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: height / 2)
                        .fill(backgroundColor)

                    // Progress Bar
                    RoundedRectangle(cornerRadius: height / 2)
                        .fill(foregroundColor)
                        .frame(width: geometry.size.width * animatedProgress)
                        .overlay(progressOverlay(for: style))
                }
            }
            .frame(height: height)
        }
        .drawingGroup()
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { newValue in
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                animatedProgress = newValue
            }
        }
    }

    @ViewBuilder
    private func progressOverlay(for style: ProgressStyle) -> some View {
        switch style {
        case .standard:
            EmptyView()

        case .striped:
            stripedPattern

        case .glow:
            RoundedRectangle(cornerRadius: height / 2)
                .fill(
                    LinearGradient(
                        colors: [
                            foregroundColor.opacity(0.8),
                            foregroundColor,
                            foregroundColor.opacity(0.8)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .shadow(color: foregroundColor.opacity(0.5), radius: 4, x: 0, y: 2)

        case .minimal:
            EmptyView()
        }
    }

    private var stripedPattern: some View {
        RoundedRectangle(cornerRadius: height / 2)
            .fill(
                LinearGradient(
                    colors: [
                        foregroundColor.opacity(0.4),
                        foregroundColor.opacity(0.6),
                        foregroundColor.opacity(0.4)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
    }
}

// MARK: - Segmented Linear Progress View
/// セグメント化された線形プログレスバー
public struct SegmentedLinearProgressView: View {
    private let progress: Double
    private let segmentCount: Int
    private let spacing: CGFloat
    private let height: CGFloat

    @State private var animatedProgress: Double = 0

    public init(
        progress: Double,
        segmentCount: Int = 5,
        spacing: CGFloat = 4,
        height: CGFloat = 8
    ) {
        self.progress = max(0, min(1, progress))
        self.segmentCount = segmentCount
        self.spacing = spacing
        self.height = height
    }

    public var body: some View {
        HStack(spacing: spacing) {
            ForEach(0..<segmentCount, id: \.self) { index in
                let segmentProgress = Double(index) / Double(segmentCount)
                let isActive = animatedProgress >= segmentProgress

                RoundedRectangle(cornerRadius: height / 2)
                    .fill(isActive ? Color.accentColor : Color.gray.opacity(0.2))
                    .frame(height: height)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: animatedProgress)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { newValue in
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                animatedProgress = newValue
            }
        }
    }
}

// MARK: - Animated Linear Progress View
/// アニメーション付き線形プログレスバー
public struct AnimatedLinearProgressView: View {
    private let progress: Double
    private let height: CGFloat
    private let animationDuration: TimeInterval

    @State private var animatedProgress: Double = 0
    @State private var shimmerOffset: CGFloat = -100

    public init(
        progress: Double,
        height: CGFloat = 8,
        animationDuration: TimeInterval = 2.0
    ) {
        self.progress = max(0, min(1, progress))
        self.height = height
        self.animationDuration = animationDuration
    }

    public var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(Color.gray.opacity(0.2))

                // Progress Bar
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(Color.accentColor)
                    .frame(width: geometry.size.width * animatedProgress)
                    .overlay(
                        shimmerOverlay
                            .mask(
                                RoundedRectangle(cornerRadius: height / 2)
                                    .fill(Color.accentColor)
                                    .frame(width: geometry.size.width * animatedProgress)
                            )
                    )
            }
        }
        .frame(height: height)
        .drawingGroup()
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                animatedProgress = progress
            }
            startShimmerAnimation()
        }
        .onChange(of: progress) { newValue in
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                animatedProgress = newValue
            }
        }
    }

    private var shimmerOverlay: some View {
        GeometryReader { geometry in
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            .clear,
                            .white.opacity(0.4),
                            .clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 100)
                .offset(x: shimmerOffset)
                .onAppear {
                    startShimmerAnimation()
                }
        }
    }

    private func startShimmerAnimation() {
        withAnimation(.linear(duration: animationDuration).repeatForever(autoreverses: false)) {
            shimmerOffset = 200
        }
    }
}

// MARK: - Label Linear Progress View
/// ラベル付き線形プログレスバー
public struct LabelLinearProgressView: View {
    private let title: String
    private let subtitle: String?
    private let progress: Double
    private let height: CGFloat

    @State private var animatedProgress: Double = 0

    public init(
        title: String,
        subtitle: String? = nil,
        progress: Double,
        height: CGFloat = 8
    ) {
        self.title = title
        self.subtitle = subtitle
        self.progress = max(0, min(1, progress))
        self.height = height
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)

                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                Text("\(Int(animatedProgress * 100))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .monospacedDigit()
            }

            LinearProgressView(
                progress: progress,
                style: .standard,
                height: height
            )
        }
    }
}

// MARK: - Stepped Linear Progress View
/// ステップ形式の線形プログレスバー
public struct SteppedLinearProgressView: View {
    private let steps: [Step]
    private let currentStep: Int
    private let height: CGFloat

    public struct Step {
        public let title: String
        public let subtitle: String?

        public init(title: String, subtitle: String? = nil) {
            self.title = title
            self.subtitle = subtitle
        }
    }

    public init(
        steps: [Step],
        currentStep: Int,
        height: CGFloat = 8
    ) {
        self.steps = steps
        self.currentStep = min(max(0, currentStep), steps.count - 1)
        self.height = height
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background Line
                    RoundedRectangle(cornerRadius: height / 2)
                        .fill(Color.gray.opacity(0.2))

                    // Progress Line
                    RoundedRectangle(cornerRadius: height / 2)
                        .fill(Color.accentColor)
                        .frame(width: geometry.size.width * stepProgress)
                }
            }
            .frame(height: height)

            // Step Labels
            HStack {
                ForEach(0..<steps.count, id: \.self) { index in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(steps[index].title)
                            .font(.caption)
                            .foregroundColor(index <= currentStep ? .primary : .secondary)

                        if let subtitle = steps[index].subtitle {
                            Text(subtitle)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .drawingGroup()
    }

    private var stepProgress: Double {
        return Double(currentStep) / Double(steps.count - 1)
    }
}

// MARK: - Circular Linear Progress View
/// 円形表示も可能な汎用プログレスビュー
public struct CircularLinearProgressView: View {
    private let progress: Double
    private let size: CGFloat
    private let lineWidth: CGFloat

    @State private var animatedProgress: Double = 0

    public init(
        progress: Double,
        size: CGFloat = 100,
        lineWidth: CGFloat = 8
    ) {
        self.progress = max(0, min(1, progress))
        self.size = size
        self.lineWidth = lineWidth
    }

    public var body: some View {
        ZStack {
            // Background Circle
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: lineWidth)

            // Progress Circle
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    Color.accentColor,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.6, dampingFraction: 0.7), value: animatedProgress)
        }
        .frame(width: size, height: size)
        .drawingGroup()
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { newValue in
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                animatedProgress = newValue
            }
        }
    }
}

// MARK: - Preview
#Preview("Standard Progress") {
    VStack(spacing: 20) {
        LinearProgressView(progress: 0.25, height: 8)
        LinearProgressView(progress: 0.50, height: 8)
        LinearProgressView(progress: 0.75, height: 8)
        LinearProgressView(progress: 1.0, height: 8)
    }
    .padding()
}

#Preview("Striped Progress") {
    VStack(spacing: 20) {
        LinearProgressView(progress: 0.3, style: .striped, height: 10)
        LinearProgressView(progress: 0.6, style: .striped, height: 10)
        LinearProgressView(progress: 0.9, style: .striped, height: 10)
    }
    .padding()
}

#Preview("Glow Progress") {
    VStack(spacing: 20) {
        LinearProgressView(progress: 0.3, style: .glow, height: 10, foregroundColor: .blue)
        LinearProgressView(progress: 0.6, style: .glow, height: 10, foregroundColor: .green)
        LinearProgressView(progress: 0.9, style: .glow, height: 10, foregroundColor: .purple)
    }
    .padding()
}

#Preview("With Percentage") {
    VStack(spacing: 20) {
        LinearProgressView(progress: 0.25, showsPercentage: true)
        LinearProgressView(progress: 0.50, showsPercentage: true)
        LinearProgressView(progress: 0.75, showsPercentage: true)
    }
    .padding()
}

#Preview("Segmented Progress") {
    VStack(spacing: 20) {
        SegmentedLinearProgressView(progress: 0.2, segmentCount: 5)
        SegmentedLinearProgressView(progress: 0.6, segmentCount: 5)
        SegmentedLinearProgressView(progress: 0.8, segmentCount: 8)
    }
    .padding()
}

#Preview("Animated Progress") {
    VStack(spacing: 20) {
        AnimatedLinearProgressView(progress: 0.4, height: 10)
        AnimatedLinearProgressView(progress: 0.7, height: 10)
        AnimatedLinearProgressView(progress: 0.9, height: 10)
    }
    .padding()
}

#Preview("Label Progress") {
    VStack(spacing: 20) {
        LabelLinearProgressView(
            title: "ダウンロード中",
            subtitle: "ファイル1 / 3",
            progress: 0.33
        )
        LabelLinearProgressView(
            title: "アップロード中",
            subtitle: "2.5 GB / 5.0 GB",
            progress: 0.50
        )
        LabelLinearProgressView(
            title: "同期中",
            progress: 0.85
        )
    }
    .padding()
}

#Preview("Stepped Progress") {
    SteppedLinearProgressView(
        steps: [
            Step(title: "登録", subtitle: "完了"),
            Step(title: "確認", subtitle: "進行中"),
            Step(title: "承認", subtitle: "待機中"),
            Step(title: "完了", subtitle: "")
        ],
        currentStep: 1
    )
    .padding()
}

#Preview("Circular Progress") {
    HStack(spacing: 30) {
        CircularLinearProgressView(progress: 0.25, size: 80)
        CircularLinearProgressView(progress: 0.50, size: 80)
        CircularLinearProgressView(progress: 0.75, size: 80)
        CircularLinearProgressView(progress: 1.0, size: 80)
    }
    .padding()
}
