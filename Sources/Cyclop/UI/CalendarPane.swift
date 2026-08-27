import SwiftUI

struct CalendarPane: View {
    @ObservedObject var calendar: CalendarStore
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)
    private let monthOffsets = Array(-24...24)

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(alignment: .leading, spacing: 24) {
                    ForEach(monthOffsets, id: \.self) { offset in
                        let month = calendar.month(atOffset: offset)
                        monthView(month, offset: offset)
                            .id(calendar.monthStartID(for: month))
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
            }
            .onAppear {
                // LazyVStack needs one layout pass before the current month can
                // be resolved reliably by ScrollViewReader.
                let currentMonthID = calendar.monthStartID(for: calendar.month(atOffset: 0))
                DispatchQueue.main.async {
                    DispatchQueue.main.async {
                        proxy.scrollTo(currentMonthID, anchor: .top)
                    }
                }
            }
        }
    }

    private func monthView(_ month: Date, offset: Int) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(calendar.monthTitle(for: month))
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.white)

            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(calendar.weekdayNames, id: \.self) { weekday in
                    Text(weekday)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Theme.tertiary)
                }
                ForEach(calendar.days(for: month)) { day in
                    Text("\(day.number)日")
                        .font(.system(size: 16, weight: day.isToday ? .bold : .semibold))
                        .monospacedDigit()
                        .foregroundStyle(day.isToday ? .white : (day.isInDisplayedMonth ? Theme.secondary : Theme.tertiary.opacity(0.45)))
                        .frame(maxWidth: .infinity, minHeight: 28)
                        .background {
                            if day.isToday {
                                Circle()
                                    .fill(Color(red: 0.10, green: 0.48, blue: 0.95))
                                    .frame(width: 56, height: 56)
                            }
                        }
                }
            }
        }
    }
}

/// The folded notch clock; independent of EventKit and updated every second.
struct CalendarClockView: View {
    @ObservedObject var calendar: CalendarStore

    var body: some View {
        Text(calendar.compactDateText)
            .font(.system(size: 10, weight: .semibold).monospacedDigit())
            .foregroundStyle(.white.opacity(0.82))
            .lineLimit(1)
            .minimumScaleFactor(0.65)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
