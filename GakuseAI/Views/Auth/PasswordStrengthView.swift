//
//  PasswordStrengthView.swift
//  GakuseAI
//
//  Created by OpenGoat on 2026-03-16.
//

import SwiftUI

// MARK: - PasswordStrengthView
/// パスワード強度表示コンポーネント
public struct PasswordStrengthView: View {
    private let password: String

    public init(password: String) {
        self.password = password
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                ForEach(0..<4, id: \.self) { index in
                    Rectangle()
                        .fill(strengthColor(for: index))
                        .frame(height: 4)
                        .cornerRadius(2)
                }
            }

            Text(strengthText)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Password Strength

    private var strength: Int {
        guard !password.isEmpty else { return 0 }
        var score = 0
        if password.count >= 8 { score += 1 }
        if password.contains(where: { $0.isUppercase }) { score += 1 }
        if password.contains(where: { $0.isNumber }) { score += 1 }
        if password.contains(where: { !$0.isLetter && !$0.isNumber }) { score += 1 }
        return score
    }

    private func strengthColor(for index: Int) -> Color {
        let strengthValue = strength
        if index < strengthValue {
            switch strengthValue {
            case 1: return .red
            case 2: return .orange
            case 3: return .yellow
            case 4: return .green
            default: return .gray.opacity(0.3)
            }
        }
        return .gray.opacity(0.3)
    }

    private var strengthText: String {
        switch strength {
        case 0: return ""
        case 1: return "弱い"
        case 2: return "普通"
        case 3: return "強い"
        case 4: return "非常に強い"
        default: return ""
        }
    }
}
