import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("アカウント") {
                    HStack {
                        Circle()
                            .fill(Color.pink)
                            .frame(width: 50, height: 50)
                            .overlay {
                                Image(systemName: "person.fill")
                                    .foregroundColor(.white)
                            }
                        
                        VStack(alignment: .leading) {
                            Text("ユーザー名")
                                .font(.headline)
                            Text("email@example.com")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section("設定") {
                    NavigationLink("通知設定") {
                        Text("通知設定")
                    }
                    NavigationLink("プライバシー") {
                        Text("プライバシー")
                    }
                    NavigationLink("テーマ") {
                        Text("テーマ")
                    }
                }
                
                Section("その他") {
                    Link("利用規約", destination: URL(string: "https://gakuse.ai/terms")!)
                    Link("プライバシーポリシー", destination: URL(string: "https://gakuse.ai/privacy")!)
                    Link("ヘルプ", destination: URL(string: "https://gakuse.ai/help")!)
                }
                
                Section {
                    Button("ログアウト", role: .destructive) {
                        // TODO: Implement logout
                    }
                }
            }
            .navigationTitle("設定")
        }
    }
}

#Preview {
    ProfileView()
}
