import SwiftUI

// MARK: - Date Picker
/// 汎用日付選択コンポーネント
struct DatePickerField: View {
    @Binding var date: Date
    let placeholder: String
    var style: DatePickerFieldStyle = .standard
    var minimumDate: Date? = nil
    var maximumDate: Date? = nil
    
    @State private var isDatePickerPresented: Bool = false
    @State private var isFocused: Bool = false
    
    enum DatePickerFieldStyle {
        case standard
        case outlined
        case compact
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Button(action: {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                    isDatePickerPresented.toggle()
                }
            }) {
                HStack {
                    if style != .compact {
                        Image(systemName: "calendar")
                            .foregroundColor(.pink)
                            .frame(width: 20)
                    }
                    
                    Text(formattedDate)
                        .foregroundColor(date != Date() ? .primary : .gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    if style != .compact {
                        Image(systemName: "chevron.down")
                            .foregroundColor(.gray)
                            .font(.caption)
                    }
                }
                .padding(.horizontal, style == .compact ? 12 : 16)
                .padding(.vertical, style == .compact ? 8 : 12)
                .background(fieldBackground)
                .overlay(fieldBorder)
                .cornerRadius(cornerRadius)
                .drawingGroup()
            }
            .buttonStyle(.plain)
            .scaleEffect(isDatePickerPresented ? 0.98 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isDatePickerPresented)
        }
        .sheet(isPresented: $isDatePickerPresented) {
            DatePickerSheet(
                date: $date,
                minimumDate: minimumDate,
                maximumDate: maximumDate,
                isPresented: $isDatePickerPresented
            )
        }
    }
    
    private var formattedDate: String {
        if date == Date() {
            return placeholder
        }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
    
    @ViewBuilder
    private var fieldBackground: some View {
        switch style {
        case .standard, .compact:
            Color(UIColor.systemBackground)
        case .outlined:
            Color.clear
        }
    }
    
    @ViewBuilder
    private var fieldBorder: some View {
        switch style {
        case .standard, .compact:
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(Color(UIColor.separator), lineWidth: 1)
        case .outlined:
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(isDatePickerPresented ? Color.pink : Color(UIColor.separator), lineWidth: 1.5)
        }
    }
    
    private var cornerRadius: CGFloat {
        switch style {
        case .standard:
            return 8
        case .outlined:
            return 12
        case .compact:
            return 6
        }
    }
}

// MARK: - Time Picker
/// 時間選択コンポーネント
struct TimePickerField: View {
    @Binding var time: Date
    let placeholder: String
    var style: TimePickerFieldStyle = .standard
    
    @State private var isTimePickerPresented: Bool = false
    
    enum TimePickerFieldStyle {
        case standard
        case outlined
        case compact
    }
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                isTimePickerPresented.toggle()
            }
        }) {
            HStack {
                if style != .compact {
                    Image(systemName: "clock")
                        .foregroundColor(.pink)
                        .frame(width: 20)
                }
                
                Text(formattedTime)
                    .foregroundColor(time != Date() ? .primary : .gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if style != .compact {
                    Image(systemName: "chevron.down")
                        .foregroundColor(.gray)
                        .font(.caption)
                }
            }
            .padding(.horizontal, style == .compact ? 12 : 16)
            .padding(.vertical, style == .compact ? 8 : 12)
            .background(fieldBackground)
            .overlay(fieldBorder)
            .cornerRadius(cornerRadius)
            .drawingGroup()
        }
        .buttonStyle(.plain)
        .scaleEffect(isTimePickerPresented ? 0.98 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isTimePickerPresented)
        .sheet(isPresented: $isTimePickerPresented) {
            TimePickerSheet(
                time: $time,
                isPresented: $isTimePickerPresented
            )
        }
    }
    
    private var formattedTime: String {
        if time == Date() {
            return placeholder
        }
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: time)
    }
    
    @ViewBuilder
    private var fieldBackground: some View {
        switch style {
        case .standard, .compact:
            Color(UIColor.systemBackground)
        case .outlined:
            Color.clear
        }
    }
    
    @ViewBuilder
    private var fieldBorder: some View {
        switch style {
        case .standard, .compact:
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(Color(UIColor.separator), lineWidth: 1)
        case .outlined:
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(isTimePickerPresented ? Color.pink : Color(UIColor.separator), lineWidth: 1.5)
        }
    }
    
    private var cornerRadius: CGFloat {
        switch style {
        case .standard:
            return 8
        case .outlined:
            return 12
        case .compact:
            return 6
        }
    }
}

