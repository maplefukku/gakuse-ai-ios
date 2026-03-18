import SwiftUI

struct LearningLogDetailHeaderSection: View {
    let log: LearningLog

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: log.category.icon)
                    .foregroundColor(.pink)
                Text(log.category.rawValue)
                    .font(.subheadline)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.pink.opacity(0.2))
                    .cornerRadius(8)

                Spacer()

                if log.isPublic {
                    Label("公開中", systemImage: "globe")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }

            Text(log.title)
                .font(.title.bold())

            Text(log.createdAt.formatted(date: .long, time: .shortened))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
