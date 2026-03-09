//
//  TimelineView.swift
//  GakuseAI
//
//  Created by fe-dev-2 on 2026-03-09.
//

import SwiftUI

// MARK: - Timeline View
struct TimelineView: View {
    var events: [TimelineEvent]
    var style: TimelineStyle = .standard
    var showDate: Bool = true
    var showTime: Bool = true
    var onTapEvent: ((TimelineEvent) -> Void)? = nil

    @State private var pressedEventIndex: Int? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: style.spacing) {
            ForEach(Array(events.enumerated()), id: \.offset) { index, event in
                eventRow(for: event, index: index, totalEvents: events.count)
            }
        }
        .padding(style.padding)
        .background(style.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: style.cornerRadius))
    }

    @ViewBuilder
    private func eventRow(for event: TimelineEvent, index: Int, totalEvents: Int) -> some View {
        HStack(alignment: .top, spacing: style.timelineSpacing) {
            // 日時ラベル
            VStack(alignment: .leading, spacing: 2) {
                if showDate {
                    Text(eventDateFormatter.string(from: event.date))
                        .font(.system(size: style.dateFontSize, weight: .medium))
                        .foregroundColor(style.dateColor)
                }

                if showTime {
                    Text(eventTimeFormatter.string(from: event.date))
                        .font(.system(size: style.timeFontSize, weight: .regular))
                        .foregroundColor(style.timeColor)
                }
            }
            .frame(width: style.dateTimeWidth, alignment: .leading)

            // タイムライン
            ZStack(alignment: .top) {
                // 縦線
                if index < totalEvents - 1 {
                    Rectangle()
                        .fill(style.lineColor)
                        .frame(width: style.lineWidth)
                        .offset(y: style.nodeSize / 2)
                }

                // ノード
                Circle()
                    .fill(event.backgroundColor ?? style.nodeColor)
                    .frame(width: style.nodeSize, height: style.nodeSize)
                    .overlay(
                        Circle()
                            .stroke(event.borderColor ?? style.borderColor, lineWidth: style.borderWidth)
                    )
                    .shadow(color: event.shadowColor ?? style.shadowColor, radius: style.shadowRadius)
            }
            .frame(width: style.timelineWidth)

            // イベントコンテンツ
            eventContentView(for: event, index: index)
        }
    }

    @ViewBuilder
    private func eventContentView(for event: TimelineEvent, index: Int) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            // タイトル
            Text(event.title)
                .font(.system(size: style.titleFontSize, weight: .semibold))
                .foregroundColor(style.titleColor)

            // サブタイトル
            if let subtitle = event.subtitle {
                Text(subtitle)
                    .font(.system(size: style.subtitleFontSize, weight: .regular))
                    .foregroundColor(style.subtitleColor)
            }

            // 説明
            if let description = event.description {
                Text(description)
                    .font(.system(size: style.descriptionFontSize, weight: .regular))
                    .foregroundColor(style.descriptionColor)
                    .lineLimit(style.descriptionLineLimit)
            }

            // タグ
            if !event.tags.isEmpty {
                HStack(spacing: 4) {
                    ForEach(event.tags, id: \.self) { tag in
                        Text(tag)
                            .font(.system(size: style.tagFontSize, weight: .medium))
                            .foregroundColor(event.tagTextColor ?? style.tagTextColor)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(event.tagBackgroundColor ?? style.tagBackgroundColor)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                }
            }
        }
        .padding(style.contentPadding)
        .background(style.contentBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: style.contentCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: style.contentCornerRadius)
                .stroke(style.contentBorderColor, lineWidth: style.contentBorderWidth)
        )
        .scaleEffect(pressedEventIndex == index ? 0.97 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: pressedEventIndex)
        .drawingGroup() // パフォーマンス最適化：レイヤー合成削減
        .onTapGesture {
            if let onTapEvent = onTapEvent {
                onTapEvent(event)
            }
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    pressedEventIndex = index
                }
                .onEnded { _ in
                    pressedEventIndex = nil
                    let feedback = UIImpactFeedbackGenerator(style: .light)
                    feedback.impactOccurred()
                }
        )
    }
}

// MARK: - Timeline Style
enum TimelineStyle {
    case standard
    case minimal
    case card
    case colorful

    var spacing: CGFloat {
        switch self {
        case .standard:
            return 20
        case .minimal:
            return 12
        case .card:
            return 16
        case .colorful:
            return 20
        }
    }

    var padding: CGFloat {
        switch self {
        case .standard:
            return 16
        case .minimal:
            return 12
        case .card:
            return 20
        case .colorful:
            return 16
        }
    }

