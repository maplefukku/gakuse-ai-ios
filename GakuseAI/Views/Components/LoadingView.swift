import SwiftUI

/// ローディング状態のUIコンポーネント
/// SOUL.mdのビジョン「学習ログを資産化」を実現 - ローディング中もUXを維持
struct LoadingView: View {
    let message: String?
    
    init(message: String? = nil) {
        self.message = message
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // ローディングスピナー
            ProgressView()
                .scaleEffect(1.5)
                .progressViewStyle(CircularProgressViewStyle(tint: .pink))
            
            // メッセージ
            if let message = message {
                Text(message)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemBackground))
    }
}

/// プルツーリフレッシュ用のローディングビュー
struct PullToRefreshLoadingView: View {
    let isLoading: Bool
    let message: String?
    
    var body: some View {
        HStack(spacing: 12) {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .pink))
            }
            
            if let message = message {
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}

/// アクションのローディングボタン
struct LoadingButton: View {
    let title: String
    let isLoading: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Text(title)
                        .font(.headline)
                }
            }
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isLoading ? Color.gray : Color.pink)
            )
            .disabled(isLoading)
        }
    }
}

/// スケルトンローディングビュー（コンテンツプレースホルダー）
struct SkeletonLoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // タイトル用スケルトン
            SkeletonRow(widthRatio: 0.8, height: 24)
            
            // 本文用スケルトン
            SkeletonRow(widthRatio: 1.0, height: 16)
            SkeletonRow(widthRatio: 0.9, height: 16)
            SkeletonRow(widthRatio: 0.7, height: 16)
            
            // メタデータ用スケルトン
            HStack {
                SkeletonRow(widthRatio: 0.3, height: 14)
                Spacer()
                SkeletonRow(widthRatio: 0.2, height: 14)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
        .onAppear {
            withAnimation(
                Animation
                    .easeInOut(duration: 1.5)
                    .repeatForever()
            ) {
                isAnimating = true
            }
        }
    }
}

/// スケルトン行
struct SkeletonRow: View {
    let widthRatio: CGFloat
    let height: CGFloat
    @State private var isAnimating = false
    
    var body: some View {
        GeometryReader { geometry in
            RoundedRectangle(cornerRadius: 4)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(UIColor.systemGray4),
                            Color(UIColor.systemGray5),
                            Color(UIColor.systemGray4)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(
                    width: geometry.size.width * widthRatio,
                    height: height
                )
                .offset(x: isAnimating ? geometry.size.width : -geometry.size.width)
                .onAppear {
                    withAnimation(
                        Animation
                            .easeInOut(duration: 1.5)
                            .repeatForever()
                    ) {
                        isAnimating = true
                    }
                }
        }
        .frame(height: height)
    }
}

/// リスト用スケルトン
struct ListSkeletonView: View {
    let count: Int
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(0..<count, id: \.self) { _ in
                SkeletonLoadingView()
            }
        }
        .padding()
    }
}

/// インラインローディングインジケーター
struct InlineLoadingIndicator: View {
    let message: String?
    
    var body: some View {
        HStack(spacing: 8) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .pink))
                .scaleEffect(0.8)
            
            if let message = message {
                Text(message)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(8)
    }
}

// MARK: - Preview

#Preview("Loading View") {
    LoadingView(message: "読み込み中...")
}

#Preview("Loading Button") {
    LoadingButton(
        title: "保存",
        isLoading: false,
        action: {}
    )
    .padding()
}

#Preview("Skeleton Loading View") {
    SkeletonLoadingView()
    .padding()
}

#Preview("List Skeleton View") {
    ListSkeletonView(count: 5)
}

#Preview("Inline Loading Indicator") {
    InlineLoadingIndicator(message: "保存中...")
}
