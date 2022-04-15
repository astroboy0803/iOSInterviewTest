import XCTest
import Combine
@testable import AnimeMangaTopItems

class NetworkServiceTest: XCTestCase {

    private var cancellables: Set<AnyCancellable> = []
    
    private let session: URLSession = {
        let config: URLSessionConfiguration = .ephemeral
        config.protocolClasses = [URLProtocolMock.self]
        return URLSession(configuration: config)
    }()
    
    private lazy var network: NetworkService = .init(session: session)
    
    private lazy var animeJsonData: Data = {
        guard
            let jsonURL = Bundle(for: NetworkServiceTest.self).url(forResource: "Anime", withExtension: "json"),
            let data = try? Data(contentsOf: jsonURL)
        else {
            XCTFail("Failed to create data object from string!")
            return Data()
        }
        return data
    }()
    
    private lazy var mangaJsonData: Data = {
        guard
            let jsonURL = Bundle(for: NetworkServiceTest.self).url(forResource: "Manga", withExtension: "json"),
            let data = try? Data(contentsOf: jsonURL)
        else {
            XCTFail("Failed to create data object from string!")
            return Data()
        }
        return data
    }()
        
    override func setUpWithError() throws {

    }

    override func tearDownWithError() throws {
        
    }

    func testAnimeSuccess() throws {
        // given
        URLProtocolMock.handler = getSuccessHandler(jsonData: animeJsonData)
        let expectation = self.expectation(description: "anime network service expectation")
        var result: Result<AnimeModel, Error>?
        
        // when
        network.fetchAnime(page: 1)
            .map { animeModel -> Result<AnimeModel, Error> in
                .success(animeModel)
            }
            .catch { error -> AnyPublisher<Result<AnimeModel, Error>, Never> in
                Just(.failure(error))
                    .eraseToAnyPublisher()
            }
            .sink { value in
                result = value
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // then
        self.waitForExpectations(timeout: 1.0, handler: nil)
        guard case let .success(animeModel) = result else {
            XCTFail("testAnimeSuccess is fail")
            return
        }
        XCTAssertEqual(animeModel.data.count, 25)
    }
    
    func testMangaSuccess() throws {
        // given
        URLProtocolMock.handler = getSuccessHandler(jsonData: mangaJsonData)
        let expectation = self.expectation(description: "manga network service expectation")
        var result: Result<MangaModel, Error>?
        
        // when
        network.fetchManga(page: 1)
            .map { mangaModel -> Result<MangaModel, Error> in
                .success(mangaModel)
            }
            .catch { error -> AnyPublisher<Result<MangaModel, Error>, Never> in
                Just(.failure(error))
                    .eraseToAnyPublisher()
            }
            .sink { value in
                result = value
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // then
        self.waitForExpectations(timeout: 1.0, handler: nil)
        guard case let .success(mangaModel) = result else {
            XCTFail("testMangaSuccess is fail")
            return
        }
        XCTAssertEqual(mangaModel.data.count, 25)
    }
    
    private func getSuccessHandler(jsonData: Data) -> URLProtocolMock.networkHandler {
         { request in
            guard let url = request.url else {
                XCTFail("Request URL為空")
                return (.init(), nil)
            }
            guard let resp: HTTPURLResponse = .init(url: url, statusCode: 200, httpVersion: nil, headerFields: nil) else {
                XCTFail("HTTPURLResponse初始失敗")
                return (.init(), nil)
            }
            return (resp, jsonData)
        }
    }
    
    func testAnimeFail() throws {
        // given
        URLProtocolMock.handler = getFailHandler()
        let expectation = self.expectation(description: "anime network service expectation")
        var result: Result<AnimeModel, Error>?
        
        // when
        network.fetchAnime(page: 1)
            .map { animeModel -> Result<AnimeModel, Error> in
                .success(animeModel)
            }
            .catch { error -> AnyPublisher<Result<AnimeModel, Error>, Never> in
                Just(.failure(error))
                    .eraseToAnyPublisher()
            }
            .sink { value in
                result = value
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // then
        self.waitForExpectations(timeout: 1.0, handler: nil)
        guard
            case .failure(let error) = result,
            let networkError = error as? NetworkService.NetworkError,
            case NetworkService.NetworkError.status(code: 500, data: _) = networkError
        else {
            XCTFail("testAnimeFail is fail")
            return
        }
    }
    
    func testMangaFail() throws {
        // given
        URLProtocolMock.handler = getFailHandler()
        let expectation = self.expectation(description: "manga network service expectation")
        var result: Result<MangaModel, Error>?
        
        // when
        network.fetchManga(page: 1)
            .map { mangaModel -> Result<MangaModel, Error> in
                .success(mangaModel)
            }
            .catch { error -> AnyPublisher<Result<MangaModel, Error>, Never> in
                Just(.failure(error))
                    .eraseToAnyPublisher()
            }
            .sink { value in
                result = value
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // then
        self.waitForExpectations(timeout: 1.0, handler: nil)
        guard
            case .failure(let error) = result,
            let networkError = error as? NetworkService.NetworkError,
            case NetworkService.NetworkError.status(code: 500, data: _) = networkError
        else {
            XCTFail("testMangaFail is fail")
            return
        }
    }
    
    private func getFailHandler() -> URLProtocolMock.networkHandler {
         { request in
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
    }
}