    var cornerRadius: CGFloat {
        switch self {
        case .standard:
            return 8
        case .minimal:
            return 4
        case .card:
            return 12
        case .colorful:
            return 8
        }
    }

    var backgroundColor: Color {
        switch self {
        case .standard:
            return Color(.systemGroupedBackground)
        case .minimal:
            return Color(.systemBackground)
        case .card:
            return Color(.systemGroupedBackground)
        case .colorful:
            return Color(.systemGroupedBackground)
        }
    }

    var timelineSpacing: CGFloat {
        switch self {
        case .standard:
            return 12
        case .minimal:
            return 8
        case .card:
            return 16
        case .colorful:
            return 12
        }
    }

    var dateTimeWidth: CGFloat {
        switch self {
        case .standard:
            return 70
        case .minimal:
            return 60
        case .card:
            return 80
        case .colorful:
            return 70
        }
    }

    var dateFontSize: CGFloat {
        switch self {
        case .standard:
            return 12
        case .minimal:
            return 11
        case .card:
            return 13
        case .colorful:
            return 12
        }
    }

    var dateColor: Color {
        switch self {
        case .standard:
            return .primary
        case .minimal:
            return .secondary
        case .card:
            return .primary
        case .colorful:
            return .primary
        }
    }

    var timeFontSize: CGFloat {
        switch self {
        case .standard:
            return 10
        case .minimal:
            return 9
        case .card:
            return 11
        case .colorful:
            return 10
        }
    }

    var timeColor: Color {
        switch self {
        case .standard:
            return .secondary
        case .minimal:
            return .secondary
        case .card:
            return .secondary
        case .colorful:
            return .secondary
        }
    }

    var timelineWidth: CGFloat {
        switch self {
        case .standard:
            return 24
        case .minimal:
            return 16
        case .card:
            return 28
        case .colorful:
            return 24
        }
    }

    var lineColor: Color {
        switch self {
        case .standard:
            return Color(.systemGray4)
        case .minimal:
            return Color(.systemGray3)
        case .card:
            return Color(.systemGray4)
        case .colorful:
            return Color(.systemGray4)
        }
    }

    var lineWidth: CGFloat {
        switch self {
        case .standard:
            return 2
        case .minimal:
            return 1
        case .card:
            return 3
        case .colorful:
            return 2
        }
    }

    var nodeSize: CGFloat {
        switch self {
        case .standard:
            return 12
        case .minimal:
            return 8
        case .card:
            return 14
        case .colorful:
            return 12
        }
    }

    var nodeColor: Color {
        switch self {
        case .standard:
            return Color.accentColor
        case .minimal:
            return Color.accentColor
        case .card:
            return Color.accentColor
        case .colorful:
            return Color.accentColor
        }
    }

    var borderWidth: CGFloat {
        switch self {
        case .standard:
            return 2
        case .minimal:
            return 1
        case .card:
            return 3
        case .colorful:
            return 2
        }
    }

    var borderColor: Color {
        switch self {
        case .standard:
            return Color(.systemBackground)
        case .minimal:
            return Color.accentColor
        case .card:
            return Color(.systemBackground)
        case .colorful:
            return Color(.systemBackground)
        }
    }

    var shadowColor: Color {
        switch self {
        case .standard:
            return Color.black.opacity(0.1)
        case .minimal:
            return Color.clear
        case .card:
            return Color.black.opacity(0.15)
        case .colorful:
            return Color.black.opacity(0.1)
        }
    }

    var shadowRadius: CGFloat {
        switch self {
        case .standard:
            return 2
        case .minimal:
            return 0
        case .card:
            return 3
        case .colorful:
            return 2
        }
    }

    var titleFontSize: CGFloat {
        switch self {
        case .standard:
            return 14
        case .minimal:
            return 13
        case .card:
            return 15
        case .colorful:
            return 14
        }
    }

    var titleColor: Color {
        switch self {
        case .standard:
            return .primary
        case .minimal:
            return .primary
        case .card:
            return .primary
        case .colorful:
            return .primary
        }
    }

    var subtitleFontSize: CGFloat {
        switch self {
        case .standard:
            return 12
        case .minimal:
            return 11
        case .card:
            return 13
        case .colorful:
            return 12
        }
    }

    var subtitleColor: Color {
        switch self {
        case .standard:
            return .secondary
        case .minimal:
            return .secondary
        case .card:
            return .secondary
        case .colorful:
            return .secondary
        }
    }

    var descriptionFontSize: CGFloat {
        switch self {
        case .standard:
            return 11
        case .minimal:
            return 10
        case .card:
            return 12
        case .colorful:
            return 11
        }
    }

