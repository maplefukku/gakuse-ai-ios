//
//  RatingStar.swift
//  GakuseAI
//
//  Created by fe-dev-2 on 2026-03-09.
//

import SwiftUI

// MARK: - Rating Star View
struct RatingStar: View {
    var rating: Double = 0.0
    var maxRating: Int = 5
    var style: RatingStyle = .standard
    var size: CGFloat = 24
    var spacing: CGFloat = 4
    var isInteractive: Bool = false
    var onRatingChange: ((Double) -> Void)? = nil
    var allowHalfRating: Bool = false

    @State private var currentRating: Double = 0.0
    @State private var hoverRating: Double = 0.0

    init(
        rating: Double,
        maxRating: Int = 5,
        style: RatingStyle = .standard,
        size: CGFloat = 24,
        spacing: CGFloat = 4,
        isInteractive: Bool = false,
        onRatingChange: ((Double) -> Void)? = nil,
        allowHalfRating: Bool = false
    ) {
        self.rating = rating
        self.maxRating = maxRating
        self.style = style
        self.size = size
        self.spacing = spacing
        self.isInteractive = isInteractive
        self.onRatingChange = onRatingChange
        self.allowHalfRating = allowHalfRating
        self._currentRating = State(initialValue: rating)
    }

    var body: some View {
        HStack(spacing: spacing) {
            ForEach(0..<maxRating, id: \.self) { index in
                StarView(
                    value: Double(index),
                    rating: isInteractive ? hoverRating > 0 ? hoverRating : currentRating : rating,
                    maxRating: Double(maxRating),
                    style: style,
                    size: size
                )
                .onTapGesture {
                    guard isInteractive else { return }
                    let newRating = allowHalfRating ? calculateHalfRating(for: index) : Double(index + 1)
                    currentRating = newRating
                    onRatingChange?(newRating)
                    // タップフィードバック
                    let feedback = UIImpactFeedbackGenerator(style: .light)
                    feedback.impactOccurred()
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            guard isInteractive else { return }
                            // スターの位置を計算
                            let starWidth = size + spacing
                            let relativePosition = value.location.x / starWidth
                            let newRating = max(0, min(Double(maxRating), relativePosition))
                            hoverRating = newRating
                        }
                        .onEnded { _ in
                            guard isInteractive else { return }
                            let finalRating = allowHalfRating ? roundToHalf(hoverRating) : round(hoverRating)
                            currentRating = max(0, min(Double(maxRating), finalRating))
                            hoverRating = 0
                            onRatingChange?(currentRating)
                        }
                )
            }
        }
        .drawingGroup()
    }

    private func calculateHalfRating(for index: Int) -> Double {
        return Double(index) + 0.5
    }

    private func roundToHalf(_ value: Double) -> Double {
        return round(value * 2) / 2
    }
}

// MARK: - Individual Star View
struct StarView: View {
    let value: Double
    let rating: Double
    let maxRating: Double
    let style: RatingStyle
    let size: CGFloat

    private var starFill: Double {
        min(max(rating - value, 0), 1)
    }

    private var starType: StarType {
        if starFill <= 0 {
            return .empty
        } else if starFill < 0.5 {
            return .empty
        } else if starFill < 0.75 {
            return .half
        } else {
            return .full
        }
    }

    var body: some View {
        Image(systemName: starImageName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size, height: size)
            .foregroundColor(starColor)
    }

    private var starImageName: String {
        switch (style, starType) {
        case (.standard, .empty):
            return "star"
        case (.standard, .half):
            return "star.lefthalf.filled"
        case (.standard, .full):
            return "star.fill"

        case (.filled, .empty):
            return "star"
        case (.filled, .half):
            return "star.lefthalf.filled"
        case (.filled, .full):
            return "star.fill"

        case (.outlined, .empty):
            return "star"
        case (.outlined, .half):
            return "star.lefthalf.filled"
        case (.outlined, .full):
            return "star.fill"

        case (.minimal, .empty):
            return "star"
        case (.minimal, .half):
            return "star.lefthalf.filled"
        case (.minimal, .full):
            return "star.fill"

        case (.gold, .empty):
            return "star"
        case (.gold, .half):
            return "star.lefthalf.filled"
        case (.gold, .full):
            return "star.fill"
        }
    }

    private var starColor: Color {
        switch style {
        case .standard:
            return starFill > 0 ? Color(.systemOrange) : Color(.systemGray4)
        case .filled:
            return starFill > 0 ? Color(.systemYellow) : Color(.systemGray5)
        case .outlined:
            return starFill > 0 ? Color(.systemOrange) : Color(.systemGray3)
        case .minimal:
            return starFill > 0 ? Color(.label) : Color(.tertiaryLabel)
        case .gold:
            return starFill > 0 ? Color(red: 1.0, green: 0.84, blue: 0.0) : Color(.systemGray4)
        }
    }
}

// MARK: - Star Type
enum StarType {
    case empty
    case half
    case full
}

// MARK: - Rating Style
enum RatingStyle {
    case standard
    case filled
    case outlined
    case minimal
    case gold
}

// MARK: - Rating Summary View
struct RatingSummary: View {
    var rating: Double
    var reviewCount: Int = 0
    var style: RatingStyle = .standard
    var starSize: CGFloat = 24
    var showReviewCount: Bool = true
    var showAverageRating: Bool = true

    var body: some View {
        VStack(spacing: 4) {
            if showAverageRating {
                Text(String(format: "%.1f", rating))
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.primary)
            }

            RatingStar(
                rating: rating,
                style: style,
                size: starSize
            )

            if showReviewCount {
                Text(reviewCount == 0 ? "まだレビューがありません" : "\(reviewCount)件のレビュー")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        .drawingGroup()
    }
}

// MARK: - Rating Breakdown View
struct RatingBreakdown: View {
    var rating: Double
    var ratings: [Int] = [0, 0, 0, 0, 0] // 5星, 4星, 3星, 2星, 1星
    var totalRatings: Int {
        ratings.reduce(0, +)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 平均評価
            HStack {
                Text(String(format: "%.1f", rating))
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.primary)

                VStack(alignment: .leading, spacing: 4) {
                    RatingStar(rating: rating, size: 20)
                    Text("\(totalRatings)件の評価")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
            }

            // 評価分布
            VStack(alignment: .leading, spacing: 6) {
                ForEach(0..<5) { index in
                    RatingBar(
                        starCount: 5 - index,
                        count: ratings[4 - index],
                        total: totalRatings
                    )
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        .drawingGroup()
    }
}

// MARK: - Rating Bar View
struct RatingBar: View {
    let starCount: Int
    let count: Int
    let total: Int

    private var percentage: Double {
        guard total > 0 else { return 0 }
        return Double(count) / Double(total)
    }

    var body: some View {
        HStack(spacing: 8) {
            Text("\(starCount)星")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .frame(width: 30, alignment: .leading)

            // プログレスバー
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // 背景
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(.systemGray5))
                        .frame(height: 6)

                    // フィル
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(.systemOrange))
                        .frame(width: geometry.size.width * CGFloat(percentage), height: 6)
                }
            }
            .frame(height: 6)

            Text("\(count)")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .frame(width: 30, alignment: .trailing)
        }
    }
}


