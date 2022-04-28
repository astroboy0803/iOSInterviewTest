import Foundation
import Combine

internal final class NetworkService: NetworkServiceType {

    private let session: URLSession

    init(session: URLSession = URLSession(configuration: .ephemeral)) {
        self.session = session
    }

    enum NetworkError: Error {
        case url
        case request
        case response
        case status(code: Int, data: Data)

        var message: String {
            switch self {
            case .url:
                return "網址有誤"
            case .request:
                return "請求失敗"
            case .response:
                return "回應失敗"
            case let .status(code, _):
                return "回應狀態有誤(code=\(code))"
            }
        }
    }

    func fetchAnime(page: Int) -> AnyPublisher<AnimeModel, Error> {
        self.fetch(path: "/v4/top/anime", page: page, decodeType: AnimeModel.self)
    }

    func fetchManga(page: Int) -> AnyPublisher<MangaModel, Error> {
        self.fetch(path: "/v4/top/manga", page: page, decodeType: MangaModel.self)
    }

    private func fetch<T: Codable>(path: String, page: Int, decodeType: T.Type) -> AnyPublisher<T, Error> {
        var components: URLComponents = .init()
        components.scheme = "https"
        components.host = "api.jikan.moe"
        components.path = path
        components.queryItems = [
            .init(name: "page", value: String(page))
        ]
        guard let url = components.url else {
            return Fail(error: NetworkError.url).eraseToAnyPublisher()
        }
        var request: URLRequest = .init(url: url)
        request.httpMethod = "GET"
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return session.dataTaskPublisher(for: request)
            .mapError { _ in NetworkError.request }
            .flatMap { data, resp -> AnyPublisher<Data, Error> in
                guard let response = resp as? HTTPURLResponse else {
                    return Fail(error: NetworkError.response).eraseToAnyPublisher()
                }

                guard 200..<300 ~= response.statusCode else {
                    return Fail(error: NetworkError.status(code: response.statusCode, data: data))
                        .eraseToAnyPublisher()
                }
                return Just(data)
                    .catch { _ in Empty().eraseToAnyPublisher() }
                    .eraseToAnyPublisher()
            }
            .decode(type: T.self, decoder: decoder)
            .eraseToAnyPublisher()
    }
}
