import SwiftUI

// MARK: - Text Input Field
/// 汎用テキスト入力フィールドコンポーネント
/// - 様々なスタイルのテキスト入力フィールドを提供します
struct TextInputField: View {
    // MARK: - Properties
    @Binding var text: String
    let placeholder: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .sentences
    var style: TextInputFieldStyle = .standard
    var isError: Bool = false
    var errorMessage: String? = nil
    
    @FocusState private var isFocused: Bool
    @State private var showPassword: Bool = false
    
    // MARK: - Styles
    enum TextInputFieldStyle {
        case standard
        case outlined
        case filled
        case minimal
    }
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            fieldView
            
            if isError, let errorMessage = errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
    
    // MARK: - Field View
    @ViewBuilder
    private var fieldView: some View {
        HStack(spacing: 12) {
            if let leadingIcon = leadingIcon {
                Image(systemName: leadingIcon)
                    .foregroundColor(iconColor)
            }
            
            if isSecure && !showPassword {
                SecureField(placeholder, text: $text)
                    .focused($isFocused)
                    .keyboardType(keyboardType)
                    .textInputAutocapitalization(autocapitalization)
                    .autocorrectionDisabled()
            } else {
                TextField(placeholder, text: $text)
                    .focused($isFocused)
                    .keyboardType(keyboardType)
                    .textInputAutocapitalization(autocapitalization)
                    .autocorrectionDisabled()
            }
            
            if isSecure {
                Button(action: {
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                        showPassword.toggle()
                    }
                }) {
                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(iconColor)
                }
                .buttonStyle(.plain)
            }
            
            if let trailingIcon = trailingIcon {
                Button(action: trailingAction) {
                    Image(systemName: trailingIcon)
                        .foregroundColor(iconColor)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(fieldBackground)
        .overlay(fieldBorder)
        .cornerRadius(cornerRadius)
        .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: shadowOffset)
        .drawingGroup()
        .onTapGesture {
            isFocused = true
        }
    }
    
    // MARK: - Style Properties
    @ViewBuilder
    private var fieldBackground: some View {
        switch style {
        case .standard:
            Color(UIColor.systemBackground)
        case .outlined:
            Color.clear
        case .filled:
            Color(UIColor.secondarySystemGroupedBackground)
        case .minimal:
            Color(UIColor.systemBackground)
        }
    }
    
    @ViewBuilder
    private var fieldBorder: some View {
        switch style {
        case .standard:
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(borderColor, lineWidth: 1)
        case .outlined:
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(borderColor, lineWidth: 1.5)
        case .filled:
            Rectangle()
                .fill(borderColor)
                .frame(height: 2)
                .padding(.bottom, -12)
        case .minimal:
            Rectangle()
                .fill(borderColor)
                .frame(height: 1)
                .padding(.bottom, -12)
        }
    }
    
    // MARK: - Computed Properties
    private var borderColor: Color {
        if isError {
            return .red
        } else if isFocused {
            return .pink
        } else {
            return Color(UIColor.separator)
        }
    }
    
    private var iconColor: Color {
        if isError {
            return .red
        } else if isFocused {
            return .pink
        } else {
            return .gray
        }
    }
    
    private var cornerRadius: CGFloat {
        switch style {
        case .standard:
            return 8
        case .outlined:
            return 12
        case .filled:
            return 8
        case .minimal:
            return 0
        }
    }
    
    private var shadowColor: Color {
        switch style {
        case .standard, .outlined:
            return isFocused ? Color.pink.opacity(0.2) : Color.black.opacity(0.05)
        case .filled, .minimal:
            return .clear
        }
    }
    
    private var shadowRadius: CGFloat {
        switch style {
        case .standard, .outlined:
            return isFocused ? 8 : 2
        case .filled, .minimal:
            return 0
        }
    }
    
    private var shadowOffset: CGFloat {
        switch style {
        case .standard, .outlined:
            return isFocused ? 4 : 1
        case .filled, .minimal:
            return 0
        }
    }
    
    // MARK: - Optional Properties
    var leadingIcon: String? = nil
    var trailingIcon: String? = nil
    var trailingAction: () -> Void = {}
}

// MARK: - Compact Text Input Field
/// コンパクトなテキスト入力フィールド
struct CompactTextInputField: View {
    @Binding var text: String
    let placeholder: String
    var isSecure: Bool = false
    
    @FocusState private var isFocused: Bool
    @State private var showPassword: Bool = false
    
    var body: some View {
        HStack(spacing: 8) {
            if isSecure && !showPassword {
                SecureField(placeholder, text: $text)
                    .focused($isFocused)
                    .font(.subheadline)
                    .autocorrectionDisabled()
            } else {
                TextField(placeholder, text: $text)
                    .focused($isFocused)
                    .font(.subheadline)
                    .autocorrectionDisabled()
            }
            
            if isSecure {
                Button(action: {
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                        showPassword.toggle()
                    }
                }) {
                    Image(systemName: showPassword ? "eye.slash" : "eye")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isFocused ? Color.pink : Color.clear, lineWidth: 1)
        )
        .drawingGroup()
    }
}

// MARK: - Multiline Text Input Field
/// 複数行のテキスト入力フィールド
struct MultilineTextInputField: View {
    @Binding var text: String
    let placeholder: String
    var maxLines: Int = 5
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(.gray)
                    .padding(.top, 8)
                    .padding(.leading, 12)
            }
            
