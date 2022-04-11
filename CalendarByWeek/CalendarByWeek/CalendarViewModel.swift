import Foundation
import Combine

internal final class CalendarViewModel {
    
    let dataSubject: CurrentValueSubject<[[DataContent]], Never>
    
    let dateInterval: CurrentValueSubject<String?, Never>
    
    let timezoneInfo: CurrentValueSubject<String, Never>
    
    let prevEnable: CurrentValueSubject<Bool, Never>
    
    let isLoading: CurrentValueSubject<Bool, Never>
    
    private let intervalsComponents: CurrentValueSubject<[DateComponents], Never>
    
    let message: PassthroughSubject<String, Never>
    
    private var cancellables: Set<AnyCancellable>
    
    private let servicesProvider: ServicesProvider
    
    private var today: Date
    
    init(servicesProvider: ServicesProvider, date: Date = .init()) {
        today = date
        message = .init()
        dataSubject = .init([])
        dateInterval = .init(nil)
        cancellables = []
        prevEnable = .init(true)
        isLoading = .init(false)
        timezoneInfo = .init(servicesProvider.dateFormatService.string(dateFormat: "v (OOOO)", date: date))
        self.servicesProvider = servicesProvider
        intervalsComponents = .init(servicesProvider.dateFormatService.weekDateComponents(today: date))
        setBinding()
    }
    
    private func setBinding() {
        intervalsComponents
            .sink { dateComponents in
                self.setInterval(dateComponents: dateComponents)
                self.setPrveEnabled(dateComponents: dateComponents)
                self.fetch(dateComponents: dateComponents)
            }
            .store(in: &cancellables)
    }
    
    private func setInterval(dateComponents: [DateComponents]) {
        guard
            let first = dateComponents.first,
            let last = dateComponents.last,
            let fString = servicesProvider.dateFormatService.string(dateFormat: "yyyy/MM/dd", dateComponents: first),
            let lString = servicesProvider.dateFormatService.string(dateFormat: "MM/dd", dateComponents: last)
        else {
            self.dateInterval.value = nil
            return
        }
        self.dateInterval.value = "\(fString) - \(lString)"
    }
    
    private func setPrveEnabled(dateComponents: [DateComponents]) {
        let todayComponents = servicesProvider.dateFormatService.dateComponents(date: today)
        prevEnable.value = !dateComponents
            .contains {
                $0.isSameDate(dateComponent: todayComponents)
            }
    }
        
    private func fetch(dateComponents: [DateComponents]) {
        isLoading.value = true
        guard
            let first = dateComponents.first,
            let prevDate = servicesProvider.dateFormatService.date(dateComponents: first),
            let qryDate = servicesProvider.dateFormatService.date(bySettingHour: 0, minute: 0, second: 0, date: prevDate)
        else {
            isLoading.value = false
            return
        }
        let string = servicesProvider.dateFormatService.iso8601String(date: qryDate)
        let decoder = JSONDecoder()
        decoder.userInfo[Schedule.infoKey!] = self.servicesProvider.dateFormatService
        servicesProvider.networkService
            .fetch(queryValue: string)
            .decode(type: Schedule.self, decoder: decoder)
            .sink { _ in
                self.isLoading.value = false
            } receiveValue: { schedule in
                self.convert(schedule: schedule)
            }
            .store(in: &cancellables)
    }
    
    private func convert(schedule: Schedule) {
        let availDates = schedule.available
            .flatMap {
                self.servicesProvider.dateFormatService.divids(start: $0.start ,end: $0.end)
            }

        let bookedDates = schedule.booked
            .flatMap {
                self.servicesProvider.dateFormatService.divids(start: $0.start ,end: $0.end)
            }
        
        var dataContents: [[DataContent]] = []
        for datecomponents in intervalsComponents.value {
            guard
                let weekDay = datecomponents.weekday,
                let week = WeekDayType(rawValue: weekDay)?.cht,
                let day = self.servicesProvider.dateFormatService.string(dateFormat: "dd", dateComponents: datecomponents)
            else {
                continue
            }
            var secItems: [(isBooked: Bool, date: Date)] = []
            let availItems = availDates
                .filter {
                    self.servicesProvider.dateFormatService.dateComponents(date: $0)
                        .isSameDate(dateComponent: datecomponents)
                }
                .map { (isBooked: false, date: $0) }
            secItems.append(contentsOf: availItems)
            
            let bookedItems = bookedDates
                .filter {
                    self.servicesProvider.dateFormatService.dateComponents(date: $0)
                        .isSameDate(dateComponent: datecomponents)
                }
                .map { (isBooked: true, date: $0) }
            secItems.append(contentsOf: bookedItems)
            
            let values = secItems
                .sorted { $0.date < $1.date }
                .map { item -> DataContent in
                    let time = self.servicesProvider.dateFormatService.string(dateFormat: "HH:mm", date: item.date)
                    return DataContent.value(time: time, isBooked: item.isBooked)
                }
            var sections: [DataContent] = []
            sections.append(.header(week: week, day: day, canBooked: !values.isEmpty))
            sections.append(contentsOf: values)
            dataContents.append(sections)
        }
        dataSubject.value = dataContents
    }
    
    func goBack() {
        guard
            let dateComponents = intervalsComponents.value.first,
            let aDate = servicesProvider.dateFormatService.date(addingDay: -1, dateComponents: dateComponents)
        else {
            fatalError("get last datecomponents fail")
        }
        intervalsComponents.value = servicesProvider.dateFormatService.weekDateComponents(today: aDate)
    }
    
    func goNext() {
        guard
            let dateComponents = intervalsComponents.value.last,
            let aDate = servicesProvider.dateFormatService.date(addingDay: 1, dateComponents: dateComponents)
        else {
            fatalError("get last datecomponents fail")
        }
        intervalsComponents.value = servicesProvider.dateFormatService.weekDateComponents(today: aDate)
    }
}

enum DataContent {
    case header(week: String, day: String, canBooked: Bool)
    case value(time: String, isBooked: Bool)
}

enum WeekDayType: Int, CaseIterable {
    case sun = 1
    case mon
    case tues
    case wed
    case thur
    case fri
    case sat
    
    var cht: String {
        switch self {
        case .sun:
            return "週日"
        case .mon:
            return "週一"
        case .tues:
            return "週二"
        case .wed:
            return "週三"
        case .thur:
            return "週四"
        case .fri:
            return "週五"
        case .sat:
            return "週六"
        }
    }
}
