//
//  RatingSummary.swift
//  GakuseAI
//
//  Created by fe-dev-2 on 2026-03-15.
//

import SwiftUI

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
