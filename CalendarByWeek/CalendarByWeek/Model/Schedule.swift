import Foundation

struct Schedule: Codable {
    static let infoKey = CodingUserInfoKey(rawValue: "Schedule.InfoKey.DateFormatter")
    
    let available: [Period]
    let booked: [Period]
    
    struct Period: Codable {
        enum CodingKeys: CodingKey {
            case start
            case end
        }
        
        let start: Date
        let end: Date
        
        init(from decoder: Decoder) throws {
            guard
                let infoKey = Schedule.infoKey,
                let dateFormatterServices = decoder.userInfo[infoKey] as? DateFormatterService
            else {
                fatalError("can't get dateFormatter from userInfo")
            }
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let startString = try container.decode(String.self, forKey: .start)
            let endString = try container.decode(String.self, forKey: .end)
            guard
                let sDate = dateFormatterServices.date(iso8601String: startString),
                let eDate = dateFormatterServices.date(iso8601String: endString)
            else {
                fatalError("string to date fail")
            }
            start = sDate
            end = eDate
        }
    }
}
