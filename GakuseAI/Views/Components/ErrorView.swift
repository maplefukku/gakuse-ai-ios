import SwiftUI

/// エラー画面のUIコンポーネント
/// SOUL.mdのビジョン「学習ログを資産化」を実現 - エラー時もユーザーをサポート
struct ErrorView: View {
    let error: Error
    let onRetry: (() -> Void)?
    let onUseCachedData: (() -> Void)?
    
    @Environment(\.colorScheme) var colorScheme
    
    init(error: Error, onRetry: (() -> Void)? = nil, onUseCachedData: (() -> Void)? = nil) {
        self.error = error
        self.onRetry = onRetry
        self.onUseCachedData = onUseCachedData
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // エラーアイコン
            Image(systemName: errorIcon)
                .font(.system(size: 64))
                .foregroundColor(.pink)
                .symbolEffect(.pulse, options: .repeating)
            
            // エラータイトル
            Text("エラーが発生しました")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            // エラーメッセージ
            Text(error.localizedDescription)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // 再試行ボタン
            if let onRetry = onRetry {
                Button(action: onRetry) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("再試行")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.pink)
                    )
                    .shadow(color: Color.pink.opacity(0.3), radius: 5, x: 0, y: 2)
                }
                .padding(.horizontal)
                .buttonStyle(ScaleButtonStyle())
            }
            
            // キャッシュされたデータを使用するボタン
            if let onUseCachedData = onUseCachedData, canUseCachedData {
                Button(action: onUseCachedData) {
                    HStack {
                        Image(systemName: "arrow.down.doc")
                        Text("オフラインデータを使用")
                    }
                    .font(.subheadline)
                    .foregroundColor(.pink)
                    .padding(.vertical, 12)
                }
                .buttonStyle(ScaleButtonStyle())
            }
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(colorScheme == .dark ? Color.black : Color(UIColor.systemBackground))
    }
    
    private var errorIcon: String {
        if let apiError = error as? APIError {
            switch apiError {
            case .networkError, .offline:
                return "wifi.exclamationmark"
            case .unauthenticated:
                return "person.badge.exclamationmark"
            case .httpError:
                return "exclamationmark.triangle"
            case .timeout:
                return "hourglass"
            default:
                return "exclamationmark.circle"
            }
        }
        return "exclamationmark.circle"
    }
    
    private var canUseCachedData: Bool {
        if let apiError = error as? APIError {
            switch apiError {
            case .networkError, .offline, .timeout:
                return true
            default:
                return false
            }
        }
        return false
    }
}

/// ネットワークエラー用のコンポーネント
struct NetworkErrorView: View {
    let onRetry: () -> Void
    let onUseCachedData: (() -> Void)?
    
    init(onRetry: @escaping () -> Void, onUseCachedData: (() -> Void)? = nil) {
        self.onRetry = onRetry
        self.onUseCachedData = onUseCachedData
    }
    
    var body: some View {
        ErrorView(
            error: APIError.networkError(URLError(.notConnectedToInternet)),
            onRetry: onRetry,
            onUseCachedData: onUseCachedData
        )
    }
}

/// 認証エラー用のコンポーネント
struct AuthenticationErrorView: View {
    let onLogin: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "person.badge.exclamationmark")
                .font(.system(size: 64))
                .foregroundColor(.pink)
            
            Text("認証が必要です")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text("再度ログインしてください")
                .font(.body)
                .foregroundColor(.secondary)
            
            Button(action: onLogin) {
                HStack {
                    Image(systemName: "arrow.right.to.line")
                    Text("ログイン")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.pink)
                )
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// 空状態のコンポーネント
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let action: (() -> Void)?
    let actionTitle: String?
    
    init(icon: String, title: String, message: String, action: (() -> Void)? = nil, actionTitle: String? = nil) {
        self.icon = icon
        self.title = title
        self.message = message
        self.action = action
        self.actionTitle = actionTitle
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: icon)
                .font(.system(size: 64))
                .foregroundColor(.gray)
            
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            if let action = action, let actionTitle = actionTitle {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.pink)
                        )
                }
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Button Styles

/// スケールアニメーション付きのボタンスタイル
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview("Error View - Network Error") {
    ErrorView(
        error: APIError.networkError(URLError(.notConnectedToInternet)),
        onRetry: {},
        onUseCachedData: {}
    )
}

#Preview("Error View - Timeout") {
    ErrorView(
        error: APIError.timeout,
        onRetry: {}
    )
}

#Preview("Error View - Unauthenticated") {
    ErrorView(
        error: APIError.unauthenticated,
        onRetry: {}
    )
}

#Preview("Network Error View") {
    NetworkErrorView(
        onRetry: {},
        onUseCachedData: {}
    )
}

#Preview("Authentication Error View") {
    AuthenticationErrorView(onLogin: {})
}

#Preview("Empty State View") {
    EmptyStateView(
        icon: "book.closed",
        title: "学習ログがありません",
        message: "最初の学習ログを追加して始めましょう！",
        action: {},
        actionTitle: "追加"
    )
}
