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
        .drawingGroup()
        .accessibilityElement(children: .combine)
        .accessibilityLabel(message ?? "読み込み中")
        .accessibilityAddTraits(.updatesFrequently)
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
        .drawingGroup()
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
        .drawingGroup()
    }
}

/// スケルトンローディングビュー（コンテンツプレースホルダー）
struct SkeletonLoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // タイトル用スケルトン
            SkeletonView(width: 240, height: 24, cornerRadius: 12)

            // 本文用スケルトン
            SkeletonView(width: 300, height: 16, cornerRadius: 8)
            SkeletonView(width: 270, height: 16, cornerRadius: 8)
            SkeletonView(width: 210, height: 16, cornerRadius: 8)

            // メタデータ用スケルトン
            HStack {
                SkeletonView(width: 90, height: 14, cornerRadius: 7)
                Spacer()
                SkeletonView(width: 60, height: 14, cornerRadius: 7)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
        .drawingGroup()
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
        .drawingGroup()
    }
}
