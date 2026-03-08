import Foundation
import SwiftUI

/// ナビゲーション状態管理のViewModel
/// SOUL.mdのビジョン「人は入力しない」を実現 - ナビゲーション状態の自動保存
@MainActor
class NavigationViewModel: ObservableObject {
    static let shared = NavigationViewModel()
    
    @Published var selectedTab: Int = 0 {
        didSet {
            // デバウンス後に状態を保存
            debounceSaveNavigationState()
        }
    }
    
    @Published var isNavigationRestoring = false
    @Published var isSavingState = false
    
    private let persistence = PersistenceService.shared
    private var saveTask: Task<Void, Never>?
    private let debounceDelay: TimeInterval = 0.5 // 0.5秒のデバウンス
    
    private init() {}
    
    // MARK: - Navigation State
    
    /// ナビゲーション状態を復元
    func restoreNavigationState() async {
        isNavigationRestoring = true
        defer { isNavigationRestoring = false }
        
        do {
            let state = try await persistence.loadNavigationState()
            // アニメーションなしでタブを変更（復元時）
            withAnimation(.none) {
                selectedTab = state.selectedTab
            }
        } catch {
            print("Failed to load navigation state: \(error)")
        }
    }
    
    // MARK: - Debounce Save
    
    /// デバウンスを使用してナビゲーション状態を保存
    private func debounceSaveNavigationState() {
        // 前のタスクをキャンセル
        saveTask?.cancel()
        
        // 新しいタスクを作成
        saveTask = Task {
            try? await Task.sleep(nanoseconds: UInt64(debounceDelay * 1_000_000_000))
            
            if !Task.isCancelled {
                await saveNavigationState()
            }
        }
    }
    
    /// ナビゲーション状態を保存
    private func saveNavigationState() async {
        isSavingState = true
        defer { isSavingState = false }
        
        let state = NavigationState(selectedTab: selectedTab)
        
        do {
            try await persistence.saveNavigationState(state)
        } catch {
            print("Failed to save navigation state: \(error)")
        }
    }
    
    /// 即時にナビゲーション状態を保存（アプリバックグラウンド時など）
    func saveNavigationStateImmediately() async {
        // デバウンス中のタスクをキャンセルして即時保存
        saveTask?.cancel()
        await saveNavigationState()
    }
    
    // MARK: - Tab State
    
    /// 各タブの状態を取得
    func tabState(for tab: Int) async -> TabState? {
        do {
            let state = try await persistence.loadNavigationState()
            return state.tabStates[tab]
        } catch {
            return nil
        }
    }
    
    /// 各タブの状態を保存
    func saveTabState(_ tabState: TabState, for tab: Int) async {
        do {
            var state = try await persistence.loadNavigationState()
            state.tabStates[tab] = tabState
            state.lastUpdateTime = Date()
            try await persistence.saveNavigationState(state)
        } catch {
            print("Failed to save tab state: \(error)")
        }
    }
}