            TextEditor(text: $text)
                .focused($isFocused)
                .font(.body)
                .frame(minHeight: 80, maxHeight: CGFloat(maxLines * 24))
                .padding(8)
                .background(Color.clear)
        }
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isFocused ? Color.pink : Color(UIColor.separator), lineWidth: 1)
        )
        .drawingGroup()
    }
}

// MARK: - Preview
#Preview("TextInputField - Standard") {
    VStack(spacing: 20) {
        TextInputField(
            text: .constant(""),
            placeholder: "ユーザー名",
            style: .standard
        )
        
        TextInputField(
            text: .constant(""),
            placeholder: "パスワード",
            isSecure: true,
            style: .standard
        )
        
        TextInputField(
            text: .constant("test@example.com"),
            placeholder: "メールアドレス",
            keyboardType: .emailAddress,
            style: .standard
        )
    }
    .padding()
    .background(Color(UIColor.systemGroupedBackground))
}

#Preview("TextInputField - Outlined") {
    VStack(spacing: 20) {
        TextInputField(
            text: .constant(""),
            placeholder: "ユーザー名",
            style: .outlined,
            leadingIcon: "person"
        )
        
        TextInputField(
            text: .constant(""),
            placeholder: "パスワード",
            isSecure: true,
            style: .outlined,
            leadingIcon: "lock"
        )
        
        TextInputField(
            text: .constant("error@example.com"),
            placeholder: "メールアドレス",
            keyboardType: .emailAddress,
            style: .outlined,
            isError: true,
            errorMessage: "無効なメールアドレスです"
        )
    }
    .padding()
    .background(Color(UIColor.systemGroupedBackground))
}

#Preview("TextInputField - Filled") {
    VStack(spacing: 20) {
        TextInputField(
            text: .constant(""),
            placeholder: "ユーザー名",
            style: .filled
        )
        
        TextInputField(
            text: .constant(""),
            placeholder: "パスワード",
            isSecure: true,
            style: .filled
        )
        
        TextInputField(
            text: .constant(""),
            placeholder: "検索",
            style: .filled,
            leadingIcon: "magnifyingglass"
        )
    }
    .padding()
    .background(Color(UIColor.systemGroupedBackground))
}

#Preview("TextInputField - Minimal") {
    VStack(spacing: 20) {
        TextInputField(
            text: .constant(""),
            placeholder: "ユーザー名",
            style: .minimal
        )
        
        TextInputField(
            text: .constant(""),
            placeholder: "パスワード",
            isSecure: true,
            style: .minimal
        )
    }
    .padding()
    .background(Color(UIColor.systemGroupedBackground))
}

#Preview("CompactTextInputField") {
    VStack(spacing: 20) {
        CompactTextInputField(
            text: .constant(""),
            placeholder: "ユーザー名"
        )
        
        CompactTextInputField(
            text: .constant(""),
            placeholder: "パスワード",
            isSecure: true
        )
    }
    .padding()
    .background(Color(UIColor.systemGroupedBackground))
}

#Preview("MultilineTextInputField") {
    VStack(spacing: 20) {
        MultilineTextInputField(
            text: .constant(""),
            placeholder: "メッセージを入力..."
        )
        
        MultilineTextInputField(
            text: .constant("複数行の\nテキスト入力\nコンポーネント"),
            placeholder: "メッセージを入力...",
            maxLines: 10
        )
    }
    .padding()
    .background(Color(UIColor.systemGroupedBackground))
}

#Preview("All Styles") {
    ScrollView {
        VStack(spacing: 24) {
            Text("Standard Style")
                .font(.headline)
            
            TextInputField(
                text: .constant(""),
                placeholder: "Standard Input",
                style: .standard
            )
            
            Divider()
            
            Text("Outlined Style")
                .font(.headline)
            
            TextInputField(
                text: .constant(""),
                placeholder: "Outlined Input",
                style: .outlined,
                leadingIcon: "person"
            )
            
            Divider()
            
            Text("Filled Style")
                .font(.headline)
            
            TextInputField(
                text: .constant(""),
                placeholder: "Filled Input",
                style: .filled
            )
            
            Divider()
            
            Text("Minimal Style")
                .font(.headline)
            
            TextInputField(
                text: .constant(""),
                placeholder: "Minimal Input",
                style: .minimal
            )
            
            Divider()
            
            Text("Compact")
                .font(.headline)
            
            CompactTextInputField(
                text: .constant(""),
                placeholder: "Compact Input"
            )
            
            Divider()
            
            Text("Multiline")
                .font(.headline)
            
            MultilineTextInputField(
                text: .constant(""),
                placeholder: "Multiline Input..."
            )
        }
        .padding()
    }
    .background(Color(UIColor.systemGroupedBackground))
}
