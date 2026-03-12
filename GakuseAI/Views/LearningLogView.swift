import SwiftUI

struct LearningLogView: View {
    @StateObject private var viewModel = LearningLogViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.logs.isEmpty {
                    ProgressView("読み込み中...")
                } else if viewModel.filteredLogs.isEmpty {
                    if viewModel.logs.isEmpty {
                        emptyStateView
                    } else {
                        noResultsView
                    }
                } else {
                    logListView
                }
            }
            .navigationTitle("学習ログ")
            .searchable(text: $viewModel.searchText, prompt: "ログを検索...")
            .accessibilityElement(children: .contain)
            .accessibilityLabel("学習ログ一覧")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        // ソート順
                        Menu {
                            ForEach(LogSortOrder.allCases, id: \.self) { order in
                                Button {
                                    viewModel.sortOrder = order
                                } label: {
                                    Label(order.rawValue, systemImage: viewModel.sortOrder == order ? "checkmark" : "")
                                }
                            }
                        } label: {
                            Label("ソート順", systemImage: "arrow.up.arrow.down")
                        }

                        Divider()

                        // カテゴリフィルター
                        Menu {
                            Button {
                                viewModel.selectedCategory = nil
                            } label: {
                                Label("すべて", systemImage: viewModel.selectedCategory == nil ? "checkmark" : "")
                            }

                            Divider()

                            ForEach(LearningCategory.allCases, id: \.self) { category in
                                Button {
                                    viewModel.selectedCategory = viewModel.selectedCategory == category ? nil : category
                                } label: {
                                    Label(category.rawValue, systemImage: viewModel.selectedCategory == category ? "checkmark" : "")
                                }
                            }
                        } label: {
                            Label("カテゴリ", systemImage: "line.3.horizontal.decrease.circle")
                        }

                        // 公開設定フィルター
                        Button {
                            viewModel.showOnlyPublic.toggle()
                        } label: {
                            Label("公開のみ", systemImage: viewModel.showOnlyPublic ? "checkmark" : "")
                        }

                        // お気に入りフィルター
                        Button {
                            viewModel.showingFavoritesOnly.toggle()
                        } label: {
                            Label("お気に入り", systemImage: viewModel.showingFavoritesOnly ? "star.fill" : "star")
                        }

                        Divider()

                        // 検索オプション
                        Button {
                            viewModel.showingSearchOptions = true
                        } label: {
                            Label("検索オプション", systemImage: "magnifyingglass.circle")
                        }

                        // エクスポート
                        Button {
                            viewModel.showingExportOptions = true
                        } label: {
                            Label("エクスポート", systemImage: "square.and.arrow.up")
                        }

                        Divider()

                        Button {
                            viewModel.showingCreateSheet = true
                        } label: {
                            Label("新規作成", systemImage: "plus.circle.fill")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingCreateSheet) {
                CreateLearningLogView(
                    existingLog: nil,
                    onSave: { title, description, category, isPublic in
                        Task {
                            await viewModel.createLog(
                                title: title,
                                description: description,
                                category: category,
                                isPublic: isPublic
                            )
                        }
                        viewModel.showingCreateSheet = false
                    }
                )
            }
            .sheet(item: $viewModel.logToEdit) { log in
                CreateLearningLogView(
                    existingLog: log,
                    onSave: { title, description, category, isPublic in
                        Task {
                            await viewModel.updateLog(
                                id: log.id,
                                title: title,
                                description: description,
                                category: category,
                                isPublic: isPublic
                            )
                        }
                        viewModel.logToEdit = nil
                    }
                )
            }
            .alert("エラー", isPresented: .init(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("OK") { viewModel.errorMessage = nil }
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
        }
        .refreshable {
            await viewModel.loadLogs()
        }
        .sheet(isPresented: $viewModel.showingSearchOptions) {
            SearchOptionsSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showingExportOptions) {
            ExportOptionsSheet(viewModel: viewModel)
        }
    }
    
    private var emptyStateView: some View {
        ContentUnavailableView(
            "ログがありません",
            systemImage: "book.closed",
            description: Text("右下のボタンから学習ログを作成しましょう")
        )
    }
    
    private var noResultsView: some View {
        ContentUnavailableView(
            "該当するログがありません",
            systemImage: "magnifyingglass",
            description: Text("検索条件を変更してみてください")
        )
    }
    
    private var logListView: some View {
        List {
            ForEach(viewModel.filteredLogs) { log in
                NavigationLink(value: log) {
                    LearningLogRow(log: log, viewModel: viewModel)
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.9).combined(with: .opacity),
                            removal: .scale(scale: 0.9).combined(with: .opacity)
                        ))
                }
            }
            .onDelete { offsets in
                // フィルター後の配列から削除対象を特定し、元の配列のインデックスを取得
                let logsToDelete = offsets.map { viewModel.filteredLogs[$0] }
                let indicesToDelete = logsToDelete.compactMap { log in
                    viewModel.logs.firstIndex(where: { $0.id == log.id })
                }

                Task {
                    await viewModel.deleteLog(at: IndexSet(indicesToDelete))
                }
            }
        }
        .drawingGroup() // パフォーマンス改善: レイヤー合成を最適化
        .animation(.easeInOut(duration: 0.3), value: viewModel.filteredLogs.count)
        .navigationDestination(for: LearningLog.self) { log in
            LearningLogDetailView(log: log, viewModel: viewModel)
        }
        .sheet(item: $viewModel.logToEdit) { log in
            LearningLogDetailView(log: log, viewModel: viewModel)
        }
    }
}

#Preview {
    LearningLogView()
}
