import Foundation

/// Local date and time for the calendar tab.
/// This deliberately does not use EventKit: it needs no Calendar permission.
@MainActor
final class CalendarStore: ObservableObject {
    struct Day: Identifiable {
        let date: Date
        let number: Int
        let isToday: Bool
        let isInDisplayedMonth: Bool
        var id: Date { date }
    }

    @Published private(set) var now: Date
    @Published private(set) var displayedMonth: Date
    private var timer: Timer?
    private var calendar: Calendar {
        var value = Calendar.autoupdatingCurrent
        value.firstWeekday = 2
        return value
    }

    init() {
        let current = Date()
        var localCalendar = Calendar.autoupdatingCurrent
        localCalendar.firstWeekday = 2
        now = current
        displayedMonth = localCalendar.dateInterval(of: .month, for: current)?.start ?? current
    }

    var monthTitle: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "MMMM yyyy年"
        return formatter.string(from: displayedMonth)
    }

    var compactDateText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy年M月d日 HH:mm 周"
        let weekday = calendar.component(.weekday, from: now)
        return formatter.string(from: now) + ["日", "一", "二", "三", "四", "五", "六"][weekday - 1]
    }

    var weekdayNames: [String] { ["一", "二", "三", "四", "五", "六", "日"] }

    /// Two rows match the supplied reference: current week plus the following week.
    var days: [Day] {
        let anchor = calendar.isDate(displayedMonth, equalTo: now, toGranularity: .month) ? now : displayedMonth
        let first = calendar.startOfWeek(for: anchor)
        let month = calendar.component(.month, from: displayedMonth)
        return (0..<14).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: offset, to: first) else { return nil }
            return Day(
                date: date,
                number: calendar.component(.day, from: date),
                isToday: calendar.isDate(date, inSameDayAs: now),
                isInDisplayedMonth: calendar.component(.month, from: date) == month
            )
        }
    }

    func start() {
        now = Date()
        startTimer()
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    func setActive(_ active: Bool) {
        if active {
            now = Date()
            startTimer()
        } else {
            stop()
        }
    }

    func moveMonth(by value: Int) {
        displayedMonth = calendar.date(byAdding: .month, value: value, to: displayedMonth)
            .map { calendar.startOfMonth(for: $0) } ?? displayedMonth
    }

    private func startTimer() {
        guard timer == nil else { return }
        let timer = Timer(timeInterval: 1, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated { self?.now = Date() }
        }
        timer.tolerance = 0.2
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }
}

private extension Calendar {
    func startOfMonth(for date: Date) -> Date { dateInterval(of: .month, for: date)?.start ?? date }
    func startOfWeek(for date: Date) -> Date { dateInterval(of: .weekOfYear, for: date)?.start ?? date }
}
