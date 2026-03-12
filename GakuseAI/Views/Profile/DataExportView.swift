import SwiftUI

// MARK: - Data Export View

struct DataExportView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: ProfileViewModel
    @State private var isExporting = false
    @State private var exportedURL: URL?
    @State private var showingShareSheet = false

    var body: some View {
        NavigationStack {
            List {
                Section("エクスポート形式") {
                    Button {
                        exportToCSV()
                    } label: {
                        HStack {
                            Image(systemName: "doc.text")
                                .foregroundColor(.pink)
                            VStack(alignment: .leading) {
                                Text("CSV形式")
                                    .font(.headline)
                                Text("スプレッドシートで開ける形式")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }

                    Button {
                        exportToJSON()
                    } label: {
                        HStack {
                            Image(systemName: "doc.text")
                                .foregroundColor(.pink)
                            VStack(alignment: .leading) {
                                Text("JSON形式")
                                    .font(.headline)
                                Text("データ形式でエクスポート")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }

                Section {
                    Text("学習ログ、プロファイル、チャット履歴をエクスポートします。")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("データエクスポート")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                }
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            if let url = exportedURL {
                ShareSheet(items: [url])
            }
        }
    }

    private func exportToCSV() {
        isExporting = true
        defer { isExporting = false }

        Task {
            // LearningLogViewModelを作成してCSVエクスポートを実行
            let logViewModel = LearningLogViewModel()
            await logViewModel.loadLogs()

            if let url = logViewModel.exportToCSV() {
                exportedURL = url
                showingShareSheet = true
            } else if let error = logViewModel.errorMessage {
                print("CSVエクスポートエラー: \(error)")
            }
        }
    }

    private func exportToJSON() {
        isExporting = true
        defer { isExporting = false }

        Task {
            do {
                let url = try await viewModel.exportAllData()
                exportedURL = url
                showingShareSheet = true
            } catch {
                // Handle error
                print("エクスポートエラー: \(error)")
            }
        }
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
