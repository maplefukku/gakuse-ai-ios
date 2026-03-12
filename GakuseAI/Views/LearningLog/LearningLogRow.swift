import SwiftUI

// MARK: - Learning Log Row

struct LearningLogRow: View {
    let log: LearningLog
    let viewModel: LearningLogViewModel
    @State private var isPressed = false

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
                Button {
                    Task {
                        await viewModel.toggleFavorite(for: log)
                    }
                } label: {
                    Image(systemName: log.isFavorite ? "star.fill" : "star")
                        .foregroundColor(log.isFavorite ? .yellow : .gray)
                        .font(.caption)
                        .symbolEffect(.bounce, value: log.isFavorite)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: log.isFavorite)
                }
                .buttonStyle(.plain)
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
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
            withAnimation {
                isPressed = pressing
            }
        }, perform: {})
    }
}
