import Foundation
import Supabase

/// Supabaseクライアント管理
/// SOUL.mdのビジョン「採用や案件は副産物」を実現 - 学習ログを資産化
actor SupabaseManager {
    static let shared = SupabaseManager()
    
    private(set) var client: SupabaseClient!
    
    private init() {
        // Info.plistからSupabase URLとKeyを取得
        guard let supabaseURLString = Bundle.main.object(forInfoDictionaryKey: "SupabaseURL") as? String,
              let supabaseURL = URL(string: supabaseURLString),
              let supabaseKey = Bundle.main.object(forInfoDictionaryKey: "SupabaseAnonKey") as? String,
              !supabaseURLString.isEmpty,
              !supabaseKey.isEmpty else {
            fatalError("Supabase URL and Anon Key must be set in Info.plist")
        }

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
