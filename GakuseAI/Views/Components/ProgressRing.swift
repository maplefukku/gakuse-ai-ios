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


