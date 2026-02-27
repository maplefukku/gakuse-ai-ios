import SwiftUI

struct LearningLogView: View {
    @State private var logs: [LearningLog] = []
    @State private var showingCreateSheet = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(logs) { log in
                    LearningLogRow(log: log)
                }
            }
            .navigationTitle("学習ログ")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingCreateSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showingCreateSheet) {
                CreateLearningLogView { newLog in
                    logs.append(newLog)
                    showingCreateSheet = false
                }
            }
            .overlay {
                if logs.isEmpty {
                    ContentUnavailableView(
                        "ログがありません",
                        systemImage: "book.closed",
                        description: Text("右下のボタンから学習ログを作成しましょう")
                    )
                }
            }
        }
    }
}

struct LearningLogRow: View {
    let log: LearningLog
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: log.category.icon)
                    .foregroundColor(.pink)
                Text(log.title)
                    .font(.headline)
                Spacer()
                if log.isPublic {
                    Image(systemName: "globe")
                        .foregroundColor(.green)
                        .font(.caption)
                }
            }
            
            Text(log.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            HStack {
                Text(log.category.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.pink.opacity(0.2))
                    .cornerRadius(8)
                
                Spacer()
                
                Text(log.createdAt.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct CreateLearningLogView: View {
    @Environment(\.dismiss) var dismiss
    @State private var title = ""
    @State private var description = ""
    @State private var category: LearningCategory = .programming
    @State private var isPublic = false
    
    let onCreate: (LearningLog) -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section("基本情報") {
                    TextField("タイトル", text: $title)
                    TextField("説明", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("カテゴリ") {
                    Picker("カテゴリ", selection: $category) {
                        ForEach(LearningCategory.allCases, id: \.self) { cat in
                            Label(cat.rawValue, systemImage: cat.icon)
                                .tag(cat)
                        }
                    }
                }
                
                Section {
                    Toggle("公開する", isOn: $isPublic)
                }
            }
            .navigationTitle("新しいログ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("作成") {
                        let log = LearningLog(
                            title: title,
                            description: description,
                            category: category,
                            isPublic: isPublic
                        )
                        onCreate(log)
                    }
                    .disabled(title.isEmpty || description.isEmpty)
                }
            }
        }
    }
}

#Preview {
    LearningLogView()
}