// MARK: - Date & Time Picker
/// 日時選択コンポーネント
struct DateTimePickerField: View {
    @Binding var dateTime: Date
    let placeholder: String
    
    @State private var isDatePickerPresented: Bool = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                isDatePickerPresented.toggle()
            }
        }) {
            HStack {
                Image(systemName: "calendar.badge.clock")
                    .foregroundColor(.pink)
                    .frame(width: 20)
                
                Text(formattedDateTime)
                    .foregroundColor(dateTime != Date() ? .primary : .gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Image(systemName: "chevron.down")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(UIColor.systemBackground))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isDatePickerPresented ? Color.pink : Color(UIColor.separator), lineWidth: 1)
            )
            .cornerRadius(8)
            .drawingGroup()
        }
        .buttonStyle(.plain)
        .scaleEffect(isDatePickerPresented ? 0.98 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isDatePickerPresented)
        .sheet(isPresented: $isDatePickerPresented) {
            DateTimePickerSheet(
                dateTime: $dateTime,
                isPresented: $isDatePickerPresented
            )
        }
    }
    
    private var formattedDateTime: String {
        if dateTime == Date() {
            return placeholder
        }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: dateTime)
    }
}

// MARK: - DatePicker Sheet
private struct DatePickerSheet: View {
    @Binding var date: Date
    let minimumDate: Date?
    let maximumDate: Date?
    @Binding var isPresented: Bool
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker("", selection: $date, in: dateRange, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .padding()
                    .presentationDetents([.height(400)])
                
                Spacer()
            }
            .navigationTitle("日付を選択")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("完了") {
                        isPresented = false
                    }
                }
            }
        }
    }
    
    private var dateRange: ClosedRange<Date> {
        let minDate = minimumDate ?? Date.distantPast
        let maxDate = maximumDate ?? Date.distantFuture
        return minDate...maxDate
    }
}

// MARK: - TimePicker Sheet
private struct TimePickerSheet: View {
    @Binding var time: Date
    @Binding var isPresented: Bool
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker("", selection: $time, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .padding()
                    .presentationDetents([.height(300)])
                
                Spacer()
            }
            .navigationTitle("時間を選択")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("完了") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

// MARK: - DateTimePicker Sheet
private struct DateTimePickerSheet: View {
    @Binding var dateTime: Date
    @Binding var isPresented: Bool
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                DatePicker("日付", selection: $dateTime, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .padding()
                
                DatePicker("時間", selection: $dateTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .padding()
                
                Spacer()
            }
            .navigationTitle("日時を選択")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("完了") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

// MARK: - Quick Date Picker Buttons
/// クイック日付選択ボタン（今日、明日、来週など）
struct QuickDatePickerButtons: View {
    @Binding var date: Date
    let options: [QuickDateOption]
    
    enum QuickDateOption {
        case today
        case tomorrow
        case nextWeek
        case nextMonth
        case custom(days: Int, label: String)
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(options, id: \.label) { option in
                    QuickDateButton(
                        title: option.label,
                        isSelected: isSelected(option),
                        action: {
                            withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                                date = option.targetDate
                            }
                        }
                    )
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func isSelected(_ option: QuickDateOption) -> Bool {
        Calendar.current.isDate(date, inSameDayAs: option.targetDate)
    }
}

extension QuickDatePickerButtons.QuickDateOption {
    var label: String {
        switch self {
        case .today:
            return "今日"
        case .tomorrow:
            return "明日"
        case .nextWeek:
            return "来週"
        case .nextMonth:
            return "来月"
        case .custom(_, let label):
            return label
        }
    }
    
    var targetDate: Date {
        let calendar = Calendar.current
        switch self {
        case .today:
            return Date()
        case .tomorrow:
            return calendar.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        case .nextWeek:
            return calendar.date(byAdding: .weekOfYear, value: 1, to: Date()) ?? Date()
        case .nextMonth:
            return calendar.date(byAdding: .month, value: 1, to: Date()) ?? Date()
        case .custom(let days, _):
            return calendar.date(byAdding: .day, value: days, to: Date()) ?? Date()
        }
    }
}

// MARK: - Quick Date Button
private struct QuickDateButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .pink)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.pink : Color.pink.opacity(0.1))
                .cornerRadius(20)
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
            withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

// MARK: - Preview
#Preview("DatePickerField - Standard") {
    VStack(spacing: 20) {
        DatePickerField(
            date: .constant(Date()),
            placeholder: "生年月日を選択",
            style: .standard
        )
        
        DatePickerField(
            date: .constant(Date().addingTimeInterval(-86400 * 365 * 25)),
            placeholder: "開始日を選択",
            style: .standard
        )
        
        DatePickerField(
            date: .constant(Date()),
            placeholder: "終了日を選択",
            style: .standard,
            minimumDate: Date()
        )
    }
    .padding()
    .background(Color(UIColor.systemGroupedBackground))
}

#Preview("DatePickerField - Outlined") {
    VStack(spacing: 20) {
        DatePickerField(
            date: .constant(Date()),
            placeholder: "生年月日を選択",
            style: .outlined
        )
        
        DatePickerField(
            date: .constant(Date()),
            placeholder: "予約日を選択",
            style: .outlined
        )
    }
    .padding()
    .background(Color(UIColor.systemGroupedBackground))
}

