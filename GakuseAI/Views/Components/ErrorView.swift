import SwiftUI

/// エラー画面のUIコンポーネント
/// SOUL.mdのビジョン「学習ログを資産化」を実現 - エラー時もユーザーをサポート
struct ErrorView: View {
    let error: Error
    let onRetry: (() -> Void)?
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 24) {
            // エラーアイコン
            Image(systemName: errorIcon)
                .font(.system(size: 64))
                .foregroundColor(.pink)
            
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
                }
                .padding(.horizontal)
            }
            
            // キャッシュされたデータを使用するボタン
            Button(action: {
                // キャッシュされたデータを使用する処理
            }) {
                Text("オフラインデータを使用")
                    .font(.subheadline)
                    .foregroundColor(.pink)
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
            case .networkError:
                return "wifi.exclamationmark"
            case .unauthenticated:
                return "person.badge.exclamationmark"
            case .httpError:
                return "exclamationmark.triangle"
            default:
                return "exclamationmark.circle"
            }
        }
        return "exclamationmark.circle"
    }
}

/// ネットワークエラー用のコンポーネント
struct NetworkErrorView: View {
    let onRetry: () -> Void
    
    var body: some View {
        ErrorView(
            error: APIError.networkError(URLError(.notConnectedToInternet)),
            onRetry: onRetry
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

#Preview("Error View") {
    ErrorView(
        error: APIError.networkError(URLError(.notConnectedToInternet)),
        onRetry: {}
    )
}

#Preview("Network Error View") {
    NetworkErrorView(onRetry: {})
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
