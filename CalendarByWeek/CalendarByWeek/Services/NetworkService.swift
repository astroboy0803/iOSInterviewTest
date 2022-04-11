import Foundation
import Combine

internal final class NetworkService: NetworkServiceType {
    func fetch(queryValue: String) -> AnyPublisher<Data, URLError> {
        var components: URLComponents = .init()
        components.scheme = "https"
        components.host = "tw.amazingtalker.com"
        components.path = "/v1/guest/teachers/celia-he/schedule"
        components.queryItems = [
            .init(name: "started_at", value: queryValue)
        ]
        guard let url = components.url else {
            fatalError("convert url fail")
        }
        var request: URLRequest = .init(url: url)
        request.httpMethod = "GET"
        return URLSession.shared
            .dataTaskPublisher(for: request)
            .map { (data, _) -> Data in
                return data
            }
            .eraseToAnyPublisher()
    }
}
