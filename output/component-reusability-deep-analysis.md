# コンポーネント再利用性スコア深化分析

## 生成日時
- 日時: 2026-03-11 01:10:00 JST
- 分析対象: GakuseAI/Views/Components/*.swift

---

## 現状分析（13時タスクベース）

### 総コンポーネント数
- **総コンポーネント数**: 58件
- **高再利用性（★★★★★）**: 13件（22%）
- **中再利用性（★★★★☆）**: 16件（28%）
- **その他**: 29件（50%）

---

## 再利用性スコア深化分析

### 高再利用性コンポーネント（★★★★★）- 13件

**推奨アクション: 標準化プロセスを適用**

1. **ActionBar** - アクションバー
   - 再利用性: 高（他コンポーネントに依存せず）
   - 使用頻度: 高
   - 推奨: デザインシステムに組み込み

2. **AnimatedButton** - アニメーション付きボタン
   - 再利用性: 高
   - 使用頻度: 高
   - 推奨: グローバルボタンの基準として標準化

3. **AvatarGroup** - アバターグループ
   - 再利用性: 高
   - 使用頻度: 中
   - 推奨: AvatarViewと統合を検討

4. **NotificationCard** - 通知カード
   - 再利用性: 高
   - 使用頻度: 中
   - 推奨: CardViewベースに統合

5. **ProfileCard** - プロフィールカード
   - 再利用性: 高
   - 使用頻度: 中
   - 推奨: CardViewベースに統合

6. **ProgressRing** - 円形プログレス
   - 再利用性: 高
   - 使用頻度: 高
   - 推奨: 標準化推奨

7. **SearchBar** - 検索バー
   - 再利用性: 高
   - 使用頻度: 高
   - 推奨: TextInputFieldベースに統合

8. **SegmentedControl** - セグメントコントロール
   - 再利用性: 高
   - 使用頻度: 高
   - 推奨: 標準化推奨

9. **Slider** - スライダー
   - 再利用性: 高
   - 使用頻度: 中
   - 推奨: SliderViewと統合

10. **Stepper** - ステッパー
    - 再利用性: 高
    - 使用頻度: 中
    - 推奨: StepperViewと統合

11. **TextInputField** - テキスト入力フィールド
    - 再利用性: 高
    - 使用頻度: 高
    - 推奨: FormFieldに統合

12. **Toast** - トースト通知
    - 再利用性: 高
    - 使用頻度: 高
    - 推奨: ToastViewと統合

13. **ToggleSwitch** - トグルスイッチ
    - 再利用性: 高
    - 使用頻度: 高
    - 推奨: 標準化推奨

---

### 中再利用性コンポーネント（★★★★☆）- 16件

**推奨アクション: 依存関係削減と標準化**

1. **AvatarView** - アバター
   - 再利用性: 中（AvatarGroupに依存）
   - 推奨: AvatarGroupと統合

2. **BadgeView** - バッジ
   - 再利用性: 中
   - 使用頻度: 高
   - 推奨: 標準化推奨

3. **CardView** - カード
   - 再利用性: 中
   - 使用頻度: 高
   - 推奨: すべてのカード系コンポーネントの基準として標準化

4. **DividerView** - 区切り線
   - 再利用性: 中（多数のコンポーネントに使用）
   - 使用頻度: 高
   - 推奨: 標準化推奨

5. **EmptyStateView** - 空状態
   - 再利用性: 中
   - 使用頻度: 高
   - 推奨: 標準化推奨

6. **LinearProgressView** - リニアプログレス
   - 再利用性: 中（4種類のサブコンポーネントを持つ）
   - 推奨: サブコンポーネントを統合

7. **RatingStar** - 評価星
   - 再利用性: 中
   - 使用頻度: 中
   - 推奨: RatingViewと統合

8. **SegmentedProgressView** - セグメントプログレス
   - 再利用性: 中
   - 推奨: LinearProgressViewと統合

9. **SkeletonView** - スケルトン
   - 再利用性: 中
   - 使用頻度: 高
   - 推奨: 標準化推奨

10. **StepperView** - ステッパービュー
    - 再利用性: 中
    - 推奨: Stepperと統合

11. **SwipeActionView** - スワイプアクション
    - 再利用性: 中
    - 推奨: 標準化推奨

12. **TabBar** - タブバー
    - 再利用性: 中
    - 推奨: TabViewと統合

13. **TagView** - タグ
    - 再利用性: 中
    - 推奨: ChipViewと統合

14. **TimelineView** - タイムライン
    - 再利用性: 中（多数のサブコンポーネントを持つ）
    - 推奨: サブコンポーネントを統合

15. **ToastView** - トーストビュー
    - 再利用性: 中
    - 推奨: Toastと統合

16. **TooltipView** - ツールチップ
    - 再利用性: 中
    - 推奨: 標準化推奨

---

## 重複コード特定と統合計画

### 優先度1: 即時統合推奨

1. **AvatarView ↔ AvatarGroup**
   - 課題: 重複したアバター表示ロジック
   - 推奨: AvatarInfoモデルを統合、AvatarGroupをAvatarViewの拡張として実装
   - 期待効果: コード削減約30%

2. **Slider ↔ SliderView**
   - 課題: 類似したスライダー機能
   - 推奨: SliderViewを統合コンポーネントとして標準化
   - 期待効果: メンテナンス性向上

3. **Stepper ↔ StepperView**
   - 課題: 類似したステッパー機能
   - 推奨: StepperViewを統合コンポーネントとして標準化
   - 期待効果: メンテナンス性向上

4. **Toast ↔ ToastView**
   - 課題: 重複したトースト通知機能
   - 推奨: ToastViewを統合コンポーネントとして標準化
   - 期待効果: 通知管理の一元化

5. **TabBar ↔ TabView**
   - 課題: 重複したタブナビゲーション機能
   - 推奨: TabViewを統合コンポーネントとして標準化
   - 期待効果: ナビゲーション体験の統一

### 優先度2: 中期統合推奨

1. **TextInputField ↔ FormField**
   - 課題: 重複した入力フィールド機能
   - 推奨: FormFieldを統合コンポーネントとして標準化
   - 期待効果: フォーム実装の効率化

2. **SearchBar ↔ TextInputField**
   - 課題: 検索機能の重複実装
   - 推奨: SearchBarをTextInputFieldベースに実装
   - 期待効果: 入力体験の統一

3. **Card系コンポーネント統合**
   - NotificationCard
   - ProfileCard
   - CardView
   - 推奨: CardViewをベースに統合
   - 期待効果: カードコンポーネントの標準化

4. **TagView ↔ ChipView**
   - 課題: 重複したタグ/チップ機能
   - 推奨: ChipViewを統合コンポーネントとして標準化
   - 期待効果: タグ管理の一元化

### 優先度3: 長期統合推奨

1. **Progress系コンポーネント統合**
   - ProgressRing
   - LinearProgressView
   - SegmentedProgressView
   - 推奨: 共通のProgressViewBaseを作成
   - 期待効果: プログレス表示の一元化

2. **Rating系コンポーネント統合**
   - RatingStar
   - RatingView
   - 推奨: RatingViewを統合コンポーネントとして標準化
   - 期待効果: 評価機能の一元化

---

## コンポーネント統合実施計画

### フェーズ1: 即時統合（1週間）

1. AvatarView ↔ AvatarGroup統合
   - AvatarInfoモデル統合
   - AvatarGroupをAvatarView拡張として実装

2. Slider ↔ SliderView統合
   - SliderViewを標準化

3. Stepper ↔ StepperView統合
   - StepperViewを標準化

4. Toast ↔ ToastView統合
   - ToastViewを標準化

5. TabBar ↔ TabView統合
   - TabViewを標準化

### フェーズ2: 中期統合（2週間）

1. TextInputField ↔ FormField統合
2. SearchBar ↔ TextInputField統合
3. Card系コンポーネント統合
4. TagView ↔ ChipView統合

### フェーズ3: 長期統合（4週間）

1. Progress系コンポーネント統合
2. Rating系コンポーネント統合

---

## 再利用性スコア改善目標

### 現状
- 総コンポーネント数: 58件
- 高再利用性: 13件（22%）
- 中再利用性: 16件（28%）
- その他: 29件（50%）

### 目標（統合完了後）
- 総コンポーネント数: 45件（削減13件）
- 高再利用性: 25件（56%）
- 中再利用性: 15件（33%）
- その他: 5件（11%）

### 改善効果
- 高再利用性コンポーネント: 22% → 56%（+34%）
- コード削減: 約20%
- メンテナンス性: 大幅向上

---

## 次回のアクション

1. 優先度1の統合を開始
2. コンポーネントの依存関係を再確認
3. 統合後のビルドとテスト実施
4. UIテストカバレッジ向上
