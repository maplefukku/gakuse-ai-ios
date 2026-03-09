//
//  RatingView.swift
//  GakuseAI
//
//  Created by OpenClaw on 2026-03-09.
//

import SwiftUI

// MARK: - StarRatingView
/// 星評価コンポーネント
struct StarRatingView: View {
    // MARK: - Properties
    @Binding private var rating: Int
    private let maxRating: Int
    private let color: Color
    private let spacing: CGFloat
    private let size: CGFloat
    private let isEditable: Bool
    private let onRatingChanged: ((Int) -> Void)?
    @State private var currentRating: Int = 0
    
    // MARK: - Initialization
    /// 星評価ビューを初期化
    /// - Parameters:
    ///   - rating: 評価値
    ///   - maxRating: 最大評価値（デフォルト: 5）
    ///   - color: 星の色（デフォルト: 黄色）
    ///   - spacing: 星の間隔（デフォルト: 4）
    ///   - size: 星のサイズ（デフォルト: 24）
    ///   - isEditable: 編集可能かどうか（デフォルト: true）
    ///   - onRatingChanged: 評価変更コールバック
    init(
        rating: Binding<Int>,
        maxRating: Int = 5,
        color: Color = .yellow,
        spacing: CGFloat = 4,
        size: CGFloat = 24,
        isEditable: Bool = true,
        onRatingChanged: ((Int) -> Void)? = nil
    ) {
        self._rating = rating
        self.maxRating = maxRating
        self.color = color
        self.spacing = spacing
        self.size = size
        self.isEditable = isEditable
        self.onRatingChanged = onRatingChanged
    }
    
    // MARK: - Body
    var body: some View {
        HStack(spacing: spacing) {
            ForEach(1...maxRating, id: \.self) { index in
                Image(systemName: starImageName(for: index))
                    .font(.system(size: size, weight: .medium))
                    .foregroundStyle(starColor(for: index))
                    .scaleEffect(starScale(for: index))
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: rating)
                    .if(isEditable) { view in
                        view
                            .onTapGesture {
                                rating = index
                                onRatingChanged?(index)
                            }
                    }
                    .if(isEditable) { view in
                        view
                            .onHover { hovering in
                                if hovering {
                                    currentRating = index
                                } else {
                                    currentRating = 0
                                }
                            }
                    }
            }
        }
        .drawingGroup()
    }
    
    // MARK: - Private Methods
    /// 星のイメージ名を取得
    private func starImageName(for index: Int) -> String {
        let effectiveRating = isEditable && currentRating > 0 ? currentRating : rating
        
        if index <= effectiveRating {
            return "star.fill"
        } else if index == effectiveRating + 1 {
            return "star.lefthalf.fill"
        } else {
            return "star"
        }
    }
    
    /// 星の色を取得
    private func starColor(for index: Int) -> Color {
        let effectiveRating = isEditable && currentRating > 0 ? currentRating : rating
        
        if index <= effectiveRating {
            return color
        } else {
            return Color.gray.opacity(0.3)
        }
    }
    
    /// 星のスケールを取得
    private func starScale(for index: Int) -> CGFloat {
        let effectiveRating = isEditable && currentRating > 0 ? currentRating : rating
        
        if isEditable && currentRating > 0 && index <= currentRating {
            return 1.2
        } else {
            return 1.0
        }
    }
}

// MARK: - HeartRatingView
/// ハート評価コンポーネント
struct HeartRatingView: View {
    // MARK: - Properties
    @Binding private var rating: Int
    private let maxRating: Int
    private let color: Color
    private let spacing: CGFloat
    private let size: CGFloat
    private let isEditable: Bool
    private let onRatingChanged: ((Int) -> Void)?
    @State private var currentRating: Int = 0
    
    // MARK: - Initialization
    /// ハート評価ビューを初期化
    /// - Parameters:
    ///   - rating: 評価値
    ///   - maxRating: 最大評価値（デフォルト: 5）
    ///   - color: ハートの色（デフォルト: 赤）
    ///   - spacing: ハートの間隔（デフォルト: 4）
    ///   - size: ハートのサイズ（デフォルト: 24）
    ///   - isEditable: 編集可能かどうか（デフォルト: true）
    ///   - onRatingChanged: 評価変更コールバック
    init(
        rating: Binding<Int>,
        maxRating: Int = 5,
        color: Color = .red,
        spacing: CGFloat = 4,
        size: CGFloat = 24,
        isEditable: Bool = true,
        onRatingChanged: ((Int) -> Void)? = nil
    ) {
        self._rating = rating
        self.maxRating = maxRating
        self.color = color
        self.spacing = spacing
        self.size = size
        self.isEditable = isEditable
        self.onRatingChanged = onRatingChanged
    }
    
