//
//  ToastStyle.swift
//  GakuseAI
//
//  Created by fe-dev-2 on 2026-03-13.
//

import SwiftUI

// MARK: - Toast Style
public enum ToastStyle {
    case standard
    case minimal
    case floating
    case inline

    var fontSize: CGFloat {
        switch self {
        case .standard:
            return 14
        case .minimal:
            return 13
        case .floating:
            return 15
        case .inline:
            return 14
        }
    }

    var padding: CGFloat {
        switch self {
        case .standard:
            return 16
        case .minimal:
            return 12
        case .floating:
            return 18
        case .inline:
            return 12
        }
    }

    var cornerRadius: CGFloat {
        switch self {
        case .standard:
            return 12
        case .minimal:
            return 8
        case .floating:
            return 16
        case .inline:
            return 8
        }
    }

    var borderWidth: CGFloat {
        switch self {
        case .standard:
            return 1
        case .minimal:
            return 0
        case .floating:
            return 0
        case .inline:
            return 0
        }
    }

    var shadowOpacity: Double {
        switch self {
        case .standard:
            return 0.05
        case .minimal:
            return 0.0
        case .floating:
            return 0.1
        case .inline:
            return 0.0
        }
    }

    var shadowRadius: CGFloat {
        switch self {
        case .standard:
            return 8
        case .minimal:
            return 0
        case .floating:
            return 12
        case .inline:
            return 0
        }
    }

    var shadowYOffset: CGFloat {
        switch self {
        case .standard:
            return 4
        case .minimal:
            return 0
        case .floating:
            return 6
        case .inline:
            return 0
        }
    }

    var lineLimit: Int {
        switch self {
        case .standard:
            return 2
        case .minimal:
            return 1
        case .floating:
            return 3
        case .inline:
            return 1
        }
    }

    var showDismissButton: Bool {
        switch self {
        case .standard:
            return true
        case .minimal:
            return false
        case .floating:
            return true
        case .inline:
            return false
        }
    }

    var isTransparent: Bool {
        switch self {
        case .standard:
            return true
        case .minimal:
            return false
        case .floating:
            return true
        case .inline:
            return false
        }
    }
}
