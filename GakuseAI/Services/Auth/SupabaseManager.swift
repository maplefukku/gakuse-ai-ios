import Foundation
import Supabase

/// Supabaseクライアント管理
/// SOUL.mdのビジョン「採用や案件は副産物」を実現 - 学習ログを資産化
actor SupabaseManager {
    static let shared = SupabaseManager()
    
    private(set) var client: SupabaseClient!
    
    private init() {
        // TODO: 環境変数から取得するように変更
        let supabaseURL = URL(string: "https://YOUR_PROJECT.supabase.co")!
        let supabaseKey = "YOUR_ANON_KEY"
        
        client = SupabaseClient(
            supabaseURL: supabaseURL,
            supabaseKey: supabaseKey
        )
    }
    
    /// 現在のセッションを取得
    var currentSession: Session? {
        get async throws {
            try await client.auth.session
        }
    }
    
    /// 現在のユーザーを取得
    var currentUser: User? {
        get async {
            try? await client.auth.session.user
        }
    }
    
    /// ログイン状態確認
    var isAuthenticated: Bool {
        get async {
            do {
                _ = try await client.auth.session
                return true
            } catch {
                return false
            }
        }
    }
}