    // MARK: - Body
    var body: some View {
        HStack(spacing: spacing) {
            ForEach(1...maxRating, id: \.self) { index in
                Image(systemName: heartImageName(for: index))
                    .font(.system(size: size, weight: .medium))
                    .foregroundStyle(heartColor(for: index))
                    .scaleEffect(heartScale(for: index))
                    .symbolEffect(.bounce, value: rating)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: rating)
                    .if(isEditable) { view in
                        view
                            .onTapGesture {
                                rating = index
                                onRatingChanged?(index)
                            }
                    }
                    .if(isEditable) { view in
                        view
                            .onHover { hovering in
                                if hovering {
                                    currentRating = index
                                } else {
                                    currentRating = 0
                                }
                            }
                    }
            }
        }
        .drawingGroup()
    }
    
    // MARK: - Private Methods
    /// ハートのイメージ名を取得
    private func heartImageName(for index: Int) -> String {
        let effectiveRating = isEditable && currentRating > 0 ? currentRating : rating
        
        if index <= effectiveRating {
            return "heart.fill"
        } else {
            return "heart"
        }
    }
    
    /// ハートの色を取得
    private func heartColor(for index: Int) -> Color {
        let effectiveRating = isEditable && currentRating > 0 ? currentRating : rating
        
        if index <= effectiveRating {
            return color
        } else {
            return Color.gray.opacity(0.3)
        }
    }
    
    /// ハートのスケールを取得
    private func heartScale(for index: Int) -> CGFloat {
        let effectiveRating = isEditable && currentRating > 0 ? currentRating : rating
        
        if isEditable && currentRating > 0 && index <= currentRating {
            return 1.2
        } else {
            return 1.0
        }
    }
}

// MARK: - ThumbRatingView
/// サムズアップ評価コンポーネント
struct ThumbRatingView: View {
    // MARK: - Properties
    @Binding private var rating: Int
    private let positiveColor: Color
    private let negativeColor: Color
    private let size: CGFloat
    private let isEditable: Bool
    private let onRatingChanged: ((Int) -> Void)?
    @State private var isPositivePressed: Bool = false
    @State private var isNegativePressed: Bool = false
    
    // MARK: - Initialization
    /// サムズアップ評価ビューを初期化
    /// - Parameters:
    ///   - rating: 評価値（-1: 不賛成, 0: なし, 1: 賛成）
    ///   - positiveColor: 賛成の色（デフォルト: 緑）
    ///   - negativeColor: 不賛成の色（デフォルト: 赤）
    ///   - size: アイコンサイズ（デフォルト: 32）
    ///   - isEditable: 編集可能かどうか（デフォルト: true）
    ///   - onRatingChanged: 評価変更コールバック
    init(
        rating: Binding<Int>,
        positiveColor: Color = .green,
        negativeColor: Color = .red,
        size: CGFloat = 32,
        isEditable: Bool = true,
        onRatingChanged: ((Int) -> Void)? = nil
    ) {
        self._rating = rating
        self.positiveColor = positiveColor
        self.negativeColor = negativeColor
        self.size = size
        self.isEditable = isEditable
        self.onRatingChanged = onRatingChanged
    }
    
    // MARK: - Body
    var body: some View {
        HStack(spacing: 24) {
            // 不賛成
            Button(action: {
                if isEditable {
                    rating = rating == -1 ? 0 : -1
                    onRatingChanged?(rating)
                }
            }) {
                Image(systemName: "hand.thumbsdown.fill")
                    .font(.system(size: size, weight: .medium))
                    .foregroundStyle(negativeColor)
                    .opacity(rating == -1 ? 1.0 : 0.3)
                    .scaleEffect(rating == -1 ? 1.2 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: rating)
            }
            .buttonStyle(ScaleButtonStyle(scale: 0.9))
            .disabled(!isEditable)
            
            // 賛成
            Button(action: {
                if isEditable {
                    rating = rating == 1 ? 0 : 1
                    onRatingChanged?(rating)
                }
            }) {
                Image(systemName: "hand.thumbsup.fill")
                    .font(.system(size: size, weight: .medium))
                    .foregroundStyle(positiveColor)
                    .opacity(rating == 1 ? 1.0 : 0.3)
                    .scaleEffect(rating == 1 ? 1.2 : 1.0)
                    .symbolEffect(.bounce, value: rating)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: rating)
            }
            .buttonStyle(ScaleButtonStyle(scale: 0.9))
            .disabled(!isEditable)
        }
        .drawingGroup()
    }
}

// MARK: - EmojiRatingView
/// 絵文字評価コンポーネント
struct EmojiRatingView: View {
    // MARK: - Properties
    @Binding private var rating: Int
    private let emojis: [String]
    private let spacing: CGFloat
    private let size: CGFloat
    private let isEditable: Bool
    private let onRatingChanged: ((Int) -> Void)?
    @State private var currentRating: Int = 0
    
