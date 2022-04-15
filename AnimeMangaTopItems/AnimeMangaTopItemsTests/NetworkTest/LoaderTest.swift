import XCTest
import Combine
@testable import AnimeMangaTopItems

class LoaderTest: XCTestCase {

    private var cancellables: Set<AnyCancellable> = []
    
    private let session: URLSession = {
        let config: URLSessionConfiguration = .default
        config.protocolClasses = [URLProtocolMock.self]
        return URLSession(configuration: config)
    }()
    
    private lazy var imgData: Data = {
        guard
            let imgURL = Bundle(for: NetworkServiceTest.self).url(forResource: "Gintama", withExtension: "jpeg"),
            let data = try? Data(contentsOf: imgURL)
        else {
            XCTFail("Failed to create data object from string!")
            return Data()
        }
        return data
    }()
    
    private lazy var loader: ImageLoader = .init(session: session)
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSuccessLoadImage() throws {
        // given
        URLProtocolMock.handler = { request in
            guard let url = request.url else {
                XCTFail("Request URL為空")
                return (.init(), nil)
            }
            guard let resp: HTTPURLResponse = .init(url: url, statusCode: 200, httpVersion: nil, headerFields: nil) else {
                XCTFail("HTTPURLResponse初始失敗")
                return (.init(), nil)
            }
            return (resp, self.imgData)
        }
        let expectation = self.expectation(description: "image loader expectation")
        var image: UIImage?
        
        // when
        loader.loadImage(from: .init(fileURLWithPath: ""))
            .sink { value in
                image = value
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // then
        self.waitForExpectations(timeout: 1.0, handler: nil)
        XCTAssertNotNil(image)
    }
    
    func testFailLoadImage() throws {
        // given
        URLProtocolMock.handler = { request in
            guard let url = request.url else {
                XCTFail("Request URL為空")
                return (.init(), nil)
            }
            guard let resp: HTTPURLResponse = .init(url: url, statusCode: 500, httpVersion: nil, headerFields: nil) else {
                XCTFail("HTTPURLResponse初始失敗")
                return (.init(), nil)
            }
            return (resp, nil)
        }
        let expectation = self.expectation(description: "image loader expectation")
        var image: UIImage?
        
        // when
        loader.loadImage(from: .init(fileURLWithPath: ""))
            .sink { value in
                image = value
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // then
        self.waitForExpectations(timeout: 1.0, handler: nil)
        XCTAssertNil(image)
    }
}
