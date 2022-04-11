import Foundation

internal final class WeekDayCellViewModel {
    let week: String
    let day: String
    let canBooked: Bool
    init(week: String, day: String, canBooked: Bool) {
        self.week = week
        self.day = day
        self.canBooked = canBooked
    }
}