    // MARK: - Initialization
    /// 絵文字評価ビューを初期化
    /// - Parameters:
    ///   - rating: 評価値（1-5）
    ///   - emojis: 絵文字配列（デフォルト: 5段階評価）
    ///   - spacing: 絵文字の間隔（デフォルト: 8）
    ///   - size: 絵文字サイズ（デフォルト: 32）
    ///   - isEditable: 編集可能かどうか（デフォルト: true）
    ///   - onRatingChanged: 評価変更コールバック
    init(
        rating: Binding<Int>,
        emojis: [String] = ["😢", "😕", "😐", "🙂", "😄"],
        spacing: CGFloat = 8,
        size: CGFloat = 32,
        isEditable: Bool = true,
        onRatingChanged: ((Int) -> Void)? = nil
    ) {
        self._rating = rating
        self.emojis = emojis
        self.spacing = spacing
        self.size = size
        self.isEditable = isEditable
        self.onRatingChanged = onRatingChanged
    }
    
    // MARK: - Body
    var body: some View {
        HStack(spacing: spacing) {
            ForEach(1...emojis.count, id: \.self) { index in
                Text(emojis[index - 1])
                    .font(.system(size: size))
                    .opacity(emojiOpacity(for: index))
                    .scaleEffect(emojiScale(for: index))
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: rating)
                    .if(isEditable) { view in
                        view
                            .onTapGesture {
                                rating = index
                                onRatingChanged?(index)
                            }
                    }
            }
        }
        .drawingGroup()
    }
    
    // MARK: - Private Methods
    /// 絵文字の不透明度を取得
    private func emojiOpacity(for index: Int) -> Double {
        if index <= rating {
            return 1.0
        } else {
            return 0.3
        }
    }
    
    /// 絵文字のスケールを取得
    private func emojiScale(for index: Int) -> CGFloat {
        if index == rating {
            return 1.3
        } else if index < rating {
            return 1.0
        } else {
            return 1.0
        }
    }
}

// MARK: - SwiftUI Previews
#Preview("StarRatingView - Basic") {
    VStack(spacing: 20) {
        StarRatingView(
            rating: .constant(3),
            title: "評価"
        )
        
        StarRatingView(
            rating: .constant(4),
            maxRating: 5,
            color: .orange,
            size: 32
        )
        
        StarRatingView(
            rating: .constant(2),
            maxRating: 3,
            color: .purple,
            size: 28
        )
    }
    .padding()
}

#Preview("StarRatingView - Color Variations") {
    VStack(spacing: 20) {
        StarRatingView(rating: .constant(4), color: .yellow)
        StarRatingView(rating: .constant(4), color: .orange)
        StarRatingView(rating: .constant(4), color: .pink)
        StarRatingView(rating: .constant(4), color: .blue)
    }
    .padding()
}

#Preview("HeartRatingView") {
    VStack(spacing: 20) {
        HeartRatingView(rating: .constant(3))
        
        HeartRatingView(
            rating: .constant(5),
            color: .pink,
            size: 32
        )
        
        HeartRatingView(
            rating: .constant(2),
            maxRating: 3,
            color: .red,
            size: 28
        )
    }
    .padding()
}

#Preview("ThumbRatingView") {
    VStack(spacing: 20) {
        ThumbRatingView(rating: .constant(1))
        
        ThumbRatingView(
            rating: .constant(-1),
            positiveColor: .blue,
            negativeColor: .orange
        )
        
        ThumbRatingView(
            rating: .constant(0),
            positiveColor: .green,
            negativeColor: .red,
            size: 40
        )
    }
    .padding()
}

#Preview("EmojiRatingView") {
    VStack(spacing: 20) {
        EmojiRatingView(rating: .constant(3))
        
        EmojiRatingView(
            rating: .constant(4),
            emojis: ["🌟", "⭐", "✨", "💫", "🌙"],
            size: 28
        )
        
        EmojiRatingView(
            rating: .constant(2),
            emojis: ["😡", "😠", "😐", "🙂", "😍"],
            size: 36
        )
    }
    .padding()
}

#Preview("All Rating Views") {
    ScrollView {
        VStack(spacing: 32) {
            Text("Rating Components")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Star Rating")
                    .font(.headline)
                StarRatingView(rating: .constant(4))
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Heart Rating")
                    .font(.headline)
                HeartRatingView(rating: .constant(3))
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Thumb Rating")
                    .font(.headline)
                ThumbRatingView(rating: .constant(1))
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Emoji Rating")
                    .font(.headline)
                EmojiRatingView(rating: .constant(3))
            }
        }
        .padding()
    }
}

// MARK: - Helper Extension
extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