    var descriptionColor: Color {
        switch self {
        case .standard:
            return .secondary
        case .minimal:
            return .secondary
        case .card:
            return .secondary
        case .colorful:
            return .secondary
        }
    }

    var descriptionLineLimit: Int {
        switch self {
        case .standard:
            return 2
        case .minimal:
            return 1
        case .card:
            return 3
        case .colorful:
            return 2
        }
    }

    var tagFontSize: CGFloat {
        switch self {
        case .standard:
            return 10
        case .minimal:
            return 9
        case .card:
            return 11
        case .colorful:
            return 10
        }
    }

    var tagTextColor: Color {
        switch self {
        case .standard:
            return .white
        case .minimal:
            return .secondary
        case .card:
            return .white
        case .colorful:
            return .white
        }
    }

    var tagBackgroundColor: Color {
        switch self {
        case .standard:
            return Color.accentColor
        case .minimal:
            return Color(.systemGray5)
        case .card:
            return Color.accentColor
        case .colorful:
            return Color.accentColor
        }
    }

    var contentPadding: CGFloat {
        switch self {
        case .standard:
            return 12
        case .minimal:
            return 8
        case .card:
            return 16
        case .colorful:
            return 12
        }
    }

    var contentBackgroundColor: Color {
        switch self {
        case .standard:
            return Color(.systemBackground)
        case .minimal:
            return Color.clear
        case .card:
            return Color(.systemBackground)
        case .colorful:
            return Color(.systemBackground)
        }
    }

    var contentCornerRadius: CGFloat {
        switch self {
        case .standard:
            return 8
        case .minimal:
            return 4
        case .card:
            return 12
        case .colorful:
            return 8
        }
    }

    var contentBorderColor: Color {
        switch self {
        case .standard:
            return Color(.systemGray4)
        case .minimal:
            return Color.clear
        case .card:
            return Color(.systemGray4)
        case .colorful:
            return Color(.systemGray4)
        }
    }

    var contentBorderWidth: CGFloat {
        switch self {
        case .standard:
            return 1
        case .minimal:
            return 0
        case .card:
            return 1
        case .colorful:
            return 1
        }
    }
}

// MARK: - Timeline Event
struct TimelineEvent: Identifiable {
    let id: String
    let date: Date
    let title: String
    let subtitle: String?
    let description: String?
    let tags: [String]
    let backgroundColor: Color?
    let borderColor: Color?
    let tagTextColor: Color?
    let tagBackgroundColor: Color?
    let shadowColor: Color?

    init(
        id: String,
        date: Date,
        title: String,
        subtitle: String? = nil,
        description: String? = nil,
        tags: [String] = [],
        backgroundColor: Color? = nil,
        borderColor: Color? = nil,
        tagTextColor: Color? = nil,
        tagBackgroundColor: Color? = nil,
        shadowColor: Color? = nil
    ) {
        self.id = id
        self.date = date
        self.title = title
        self.subtitle = subtitle
        self.description = description
        self.tags = tags
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.tagTextColor = tagTextColor
        self.tagBackgroundColor = tagBackgroundColor
        self.shadowColor = shadowColor
    }
}

// MARK: - Date Formatters
private let eventDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "M/d"
    formatter.locale = Locale(identifier: "ja_JP")
    return formatter
}()

private let eventTimeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    formatter.locale = Locale(identifier: "ja_JP")
    return formatter
}()

// MARK: - SwiftUI Previews
#Preview("Standard Timeline") {
    VStack(spacing: 20) {
        Text("標準タイムライン")
            .font(.headline)

        TimelineView(
            events: standardEvents,
            style: .standard,
            showDate: true,
            showTime: true
        )
    }
    .padding()
    .background(Color(.systemBackground))
}

#Preview("Minimal Timeline") {
    VStack(spacing: 20) {
        Text("ミニマルタイムライン")
            .font(.headline)

        TimelineView(
            events: standardEvents.prefix(3).map { $0 },
            style: .minimal,
            showDate: true,
            showTime: true
        )
    }
    .padding()
    .background(Color(.systemBackground))
}

#Preview("Card Timeline") {
    VStack(spacing: 20) {
        Text("カードタイムライン")
            .font(.headline)

        TimelineView(
            events: standardEvents,
            style: .card,
            showDate: true,
            showTime: true
        )
    }
    .padding()
    .background(Color(.systemBackground))
}

