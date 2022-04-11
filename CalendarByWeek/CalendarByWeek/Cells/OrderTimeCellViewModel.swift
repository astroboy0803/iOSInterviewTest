import Foundation

internal final class OrderTimeCellViewModel {
    let time: String
    let isBooked: Bool
    
    init(time: String, isBooked: Bool) {
        self.time = time
        self.isBooked = isBooked
    }
}
