import Foundation

extension DateComponents {
    func isSameDate(dateComponent: DateComponents) -> Bool {
        year == dateComponent.year && month == dateComponent.month && day == dateComponent.day
    }
}
