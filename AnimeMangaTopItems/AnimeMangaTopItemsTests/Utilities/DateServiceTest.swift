import XCTest
@testable import AnimeMangaTopItems

class DateServiceTest: XCTestCase {

    private lazy var dateService: DateFormatterService = .init()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDateConvertString() {
        // given
        let dateString = "2015-04-08T00:00:00+00:00"

        // when
        let date = dateService.date(iso8601String: dateString)

        // then
        XCTAssertNotNil(date)

        // when
        let string = dateService.string(dateFormat: "d LLL, yyyy", date: date!)

        // then
        XCTAssertEqual(string, "8 Apr, 2015")
    }
}
