import Foundation
import SwiftUI

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var userProfile: UserProfile?
    @Published var isLoading = false
    
    private let persistenceService = PersistenceService.shared
    
    init() {
        Task {
            await loadProfile()
        }
    }
    
    func loadProfile() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            userProfile = try await persistenceService.loadUserProfile()
            
            // 初回はデフォルトプロファイルを作成
            if userProfile == nil {
                let newProfile = UserProfile(name: "ユーザー")
                try await persistenceService.saveUserProfile(newProfile)
                userProfile = newProfile
            }
        } catch {
            print("プロファイル読み込みエラー: \(error)")
        }
    }
    
    func updateProfile(name: String) async {
        guard var profile = userProfile else { return }
        
        profile.name = name
        
        do {
            try await persistenceService.saveUserProfile(profile)
            userProfile = profile
        } catch {
            print("プロファイル保存エラー: \(error)")
        }
    }
    
    func updateSettings(_ settings: UserSettings) async {
        guard var profile = userProfile else { return }
        
        profile.settings = settings
        
        do {
            try await persistenceService.saveUserProfile(profile)
            userProfile = profile
        } catch {
            print("設定保存エラー: \(error)")
        }
    }
}