#Preview("Colorful Timeline") {
    VStack(spacing: 20) {
        Text("カラフルタイムライン")
            .font(.headline)

        TimelineView(
            events: colorfulEvents,
            style: .colorful,
            showDate: true,
            showTime: true
        )
    }
    .padding()
    .background(Color(.systemBackground))
}

#Preview("With Tags") {
    VStack(spacing: 20) {
        Text("タグ付きタイムライン")
            .font(.headline)

        TimelineView(
            events: taggedEvents,
            style: .standard,
            showDate: true,
            showTime: true
        )
    }
    .padding()
    .background(Color(.systemBackground))
}

#Preview("Date Only") {
    VStack(spacing: 20) {
        Text("日付のみ")
            .font(.headline)

        TimelineView(
            events: standardEvents,
            style: .minimal,
            showDate: true,
            showTime: false
        )
    }
    .padding()
    .background(Color(.systemBackground))
}

#Preview("Time Only") {
    VStack(spacing: 20) {
        Text("時刻のみ")
            .font(.headline)

        TimelineView(
            events: standardEvents,
            style: .minimal,
            showDate: false,
            showTime: true
        )
    }
    .padding()
    .background(Color(.systemBackground))
}

// MARK: - Sample Data
private let standardEvents: [TimelineEvent] = [
    TimelineEvent(
        id: "1",
        date: Date().addingTimeInterval(-86400 * 2),
        title: "プロジェクト開始",
        subtitle: "新しいプロジェクトが開始されました",
        description: "iOSアプリ開発プロジェクトが正式にスタートしました。",
        tags: ["プロジェクト", "開始"],
        backgroundColor: .blue,
        borderColor: nil
    ),
    TimelineEvent(
        id: "2",
        date: Date().addingTimeInterval(-86400),
        title: "初期設計完了",
        subtitle: "システム設計とUI設計が完了",
        description: "要件定義と基本設計が完了し、実装フェーズに入りました。",
        tags: ["設計", "完了"],
        backgroundColor: .green,
        borderColor: nil
    ),
    TimelineEvent(
        id: "3",
        date: Date(),
        title: "UI実装中",
        subtitle: "主要なUIコンポーネントの実装",
        description: "SwiftUIを使用してモダンなUIコンポーネントを実装中です。",
        tags: ["実装", "UI"],
        backgroundColor: .orange,
        borderColor: nil
    ),
    TimelineEvent(
        id: "4",
        date: Date().addingTimeInterval(86400),
        title: "テスト開始予定",
        subtitle: "ユニットテストとUIテスト",
        description: "実装完了後、テストフェーズに入ります。",
        tags: ["テスト", "予定"],
        backgroundColor: .purple,
        borderColor: nil
    )
]

private let colorfulEvents: [TimelineEvent] = [
    TimelineEvent(
        id: "1",
        date: Date().addingTimeInterval(-86400 * 3),
        title: "イベント1",
        subtitle: "赤",
        description: "赤色のイベントです。",
        tags: ["赤"],
        backgroundColor: .red,
        borderColor: .white
    ),
    TimelineEvent(
        id: "2",
        date: Date().addingTimeInterval(-86400 * 2),
        title: "イベント2",
        subtitle: "青",
        description: "青色のイベントです。",
        tags: ["青"],
        backgroundColor: .blue,
        borderColor: .white
    ),
    TimelineEvent(
        id: "3",
        date: Date().addingTimeInterval(-86400),
        title: "イベント3",
        subtitle: "緑",
        description: "緑色のイベントです。",
        tags: ["緑"],
        backgroundColor: .green,
        borderColor: .white
    ),
    TimelineEvent(
        id: "4",
        date: Date(),
        title: "イベント4",
        subtitle: "黄色",
        description: "黄色のイベントです。",
        tags: ["黄"],
        backgroundColor: .yellow,
        borderColor: .white,
        tagTextColor: .black
    )
]

private let taggedEvents: [TimelineEvent] = [
    TimelineEvent(
        id: "1",
        date: Date().addingTimeInterval(-86400),
        title: "会議",
        subtitle: "チームミーティング",
        description: "週次のチームミーティングを行いました。",
        tags: ["会議", "チーム"]
    ),
    TimelineEvent(
        id: "2",
        date: Date(),
        title: "コードレビュー",
        subtitle: "PRレビュー",
        description: "新しいPRのコードレビューを行いました。",
        tags: ["コードレビュー", "PR", "開発"]
    ),
    TimelineEvent(
        id: "3",
        date: Date().addingTimeInterval(86400),
        title: "リリース",
        subtitle: "v1.0リリース",
        description: "初回リリースを予定しています。",
        tags: ["リリース", "v1.0", "重要"]
    )
]
