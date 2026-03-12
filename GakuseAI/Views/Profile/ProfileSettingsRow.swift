import SwiftUI

// MARK: - Setting Row

struct SettingRow: View {
    let icon: String
    let title: String
    var showChevron: Bool = false
    @State private var isPressed = false

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.pink)
                .frame(width: 24)
            Text(title)
            Spacer()
            if showChevron {
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
        }
        .contentShape(Rectangle())
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
            withAnimation {
                isPressed = pressing
            }
        }, perform: {})
    }
}