#Preview("DatePickerField - Compact") {
    VStack(spacing: 20) {
        DatePickerField(
            date: .constant(Date()),
            placeholder: "日付",
            style: .compact
        )
    }
    .padding()
    .background(Color(UIColor.systemGroupedBackground))
}

#Preview("TimePickerField") {
    VStack(spacing: 20) {
        TimePickerField(
            time: .constant(Date()),
            placeholder: "開始時間",
            style: .standard
        )
        
        TimePickerField(
            time: .constant(Date()),
            placeholder: "終了時間",
            style: .outlined
        )
        
        TimePickerField(
            time: .constant(Date()),
            placeholder: "時間",
            style: .compact
        )
    }
    .padding()
    .background(Color(UIColor.systemGroupedBackground))
}

#Preview("DateTimePickerField") {
    VStack(spacing: 20) {
        DateTimePickerField(
            dateTime: .constant(Date()),
            placeholder: "予約日時を選択"
        )
        
        DateTimePickerField(
            dateTime: .constant(Date().addingTimeInterval(86400)),
            placeholder: "開催日時を選択"
        )
    }
    .padding()
    .background(Color(UIColor.systemGroupedBackground))
}

#Preview("QuickDatePickerButtons") {
    VStack(spacing: 20) {
        Text("クイック日付選択")
            .font(.headline)
        
        QuickDatePickerButtons(
            date: .constant(Date()),
            options: [.today, .tomorrow, .nextWeek]
        )
        
        QuickDatePickerButtons(
            date: .constant(Date().addingTimeInterval(86400)),
            options: [.today, .tomorrow, .nextWeek, .nextMonth]
        )
    }
    .padding()
    .background(Color(UIColor.systemGroupedBackground))
}

#Preview("All Components") {
    ScrollView {
        VStack(spacing: 30) {
            Text("日付選択")
                .font(.headline)
            
            DatePickerField(
                date: .constant(Date()),
                placeholder: "生年月日",
                style: .standard
            )
            
            Divider()
            
            Text("時間選択")
                .font(.headline)
            
            TimePickerField(
                time: .constant(Date()),
                placeholder: "開始時間",
                style: .standard
            )
            
            Divider()
            
            Text("日時選択")
                .font(.headline)
            
            DateTimePickerField(
                dateTime: .constant(Date()),
                placeholder: "予約日時"
            )
            
            Divider()
            
            Text("クイック選択")
                .font(.headline)
            
            QuickDatePickerButtons(
                date: .constant(Date()),
                options: [.today, .tomorrow, .nextWeek, .nextMonth, .custom(days: 7, label: "1週間後")]
            )
        }
        .padding()
    }
    .background(Color(UIColor.systemGroupedBackground))
}
