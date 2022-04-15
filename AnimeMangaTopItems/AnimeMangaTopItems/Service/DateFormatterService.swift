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

    func string(dateFormat: String, date: Date) -> String {
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: date)
    }

    func date(iso8601String: String) -> Date? {
        isoDateFormatter.date(from: iso8601String)
    }
}
