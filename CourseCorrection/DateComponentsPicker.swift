import SwiftUI

/// A picker that binds to ``DateComponents`` allowing selection of month,
/// day and year. It automatically adjusts the available days when the
/// month or year changes so that invalid dates are never selected.
struct DateComponentsPicker: View {
    @Binding var components: DateComponents

    private var monthNames: [String] { Calendar.current.monthSymbols }

    private var daysInCurrentMonth: Int {
        let calendar = Calendar.current
        var comps = DateComponents()
        comps.year = components.year ?? 2000
        comps.month = components.month ?? 1
        // Default to day 1 to calculate the range for the given month/year
        comps.day = 1
        if let date = calendar.date(from: comps),
           let range = calendar.range(of: .day, in: .month, for: date) {
            return range.count
        }
        return 31
    }

    private func adjustDayIfNeeded() {
        if let day = components.day, day > daysInCurrentMonth {
            components.day = daysInCurrentMonth
        }
    }

    var body: some View {
        HStack {
            Picker("Month", selection: Binding(
                get: { components.month ?? 1 },
                set: { newMonth in
                    components.month = newMonth
                    adjustDayIfNeeded()
                })) {
                    ForEach(1...12, id: \..self) { month in
                        Text(monthNames[month - 1]).tag(month)
                    }
                }
            Picker("Day", selection: Binding(
                get: { components.day ?? 1 },
                set: { newDay in components.day = newDay })) {
                    ForEach(1...daysInCurrentMonth, id: \..self) { day in
                        Text(String(day)).tag(day)
                    }
                }
            let currentYear = Calendar.current.component(.year, from: Date())
            Picker("Year", selection: Binding(
                get: { components.year ?? currentYear },
                set: { newYear in
                    components.year = newYear
                    adjustDayIfNeeded()
                })) {
                    ForEach((currentYear - 100)...(currentYear + 20), id: \..self) { year in
                        Text(String(year)).tag(year)
                    }
                }
        }
    }
}

#Preview {
    DateComponentsPicker(components: .constant(DateComponents(year: 2024, month: 2, day: 29)))
        .padding()
}
