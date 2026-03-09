import SwiftUI

/// 円形プログレスバーコンポーネント
struct ProgressRing: View {
    let progress: Double // 0.0 to 1.0
    let lineWidth: CGFloat
    let size: CGFloat
    let color: Color

    init(progress: Double, lineWidth: CGFloat = 8, size: CGFloat = 100, color: Color = .pink) {
        self.progress = max(0, min(1, progress))
        self.lineWidth = lineWidth
        self.size = size
        self.color = color
    }

    var body: some View {
        ZStack {
            // 背景円
            Circle()
                .stroke(
                    color.opacity(0.2),
                    lineWidth: lineWidth
                )

            // プログレス円
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    color,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(
                    .spring(response: 0.5, dampingFraction: 0.7),
                    value: progress
                )
        }
        .frame(width: size, height: size)
        .drawingGroup()
    }
}

/// テキスト付き円形プログレスバーコンポーネント
struct ProgressRingWithText: View {
    let progress: Double
    let text: String
    let lineWidth: CGFloat
    let size: CGFloat
    let color: Color

    init(progress: Double, text: String, lineWidth: CGFloat = 8, size: CGFloat = 100, color: Color = .pink) {
        self.progress = max(0, min(1, progress))
        self.text = text
        self.lineWidth = lineWidth
        self.size = size
        self.color = color
    }

    var body: some View {
        ZStack {
            ProgressRing(progress: progress, lineWidth: lineWidth, size: size, color: color)

            Text(text)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
        }
        .drawingGroup()
    }
}

/// 円形プログレスバーコンポーネント（パーセント表示）
struct ProgressRingPercent: View {
    let progress: Double
    let lineWidth: CGFloat
    let size: CGFloat
    let color: Color

    init(progress: Double, lineWidth: CGFloat = 8, size: CGFloat = 100, color: Color = .pink) {
        self.progress = max(0, min(1, progress))
        self.lineWidth = lineWidth
        self.size = size
        self.color = color
    }

    var body: some View {
        ProgressRingWithText(
            progress: progress,
            text: "\(Int(progress * 100))%",
            lineWidth: lineWidth,
            size: size,
            color: color
        )
    }
}

/// 複数の円形プログレスバーコンポーネント
struct MultiProgressRing: View {
    let progressItems: [ProgressItem]

    struct ProgressItem {
        let progress: Double
        let color: Color
        let label: String?
    }

    var body: some View {
        VStack(spacing: 16) {
            ForEach(Array(progressItems.enumerated()), id: \.offset) { _, item in
                HStack(spacing: 16) {
                    ProgressRingPercent(
                        progress: item.progress,
                        size: 60,
                        color: item.color
                    )

                    VStack(alignment: .leading, spacing: 4) {
                        if let label = item.label {
                            Text(label)
                                .font(.headline)
                        }

                        Text("\(Int(item.progress * 100))%")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .drawingGroup()
    }
}

// MARK: - Preview

#Preview("Progress Ring") {
    VStack(spacing: 32) {
        ProgressRing(progress: 0.0)
        ProgressRing(progress: 0.25)
        ProgressRing(progress: 0.5)
        ProgressRing(progress: 0.75)
        ProgressRing(progress: 1.0)
    }
    .padding()
}

#Preview("Progress Ring With Text") {
    VStack(spacing: 32) {
        ProgressRingWithText(progress: 0.3, text: "30%")
        ProgressRingWithText(progress: 0.6, text: "60%")
        ProgressRingWithText(progress: 0.9, text: "90%")
    }
    .padding()
}

#Preview("Progress Ring Percent") {
    VStack(spacing: 32) {
        ProgressRingPercent(progress: 0.2, color: .blue)
        ProgressRingPercent(progress: 0.5, color: .green)
        ProgressRingPercent(progress: 0.8, color: .orange)
    }
    .padding()
}

#Preview("Multi Progress Ring") {
    MultiProgressRing(progressItems: [
        ProgressItem(progress: 0.8, color: .pink, label: "Swift"),
        ProgressItem(progress: 0.6, color: .purple, label: "UI/UX"),
        ProgressItem(progress: 0.4, color: .blue, label: "学習")
    ])
    .padding()
}
