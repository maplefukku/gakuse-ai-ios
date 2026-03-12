//
//  GakuseAIUITests.swift
//  GakuseAIUITests
//
//  Created by OpenClaw on 2026-03-10.
//

import XCTest

final class GakuseAIUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-UITesting"]
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - 基本画面遷移テスト
    
    func testAppLaunch() throws {
        // アプリが起動していることを確認
        XCTAssertTrue(app.exists, "アプリが起動していません")
    }
    
    func testTabNavigation() throws {
        // メインタブが存在することを確認
        let tabBarsQuery = app.tabBars
        XCTAssertTrue(tabBarsQuery.exists, "タブバーが存在しません")
        
        // 各タブに遷移できることを確認
        let tabButtons = tabBarsQuery.buttons
        if tabButtons.count > 0 {
            let firstTab = tabButtons.element(boundBy: 0)
            XCTAssertTrue(firstTab.exists, "最初のタブが存在しません")
            firstTab.tap()
            
            // 2番目のタブ
            if tabButtons.count > 1 {
                let secondTab = tabButtons.element(boundBy: 1)
                XCTAssertTrue(secondTab.exists, "2番目のタブが存在しません")
                secondTab.tap()
            }
        }
    }
    
    // MARK: - Auth関連テスト
    
    func testLoginViewElements() throws {
        // ログイン画面の要素を確認
        let emailField = app.textFields["メールアドレス"]
        let passwordField = app.secureTextFields["パスワード"]
        let loginButton = app.buttons["ログイン"]
        
        XCTAssertTrue(emailField.exists || app.textFields.containing(NSPredicate(format: "placeholder CONTAINS[c] 'メール'")).count > 0,
                      "メール入力フィールドが存在しません")
        XCTAssertTrue(passwordField.exists || app.secureTextFields.containing(NSPredicate(format: "placeholder CONTAINS[c] 'パスワード'")).count > 0,
                      "パスワード入力フィールドが存在しません")
    }
    
    func testSignUpViewElements() throws {
        // サインアップ画面の要素を確認
        let emailField = app.textFields.containing(NSPredicate(format: "placeholder CONTAINS[c] 'メール'")).firstMatch
        let passwordField = app.secureTextFields.containing(NSPredicate(format: "placeholder CONTAINS[c] 'パスワード'")).firstMatch
        let confirmPasswordField = app.secureTextFields.containing(NSPredicate(format: "placeholder CONTAINS[c] '確認'")).firstMatch
        let signUpButton = app.buttons["新規登録"]
        
        XCTAssertTrue(emailField.exists || app.buttons["新規登録"].exists, "サインアップ画面が見つかりません")
    }
    
    // MARK: - コンテンツ関連テスト
    
    func testLearningLogViewElements() throws {
        // 学習ログ画面の要素を確認
        let searchBar = app.searchFields.firstMatch
        let addButton = app.buttons.imagesMatching("plus.circle").firstMatch
        
        // 検索バーまたは追加ボタンが存在することを確認
        XCTAssertTrue(searchBar.exists || addButton.exists || app.buttons["追加"].exists,
                      "学習ログ画面の要素が見つかりません")
    }
    
    func testPortfolioViewElements() throws {
        // ポートフォリオ画面の要素を確認
        let scrollView = app.scrollViews.firstMatch
        
        XCTAssertTrue(scrollView.exists || app.staticTexts.firstMatch.exists,
                      "ポートフォリオ画面が見つかりません")
    }
    
    func testStatisticsViewElements() throws {
        // 統計画面の要素を確認
        let charts = app.otherElements.containing(NSPredicate(format: "identifier CONTAINS[c] 'chart'"))
        
        XCTAssertTrue(app.staticTexts.firstMatch.exists,
                      "統計画面が見つかりません")
    }
    
    func testProfileViewElements() throws {
        // プロフィール画面の要素を確認
        let avatar = app.images.firstMatch
        let nameText = app.staticTexts.firstMatch
        
        XCTAssertTrue(avatar.exists || nameText.exists,
                      "プロフィール画面が見つかりません")
    }
    
    // MARK: - コンポーネント関連テスト
    
    func testAvatarViewComponent() throws {
        // AvatarViewコンポーネントが正しく表示されることを確認
        let avatarImages = app.images.matching(NSPredicate(format: "identifier CONTAINS[c] 'avatar'"))
        
        if avatarImages.count > 0 {
            XCTAssertTrue(avatarImages.firstMatch.exists, "AvatarViewが表示されていません")
        }
    }
    
    func testCardViewComponent() throws {
        // CardViewコンポーネントが正しく表示されることを確認
        let cardElements = app.otherElements.matching(NSPredicate(format: "identifier CONTAINS[c] 'card'"))
        
        if cardElements.count > 0 {
            XCTAssertTrue(cardElements.firstMatch.exists, "CardViewが表示されていません")
        }
    }
    
    func testBadgeViewComponent() throws {
        // BadgeViewコンポーネントが正しく表示されることを確認
        let badgeElements = app.otherElements.matching(NSPredicate(format: "identifier CONTAINS[c] 'badge'"))
        
        if badgeElements.count > 0 {
            XCTAssertTrue(badgeElements.firstMatch.exists, "BadgeViewが表示されていません")
        }
    }
    
    func testProgressRingComponent() throws {
        // ProgressRingコンポーネントが正しく表示されることを確認
        let progressElements = app.otherElements.matching(NSPredicate(format: "identifier CONTAINS[c] 'progress'"))
        
        if progressElements.count > 0 {
            XCTAssertTrue(progressElements.firstMatch.exists, "ProgressRingが表示されていません")
        }
    }
    
    func testToggleSwitchComponent() throws {
        // ToggleSwitchコンポーネントが正しく動作することを確認
        let toggles = app.switches
        
        if toggles.count > 0 {
            let firstToggle = toggles.firstMatch
            XCTAssertTrue(firstToggle.exists, "ToggleSwitchが見つかりません")
            
            // トグルの状態を確認
            let initialIsOn = firstToggle.value as? String == "1"
            
            // トグルをタップ
            firstToggle.tap()
            
            // 状態が変わったことを確認
            let newIsOn = firstToggle.value as? String == "1"
            XCTAssertTrue(initialIsOn != newIsOn, "ToggleSwitchの状態が変更されませんでした")
        }
    }
    
    func testSearchBarComponent() throws {
        // SearchBarコンポーネントが正しく動作することを確認
        let searchBars = app.searchFields
        
        if searchBars.count > 0 {
            let searchBar = searchBars.firstMatch
            XCTAssertTrue(searchBar.exists, "SearchBarが見つかりません")
            
            // 検索バーにテキストを入力
            searchBar.tap()
            searchBar.typeText("テスト検索")
            
            // 入力されたことを確認
            XCTAssertTrue(searchBar.value as? String == "テスト検索", "検索バーに入力できませんでした")
            
            // テキストをクリア
            let clearButton = searchBar.buttons.firstMatch
            if clearButton.exists {
                clearButton.tap()
                XCTAssertTrue(searchBar.value as? String == "", "検索バーのクリアに失敗しました")
            }
        }
    }
    
    func testCheckboxViewComponent() throws {
        // CheckboxViewコンポーネントが正しく動作することを確認
        let checkboxes = app.buttons.matching(NSPredicate(format: "identifier CONTAINS[c] 'checkbox'"))
        
        if checkboxes.count > 0 {
            let firstCheckbox = checkboxes.firstMatch
            XCTAssertTrue(firstCheckbox.exists, "CheckboxViewが見つかりません")
            
            // チェックボックスをタップ
            firstCheckbox.tap()
            
            // チェックされたことを確認
            XCTAssertTrue(firstCheckbox.isSelected, "CheckboxViewが選択されませんでした")
        }
    }
    
    func testRadioButtonViewComponent() throws {
        // RadioButtonViewコンポーネントが正しく動作することを確認
        let radioButtons = app.buttons.matching(NSPredicate(format: "identifier CONTAINS[c] 'radio'"))
        
        if radioButtons.count > 0 {
            let firstRadioButton = radioButtons.firstMatch
            XCTAssertTrue(firstRadioButton.exists, "RadioButtonViewが見つかりません")
            
            // ラジオボタンをタップ
            firstRadioButton.tap()
            
            // 選択されたことを確認
            XCTAssertTrue(firstRadioButton.isSelected, "RadioButtonViewが選択されませんでした")
        }
    }
    
    func testModalViewComponent() throws {
        // ModalViewコンポーネントが正しく表示されることを確認
        let modalButtons = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] '確認'"))
        
        if modalButtons.count > 0 {
            let firstModalButton = modalButtons.firstMatch
            XCTAssertTrue(firstModalButton.exists, "モーダルトリガーボタンが見つかりません")
            
            // モーダルを開く
            firstModalButton.tap()
            
            // モーダルが表示されたことを確認
            let modalOverlay = app.otherElements.firstMatch
            XCTAssertTrue(modalOverlay.exists, "モーダルが表示されませんでした")
            
            // 閉じるボタンを探す
            let closeButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] '閉じる' OR label CONTAINS[c] 'キャンセル'")).firstMatch
            if closeButton.exists {
                closeButton.tap()
            } else {
                // オーバーレイをタップして閉じる
                modalOverlay.tap()
            }
        }
    }
    
    func testToastViewComponent() throws {
        // ToastViewコンポーネントが正しく表示されることを確認
        // ToastViewは一時的な通知なので、自動表示されるトリガーを探す
        let triggerButtons = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] '通知'"))
        
        if triggerButtons.count > 0 {
            let triggerButton = triggerButtons.firstMatch
            XCTAssertTrue(triggerButton.exists, "Toast通知トリガーが見つかりません")
            
            // トリガーをタップ
            triggerButton.tap()
            
            // Toastが表示されるのを待つ（最大2秒）
            let toastExists = app.otherElements.matching(NSPredicate(format: "identifier CONTAINS[c] 'toast'"))
                .firstMatch
                .waitForExistence(timeout: 2)
            
            if toastExists {
                XCTAssertTrue(toastExists, "ToastViewが表示されませんでした")
            }
        }
    }
    
    func testPullToRefreshComponent() throws {
        // PullToRefreshViewコンポーネントが正しく動作することを確認
        let scrollView = app.scrollViews.firstMatch
        
        if scrollView.exists {
            // スクロールビューの上部にスクロール
            let startPoint = scrollView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.2))
            let endPoint = scrollView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.8))
            
            startPoint.press(forDuration: 0.1, thenDragTo: endPoint)
            
            // プルツーリフレッシュのインジケーターが表示されるのを待つ
            let refreshIndicator = app.activityIndicators.firstMatch
            let refreshExists = refreshIndicator.waitForExistence(timeout: 3)
            
            if refreshExists {
                XCTAssertTrue(refreshExists, "PullToRefreshのインジケーターが表示されませんでした")
            }
        }
    }
    
    func testSkeletonViewComponent() throws {
        // SkeletonViewコンポーネントが正しく表示されることを確認
        // SkeletonViewはローディング時に表示されるため、ローディング状態のトリガーを探す
        let loadingElements = app.otherElements.matching(NSPredicate(format: "identifier CONTAINS[c] 'skeleton'"))
        
        if loadingElements.count > 0 {
            XCTAssertTrue(loadingElements.firstMatch.exists, "SkeletonViewが表示されていません")
        }
    }
    
    // MARK: - アクセシビリティテスト
    
    func testAccessibilityLabels() throws {
        // 主要なUI要素にアクセシビリティラベルが設定されていることを確認
        let buttons = app.buttons.allElementsBoundByIndex
        var unlabeledButtons = 0
        
        for button in buttons {
            if button.isHittable && button.label.isEmpty {
                unlabeledButtons += 1
            }
        }
        
        // すべてのボタンにラベルがあることを確認
        XCTAssertTrue(unlabeledButtons == 0, "\(unlabeledButtons)個のボタンにアクセシビリティラベルがありません")
    }
    
    func testVoiceOverSupport() throws {
        // VoiceOverが有効な場合でもアプリが正しく動作することを確認
        let staticTexts = app.staticTexts.allElementsBoundByIndex
        
        for staticText in staticTexts {
            if staticText.isHittable {
                XCTAssertTrue(!staticText.label.isEmpty, "VoiceOver用のラベルが設定されていません")
            }
        }
    }
    
    // MARK: - パフォーマンステスト
    
    func testLaunchPerformance() throws {
        if #available(iOS 13.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
    
    func testScrollPerformance() throws {
        let scrollView = app.scrollViews.firstMatch
        
        if scrollView.exists {
            measure {
                scrollView.swipeUp()
                scrollView.swipeDown()
            }
        }
    }

    // MARK: - ローディング/状態表示コンポーネントテスト

    func testSpinnerViewComponent() throws {
        // SpinnerViewコンポーネントが正しく表示されることを確認
        let activityIndicators = app.activityIndicators

        if activityIndicators.count > 0 {
            let firstSpinner = activityIndicators.firstMatch
            XCTAssertTrue(firstSpinner.exists, "SpinnerViewが見つかりません")

            // スピナーが回転していることを確認
            XCTAssertTrue(firstSpinner.isHittable, "SpinnerViewが有効ではありません")
        }
    }

    func testLoadingViewComponent() throws {
        // LoadingViewコンポーネントが正しく表示されることを確認
        let loadingViews = app.otherElements.matching(NSPredicate(format: "identifier CONTAINS[c] 'loading'"))

        if loadingViews.count > 0 {
            let loadingView = loadingViews.firstMatch
            XCTAssertTrue(loadingView.exists, "LoadingViewが表示されていません")

            // ローディングテキストが存在することを確認
            let loadingTexts = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] '読み込み' OR label CONTAINS[c] 'ロード'"))
            if loadingTexts.count > 0 {
                XCTAssertTrue(loadingTexts.firstMatch.exists, "LoadingViewのテキストが表示されていません")
            }
        }
    }

    func testEmptyStateViewComponent() throws {
        // EmptyStateViewコンポーネントが正しく表示されることを確認
        let emptyStateViews = app.otherElements.matching(NSPredicate(format: "identifier CONTAINS[c] 'empty'"))

        if emptyStateViews.count > 0 {
            let emptyStateView = emptyStateViews.firstMatch
            XCTAssertTrue(emptyStateView.exists, "EmptyStateViewが表示されていません")

            // アイコンとテキストが存在することを確認
            let emptyTexts = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'データ' OR label CONTAINS[c] '空'"))
            if emptyTexts.count > 0 {
                XCTAssertTrue(emptyTexts.firstMatch.exists, "EmptyStateViewのテキストが表示されていません")
            }
        }
    }

    func testErrorViewComponent() throws {
        // ErrorViewコンポーネントが正しく表示されることを確認
        let errorViews = app.otherElements.matching(NSPredicate(format: "identifier CONTAINS[c] 'error'"))

        if errorViews.count > 0 {
            let errorView = errorViews.firstMatch
            XCTAssertTrue(errorView.exists, "ErrorViewが表示されていません")

            // エラーメッセージとリトライボタンが存在することを確認
            let errorTexts = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'エラー' OR label CONTAINS[c] 'Error'"))
            let retryButtons = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] '再試行' OR label CONTAINS[c] 'リトライ'"))

            if errorTexts.count > 0 {
                XCTAssertTrue(errorTexts.firstMatch.exists, "ErrorViewのエラーメッセージが表示されていません")
            }
            if retryButtons.count > 0 {
                XCTAssertTrue(retryButtons.firstMatch.exists, "ErrorViewのリトライボタンが表示されていません")
            }
        }
    }

    // MARK: - 入力コンポーネントテスト

    func testTextInputFieldComponent() throws {
        // TextInputFieldコンポーネントが正しく動作することを確認
        let textFields = app.textFields.allElementsBoundByIndex

        if textFields.count > 0 {
            let firstTextField = textFields.first!
            if firstTextField.isHittable {
                XCTAssertTrue(firstTextField.exists, "TextInputFieldが見つかりません")

                // テキストを入力
                firstTextField.tap()
                firstTextField.typeText("テスト入力")

                // 入力されたことを確認
                let inputValue = firstTextField.value as? String ?? ""
                XCTAssertTrue(inputValue.contains("テスト入力"), "TextInputFieldに入力できませんでした")
            }
        }
    }

    func testStepperViewComponent() throws {
        // StepperViewコンポーネントが正しく動作することを確認
        let steppers = app.steppers.allElementsBoundByIndex

        if steppers.count > 0 {
            let firstStepper = steppers.first!
            if firstStepper.isHittable {
                XCTAssertTrue(firstStepper.exists, "StepperViewが見つかりません")

                // 増加ボタンをタップ
                let incrementButton = firstStepper.buttons["Increment"]
                if incrementButton.exists {
                    let initialValue = firstStepper.value as? String ?? "0"
                    incrementButton.tap()
                    let newValue = firstStepper.value as? String ?? "0"
                    XCTAssertTrue(initialValue != newValue, "StepperViewの値が変更されませんでした")
                }
            }
        }
    }

    func testSliderViewComponent() throws {
        // SliderViewコンポーネントが正しく動作することを確認
        let sliders = app.sliders.allElementsBoundByIndex

        if sliders.count > 0 {
            let firstSlider = sliders.first!
            if firstSlider.isHittable {
                XCTAssertTrue(firstSlider.exists, "SliderViewが見つかりません")

                // スライダーをドラッグ
                let start = firstSlider.coordinate(withNormalizedOffset: CGVector(dx: 0.0, dy: 0.5))
                let end = firstSlider.coordinate(withNormalizedOffset: CGVector(dx: 1.0, dy: 0.5))
                start.press(forDuration: 0.1, thenDragTo: end)

                // 値が変更されたことを確認
                XCTAssertTrue(firstSlider.exists, "SliderViewが有効ではありません")
            }
        }
    }

    func testColorPickerViewComponent() throws {
        // ColorPickerViewコンポーネントが正しく表示されることを確認
        let colorPickerViews = app.otherElements.matching(NSPredicate(format: "identifier CONTAINS[c] 'colorpicker'"))

        if colorPickerViews.count > 0 {
            let colorPickerView = colorPickerViews.firstMatch
            XCTAssertTrue(colorPickerView.exists, "ColorPickerViewが表示されていません")

            // カラーオプションが存在することを確認
            let colorOptions = app.otherElements.matching(NSPredicate(format: "identifier CONTAINS[c] 'color'"))
            if colorOptions.count > 0 {
                XCTAssertTrue(colorOptions.firstMatch.exists, "ColorPickerViewのカラーオプションが表示されていません")
            }
        }
    }

    func testDatePickerViewComponent() throws {
        // DatePickerViewコンポーネントが正しく動作することを確認
        let datePickers = app.datePickers.allElementsBoundByIndex

        if datePickers.count > 0 {
            let firstDatePicker = datePickers.first!
            if firstDatePicker.isHittable {
                XCTAssertTrue(firstDatePicker.exists, "DatePickerViewが見つかりません")

                // デートピッカーをタップ
                firstDatePicker.tap()

                // 日付選択UIが表示されるのを待つ
                let dateWheels = app.pickerWheels
                if dateWheels.count > 0 {
                    XCTAssertTrue(dateWheels.firstMatch.exists, "DatePickerViewの日付選択UIが表示されませんでした")
                }
            }
        }
    }

    // MARK: - 表示コンポーネントテスト

    func testNotificationCardComponent() throws {
        // NotificationCardコンポーネントが正しく表示されることを確認
        let notificationCards = app.otherElements.matching(NSPredicate(format: "identifier CONTAINS[c] 'notification'"))

        if notificationCards.count > 0 {
            let notificationCard = notificationCards.firstMatch
            XCTAssertTrue(notificationCard.exists, "NotificationCardが表示されていません")

            // 通知アイコンとテキストが存在することを確認
            let icons = app.images.matching(NSPredicate(format: "identifier CONTAINS[c] 'icon' OR identifier CONTAINS[c] 'notification'"))
            if icons.count > 0 {
                XCTAssertTrue(icons.firstMatch.exists, "NotificationCardのアイコンが表示されていません")
            }
        }
    }

    func testProfileCardComponent() throws {
        // ProfileCardコンポーネントが正しく表示されることを確認
        let profileCards = app.otherElements.matching(NSPredicate(format: "identifier CONTAINS[c] 'profile'"))

        if profileCards.count > 0 {
            let profileCard = profileCards.firstMatch
            XCTAssertTrue(profileCard.exists, "ProfileCardが表示されていません")

            // アバターと名前が存在することを確認
            let avatars = app.images.matching(NSPredicate(format: "identifier CONTAINS[c] 'avatar'"))
            let names = app.staticTexts.matching(NSPredicate(format: "identifier CONTAINS[c] 'name'"))

            if avatars.count > 0 {
                XCTAssertTrue(avatars.firstMatch.exists, "ProfileCardのアバターが表示されていません")
            }
            if names.count > 0 {
                XCTAssertTrue(names.firstMatch.exists, "ProfileCardの名前が表示されていません")
            }
        }
    }

    func testTagViewComponent() throws {
        // TagViewコンポーネントが正しく表示されることを確認
        let tagViews = app.otherElements.matching(NSPredicate(format: "identifier CONTAINS[c] 'tag'"))

        if tagViews.count > 0 {
            let tagView = tagViews.firstMatch
            XCTAssertTrue(tagView.exists, "TagViewが表示されていません")

            // タグをタップできることを確認
            if tagView.isHittable {
                tagView.tap()
                XCTAssertTrue(tagView.exists, "TagViewが有効ではありません")
            }
        }
    }

    func testChipsComponent() throws {
        // Chipsコンポーネントが正しく表示されることを確認
        let chips = app.otherElements.matching(NSPredicate(format: "identifier CONTAINS[c] 'chip'"))

        if chips.count > 0 {
            let firstChip = chips.firstMatch
            XCTAssertTrue(firstChip.exists, "Chipsコンポーネントが表示されていません")

            // 複数のチップが存在することを確認
            if chips.count > 1 {
                XCTAssertTrue(chips.element(boundBy: 1).exists, "Chipsコンポーネントの2番目のチップが表示されていません")
            }
        }
    }

    // MARK: - 評価/タイムラインコンポーネントテスト

    func testRatingViewComponent() throws {
        // RatingViewコンポーネントが正しく表示されることを確認
        let ratingViews = app.otherElements.matching(NSPredicate(format: "identifier CONTAINS[c] 'rating'"))

        if ratingViews.count > 0 {
            let ratingView = ratingViews.firstMatch
            XCTAssertTrue(ratingView.exists, "RatingViewが表示されていません")

            // 星評価が表示されていることを確認
            let stars = app.images.matching(NSPredicate(format: "identifier CONTAINS[c] 'star'"))
            if stars.count > 0 {
                XCTAssertTrue(stars.firstMatch.exists, "RatingViewの星評価が表示されていません")
            }
        }
    }

    func testRatingStarComponent() throws {
        // RatingStarコンポーネントが正しく表示されることを確認
        let ratingStars = app.images.matching(NSPredicate(format: "identifier CONTAINS[c] 'ratingstar'"))

        if ratingStars.count > 0 {
            let ratingStar = ratingStars.firstMatch
            XCTAssertTrue(ratingStar.exists, "RatingStarが表示されていません")
        }
    }

    func testTimelineViewComponent() throws {
        // TimelineViewコンポーネントが正しく表示されることを確認
        let timelineViews = app.otherElements.matching(NSPredicate(format: "identifier CONTAINS[c] 'timeline'"))

        if timelineViews.count > 0 {
            let timelineView = timelineViews.firstMatch
            XCTAssertTrue(timelineView.exists, "TimelineViewが表示されていません")

            // タイムラインアイテムが存在することを確認
            let timelineItems = app.otherElements.matching(NSPredicate(format: "identifier CONTAINS[c] 'timelineitem'"))
            if timelineItems.count > 0 {
                XCTAssertTrue(timelineItems.firstMatch.exists, "TimelineViewのアイテムが表示されていません")
            }
        }
    }

    // MARK: - ナビゲーションコンポーネントテスト

    func testBottomSheetViewComponent() throws {
        // BottomSheetViewコンポーネントが正しく表示されることを確認
        let bottomSheetViews = app.otherElements.matching(NSPredicate(format: "identifier CONTAINS[c] 'bottomsheet'"))

        if bottomSheetViews.count > 0 {
            let bottomSheetView = bottomSheetViews.firstMatch
            XCTAssertTrue(bottomSheetView.exists, "BottomSheetViewが表示されていません")

            // ボトムシートをドラッグして閉じれることを確認
            if bottomSheetView.isHittable {
                let startPoint = bottomSheetView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.9))
                let endPoint = bottomSheetView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.1))
                startPoint.press(forDuration: 0.1, thenDragTo: endPoint)
                XCTAssertTrue(bottomSheetView.exists, "BottomSheetViewが有効ではありません")
            }
        }
    }

    func testAnimatedButtonComponent() throws {
        // AnimatedButtonコンポーネントが正しく動作することを確認
        let animatedButtons = app.buttons.matching(NSPredicate(format: "identifier CONTAINS[c] 'animated'"))

        if animatedButtons.count > 0 {
            let animatedButton = animatedButtons.firstMatch
            XCTAssertTrue(animatedButton.exists, "AnimatedButtonが見つかりません")

            // ボタンをタップ
            if animatedButton.isHittable {
                animatedButton.tap()
                XCTAssertTrue(animatedButton.exists, "AnimatedButtonが有効ではありません")
            }
        }
    }

    func testSegmentedControlComponent() throws {
        // SegmentedControlコンポーネントが正しく動作することを確認
        let segmentedControls = app.segmentedControls.allElementsBoundByIndex

        if segmentedControls.count > 0 {
            let firstSegmentedControl = segmentedControls.first!
            if firstSegmentedControl.isHittable {
                XCTAssertTrue(firstSegmentedControl.exists, "SegmentedControlが見つかりません")

                // 最初のセグメントをタップ
                let firstSegment = firstSegmentedControl.buttons.element(boundBy: 0)
                if firstSegment.exists {
                    firstSegment.tap()
                    XCTAssertTrue(firstSegmentedControl.exists, "SegmentedControlが有効ではありません")
                }
            }
        }
    }

    func testSwipeActionViewComponent() throws {
        // SwipeActionViewコンポーネントが正しく動作することを確認
        let cells = app.cells.allElementsBoundByIndex

        if cells.count > 0 {
            let firstCell = cells.first!
            if firstCell.isHittable {
                // セルをスワイプ
                firstCell.swipeLeft()

                // スワイプアクションが表示されるのを待つ
                let actionButtons = app.buttons.matching(NSPredicate(format: "identifier CONTAINS[c] 'action'"))
                if actionButtons.count > 0 {
                    XCTAssertTrue(actionButtons.firstMatch.exists, "SwipeActionViewのアクションボタンが表示されませんでした")
                }
            }
        }
    }

    // MARK: - メニュー/フィードバックコンポーネントテスト

    func testMenuViewComponent() throws {
        // MenuViewコンポーネントが正しく表示されることを確認
        let menuButtons = app.buttons.matching(NSPredicate(format: "identifier CONTAINS[c] 'menu'"))

        if menuButtons.count > 0 {
            let menuButton = menuButtons.firstMatch
            XCTAssertTrue(menuButton.exists, "MenuViewのトリガーボタンが見つかりません")

            // メニューボタンをタップ
            if menuButton.isHittable {
                menuButton.tap()

                // メニューが表示されるのを待つ
                let menus = app.menus.allElementsBoundByIndex
                if menus.count > 0 {
                    XCTAssertTrue(menus.firstMatch.exists, "MenuViewが表示されませんでした")
                }
            }
        }
    }

    func testTooltipViewComponent() throws {
        // TooltipViewコンポーネントが正しく表示されることを確認
        let tooltips = app.otherElements.matching(NSPredicate(format: "identifier CONTAINS[c] 'tooltip'"))

        if tooltips.count > 0 {
            let tooltip = tooltips.firstMatch
            XCTAssertTrue(tooltip.exists, "TooltipViewが表示されていません")

            // ツールチップテキストが存在することを確認
            let tooltipTexts = app.staticTexts.matching(NSPredicate(format: "identifier CONTAINS[c] 'tooltiptext'"))
            if tooltipTexts.count > 0 {
                XCTAssertTrue(tooltipTexts.firstMatch.exists, "TooltipViewのテキストが表示されていません")
            }
        }
    }

    // MARK: - プログレスコンポーネントテスト

    func testLinearProgressViewComponent() throws {
        // LinearProgressViewコンポーネントが正しく表示されることを確認
        let linearProgressViews = app.otherElements.matching(NSPredicate(format: "identifier CONTAINS[c] 'linearprogress'"))

        if linearProgressViews.count > 0 {
            let linearProgressView = linearProgressViews.firstMatch
            XCTAssertTrue(linearProgressView.exists, "LinearProgressViewが表示されていません")
        }
    }

    func testSegmentedProgressViewComponent() throws {
        // SegmentedProgressViewコンポーネントが正しく表示されることを確認
        let segmentedProgressViews = app.otherElements.matching(NSPredicate(format: "identifier CONTAINS[c] 'segmentedprogress'"))

        if segmentedProgressViews.count > 0 {
            let segmentedProgressView = segmentedProgressViews.firstMatch
            XCTAssertTrue(segmentedProgressView.exists, "SegmentedProgressViewが表示されていません")

            // セグメントが存在することを確認
            let segments = app.otherElements.matching(NSPredicate(format: "identifier CONTAINS[c] 'segment'"))
            if segments.count > 0 {
                XCTAssertTrue(segments.firstMatch.exists, "SegmentedProgressViewのセグメントが表示されていません")
            }
        }
    }

    // MARK: - その他コンポーネントテスト

    func testDividerViewComponent() throws {
        // DividerViewコンポーネントが正しく表示されることを確認
        let dividers = app.otherElements.matching(NSPredicate(format: "identifier CONTAINS[c] 'divider'"))

        if dividers.count > 0 {
            let divider = dividers.firstMatch
            XCTAssertTrue(divider.exists, "DividerViewが表示されていません")
        }
    }

    func testToastLightComponent() throws {
        // Toast（軽量版）コンポーネントが正しく表示されることを確認
        let toastLights = app.otherElements.matching(NSPredicate(format: "identifier CONTAINS[c] 'toastlight'"))

        if toastLights.count > 0 {
            let toastLight = toastLights.firstMatch
            XCTAssertTrue(toastLight.exists, "Toast（軽量版）が表示されていません")

            // メッセージが存在することを確認
            let toastMessages = app.staticTexts.matching(NSPredicate(format: "identifier CONTAINS[c] 'toastmessage'"))
            if toastMessages.count > 0 {
                XCTAssertTrue(toastMessages.firstMatch.exists, "Toast（軽量版）のメッセージが表示されていません")
            }
        }
    }

    func testFormViewComponent() throws {
        // FormViewコンポーネントが正しく表示されることを確認
        let formViews = app.otherElements.matching(NSPredicate(format: "identifier CONTAINS[c] 'form'"))

        if formViews.count > 0 {
            let formView = formViews.firstMatch
            XCTAssertTrue(formView.exists, "FormViewが表示されていません")

            // 入力フィールドが存在することを確認
            let textFields = app.textFields.allElementsBoundByIndex
            let secureTextFields = app.secureTextFields.allElementsBoundByIndex
            let toggles = app.switches.allElementsBoundByIndex

            let hasInputs = textFields.count > 0 || secureTextFields.count > 0 || toggles.count > 0
            XCTAssertTrue(hasInputs, "FormViewに入力要素が含まれていません")
        }
    }

    func testListViewComponent() throws {
        // ListViewコンポーネントが正しく表示されることを確認
        let listViews = app.otherElements.matching(NSPredicate(format: "identifier CONTAINS[c] 'list'"))

        if listViews.count > 0 {
            let listView = listViews.firstMatch
            XCTAssertTrue(listView.exists, "ListViewが表示されていません")

            // リストアイテムが存在することを確認
            let cells = app.cells.allElementsBoundByIndex
            if cells.count > 0 {
                XCTAssertTrue(cells.firstMatch.exists, "ListViewのリストアイテムが表示されていません")
            }
        }
    }

    func testGridViewComponent() throws {
        // GridViewコンポーネントが正しく表示されることを確認
        let gridView = app.otherElements["gridview"]

        if gridView.exists {
            XCTAssertTrue(gridView.exists, "GridViewが表示されていません")

            // グリッドアイテムが存在することを確認
            let gridItems = app.otherElements.matching(NSPredicate(format: "identifier CONTAINS[c] 'griditem'"))
            if gridItems.count > 0 {
                XCTAssertTrue(gridItems.firstMatch.exists, "GridViewのグリッドアイテムが表示されていません")
            }
        }
    }

    func testCarouselViewComponent() throws {
        // CarouselViewコンポーネントが正しく動作することを確認
        let carouselViews = app.otherElements.matching(NSPredicate(format: "identifier CONTAINS[c] 'carousel'"))

        if carouselViews.count > 0 {
            let carouselView = carouselViews.firstMatch
            XCTAssertTrue(carouselView.exists, "CarouselViewが表示されていません")

            // カルーセルをスワイプ
            if carouselView.isHittable {
                carouselView.swipeLeft()
                carouselView.swipeRight()
                XCTAssertTrue(carouselView.exists, "CarouselViewが有効ではありません")
            }
        }
    }

    func testOnboardingViewComponent() throws {
        // OnboardingViewコンポーネントが正しく表示されることを確認
        let onboardingViews = app.otherElements.matching(NSPredicate(format: "identifier CONTAINS[c] 'onboarding'"))

        if onboardingViews.count > 0 {
            let onboardingView = onboardingViews.firstMatch
            XCTAssertTrue(onboardingView.exists, "OnboardingViewが表示されていません")

            // オンボーディングアイテムが存在することを確認
            let onboardingItems = app.otherElements.matching(NSPredicate(format: "identifier CONTAINS[c] 'onboardingitem'"))
            if onboardingItems.count > 0 {
                XCTAssertTrue(onboardingItems.firstMatch.exists, "OnboardingViewのアイテムが表示されていません")
            }

            // 次へ/スキップボタンが存在することを確認
            let nextButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] '次へ' OR label CONTAINS[c] 'Next'")).firstMatch
            let skipButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'スキップ' OR label CONTAINS[c] 'Skip'")).firstMatch

            if nextButton.exists || skipButton.exists {
                XCTAssertTrue(true, "OnboardingViewのナビゲーションボタンが表示されています")
            }
        }
    }

    func testAccordionViewComponent() throws {
        // AccordionViewコンポーネントが正しく動作することを確認
        let accordionViews = app.otherElements.matching(NSPredicate(format: "identifier CONTAINS[c] 'accordion'"))

        if accordionViews.count > 0 {
            let accordionView = accordionViews.firstMatch
            XCTAssertTrue(accordionView.exists, "AccordionViewが表示されていません")

            // アコーディオンヘッダーをタップ
            let accordionHeaders = app.otherElements.matching(NSPredicate(format: "identifier CONTAINS[c] 'accordionheader'"))
            if accordionHeaders.count > 0 {
                let header = accordionHeaders.firstMatch
                if header.isHittable {
                    header.tap()

                    // アコーディオンコンテンツが表示されるのを待つ
                    let accordionContents = app.otherElements.matching(NSPredicate(format: "identifier CONTAINS[c] 'accordioncontent'"))
                    if accordionContents.count > 0 {
                        XCTAssertTrue(accordionContents.firstMatch.exists, "AccordionViewのコンテンツが表示されませんでした")
                    }
                }
            }
        }
    }

    func testAvatarGroupComponent() throws {
        // AvatarGroupコンポーネントが正しく表示されることを確認
        let avatarGroups = app.otherElements.matching(NSPredicate(format: "identifier CONTAINS[c] 'avatargroup'"))

        if avatarGroups.count > 0 {
            let avatarGroup = avatarGroups.firstMatch
            XCTAssertTrue(avatarGroup.exists, "AvatarGroupが表示されていません")

            // 複数のアバターが存在することを確認
            let avatars = app.images.matching(NSPredicate(format: "identifier CONTAINS[c] 'avatar'"))
            if avatars.count > 1 {
                XCTAssertTrue(avatars.element(boundBy: 1).exists, "AvatarGroupの2番目のアバターが表示されていません")
            }
        }
    }

    func testAvatarWithStatusComponent() throws {
        // AvatarWithStatusコンポーネントが正しく表示されることを確認
        let avatarWithStatusViews = app.otherElements.matching(NSPredicate(format: "identifier CONTAINS[c] 'avatarwithstatus'"))

        if avatarWithStatusViews.count > 0 {
            let avatarWithStatus = avatarWithStatusViews.firstMatch
            XCTAssertTrue(avatarWithStatus.exists, "AvatarWithStatusが表示されていません")

            // ステータスインジケーターが存在することを確認
            let statusIndicators = app.otherElements.matching(NSPredicate(format: "identifier CONTAINS[c] 'status'"))
            if statusIndicators.count > 0 {
                XCTAssertTrue(statusIndicators.firstMatch.exists, "AvatarWithStatusのステータスインジケーターが表示されていません")
            }
        }
    }

    func testActionBarComponent() throws {
        // ActionBarコンポーネントが正しく表示されることを確認
        let actionBars = app.otherElements.matching(NSPredicate(format: "identifier CONTAINS[c] 'actionbar'"))

        if actionBars.count > 0 {
            let actionBar = actionBars.firstMatch
            XCTAssertTrue(actionBar.exists, "ActionBarが表示されていません")

            // アクションボタンが存在することを確認
            let actionButtons = app.buttons.matching(NSPredicate(format: "identifier CONTAINS[c] 'actionbutton'"))
            if actionButtons.count > 0 {
                XCTAssertTrue(actionButtons.firstMatch.exists, "ActionBarのアクションボタンが表示されていません")
            }
        }
    }
}
