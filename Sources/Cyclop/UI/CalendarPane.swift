import SwiftUI

struct CalendarPane: View {
    @ObservedObject var calendar: CalendarStore
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                Text(calendar.monthTitle)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)
                Spacer(minLength: 0)
                Button { calendar.moveMonth(by: -1) } label: { Image(systemName: "chevron.left") }
                Button { calendar.moveMonth(by: 1) } label: { Image(systemName: "chevron.right") }
            }
            .buttonStyle(.plain)
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.top, 2)
            .padding(.bottom, 20)

            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(calendar.weekdayNames, id: \.self) { weekday in
                    Text(weekday)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Theme.tertiary)
                }
                ForEach(calendar.days) { day in
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
            .animation(.easeInOut(duration: 0.2), value: calendar.displayedMonth)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 8)
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
