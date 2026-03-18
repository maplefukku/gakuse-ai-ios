import SwiftUI

struct LearningLogDetailDescriptionSection: View {
    let log: LearningLog

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("説明")
                .font(.headline)
            Text(log.description)
                .font(.body)
        }
        .padding()
    }
}
