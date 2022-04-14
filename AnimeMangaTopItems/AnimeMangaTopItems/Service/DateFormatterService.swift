import Foundation

internal final class DateFormatterService {

    private let isoDateFormatter: ISO8601DateFormatter

    private let dateFormatter: DateFormatter

    init() {
        isoDateFormatter = .init()
        isoDateFormatter.timeZone = .autoupdatingCurrent
        dateFormatter = .init()
        dateFormatter.timeZone = .autoupdatingCurrent
    }

    func iso8601String(dateComponents: DateComponents) -> String? {
        guard let date = date(dateComponents: dateComponents) else {
            return nil
        }
        return iso8601String(date: date)
    }

    func iso8601String(date: Date) -> String {
        isoDateFormatter.string(from: date)
    }

    func string(dateFormat: String, date: Date) -> String {
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: date)
    }

    func string(dateFormat: String, dateComponents: DateComponents) -> String? {
        guard let date = date(dateComponents: dateComponents) else {
            return nil
        }
        return string(dateFormat: dateFormat, date: date)
    }

    func date(dateComponents: DateComponents) -> Date? {
        Calendar.current.date(from: dateComponents)
    }

    func date(iso8601String: String) -> Date? {
        isoDateFormatter.date(from: iso8601String)
    }

    func date(string: String, dateFormat: String) -> Date? {
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.date(from: string)
    }

    func dateComponents(date: Date) -> DateComponents {
        Calendar.current.dateComponents(in: .autoupdatingCurrent, from: date)
    }

    func date(addingDay value: Int, dateComponents: DateComponents) -> Date? {
        guard let baseDate = date(dateComponents: dateComponents) else {
            return nil
        }
        return date(addingDay: value, date: baseDate)
    }

    func date(addingDay value: Int, date: Date) -> Date? {
        Calendar.current.date(byAdding: .day, value: value, to: date)
    }

    func date(bySettingHour hour: Int, minute: Int, second: Int, date: Date) -> Date? {
        Calendar.current.date(bySettingHour: hour, minute: minute, second: second, of: date)
    }

    func weekDateComponents(today: Date) -> [DateComponents] {
        let todayComponents = Calendar.current.dateComponents(in: .current, from: today)
        guard let weekDay = todayComponents.weekday else {
            fatalError("today's weekday is nil")
        }

        var result: [DateComponents] = []

        for index in 1..<weekDay {
            let diff = index - weekDay
            guard let aDate = Calendar.current.date(byAdding: .day, value: diff, to: today) else {
                fatalError("convert date is nil")
            }
            result.append(Calendar.current.dateComponents(in: .current, from: aDate))
        }

        for index in weekDay...7 {
            if index == weekDay {
                result.append(todayComponents)
                continue
            }
            let diff = index - weekDay
            guard let aDate = Calendar.current.date(byAdding: .day, value: diff, to: today) else {
                fatalError("convert date is nil")
            }
            result.append(Calendar.current.dateComponents(in: .current, from: aDate))
        }
        return result
    }

    func divids(start: Date, end: Date, minute: Int = 30) -> [Date] {
        var result: [Date] = []
        var next = start
        repeat {
            result.append(next)
            guard let date = Calendar.current.date(byAdding: .minute, value: minute, to: next) else {
                break
            }
            next = date
        } while next < end

        return result
    }
}
