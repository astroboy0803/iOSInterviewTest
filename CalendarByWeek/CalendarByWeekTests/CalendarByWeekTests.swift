//
//  CalendarByWeekTests.swift
//  CalendarByWeekTests
//
//  Created by BruceHuang on 2022/4/11.
//

import XCTest
@testable import CalendarByWeek

class CalendarByWeekTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    func testCalendarViewModel() throws {
        let serviceProvider = ServicesProvider(networkService: NetworkServiceMock())
        let date: Date = .init(timeIntervalSince1970: 1648915200.0)
        let viewModel = CalendarViewModel(servicesProvider: serviceProvider, date: date)
        
        // satate
        let timezone = serviceProvider.dateFormatService.string(dateFormat: "v (OOOO)", date: date)
        XCTAssertEqual(timezone, viewModel.timezoneInfo.value)
        XCTAssertEqual(false, viewModel.isLoading.value)
        XCTAssertEqual(false, viewModel.dateInterval.value?.isEmpty)
        XCTAssertEqual(false, viewModel.prevEnable.value)
        
        // data
        XCTAssertEqual(7, viewModel.dataSubject.value.count)
        var hCount: Int = .zero
        var vCount: Int = .zero
        for item in viewModel.dataSubject.value.last ?? [] {
            switch item {
            case .header:
                hCount += 1
            case .value:
                vCount += 1
            }
        }
        XCTAssertEqual(1, hCount)
        XCTAssertEqual(3, vCount)
        
        testGoNext(viewModel: viewModel, timezone: timezone)
        
        testGoBack(viewModel: viewModel, timezone: timezone)
    }
    
    private func testGoNext(viewModel: CalendarViewModel, timezone: String) {
        viewModel.goNext()
        XCTAssertEqual(timezone, viewModel.timezoneInfo.value)
        XCTAssertEqual(false, viewModel.isLoading.value)
        XCTAssertEqual(false, viewModel.dateInterval.value?.isEmpty)
        XCTAssertEqual(true, viewModel.prevEnable.value)
        
        // data
        XCTAssertEqual(7, viewModel.dataSubject.value.count)
        var hCount: Int = .zero
        var vCount: Int = .zero
        var bCount: Int = .zero
        let bTimes: [String] = ["10:00","17:00","17:30","19:30","20:00","21:00","21:30"]
        for item in viewModel.dataSubject.value[4] {
            switch item {
            case .header:
                hCount += 1
            case let .value(time, isBooked):
                vCount += 1
                if isBooked {
                    bCount += 1
                }
                XCTAssertEqual(isBooked, bTimes.contains(time))
            }
        }
        XCTAssertEqual(1, hCount)
        XCTAssertEqual(30, vCount)
        XCTAssertEqual(7, bCount)
    }

    private func testGoBack(viewModel: CalendarViewModel, timezone: String) {
        viewModel.goBack()
        XCTAssertEqual(timezone, viewModel.timezoneInfo.value)
        XCTAssertEqual(false, viewModel.isLoading.value)
        XCTAssertEqual(false, viewModel.dateInterval.value?.isEmpty)
        XCTAssertEqual(false, viewModel.prevEnable.value)
        
        // data
        XCTAssertEqual(7, viewModel.dataSubject.value.count)
        var hCount: Int = .zero
        var vCount: Int = .zero
        for item in viewModel.dataSubject.value.last ?? [] {
            switch item {
            case .header:
                hCount += 1
            case .value:
                vCount += 1
            }
        }
        XCTAssertEqual(1, hCount)
        XCTAssertEqual(3, vCount)
    }
}
