import Foundation
import Combine
@testable import AnimeMangaTopItems

internal final class NetworkServiceMock: NetworkServiceType {
    enum NetworkMockError: Error {
        case dataNotFound
    }
    
    func fetchAnime(page: Int) -> AnyPublisher<AnimeModel, Error> {
        guard let data = jsonData(prefix: "Anime", page: page) else {
            return Fail(error: NetworkMockError.dataNotFound)
                .eraseToAnyPublisher()
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return Just(data)
            .decode(type: AnimeModel.self, decoder: decoder)
            .eraseToAnyPublisher()
    }
    
    func fetchManga(page: Int) -> AnyPublisher<MangaModel, Error> {
        guard let data = jsonData(prefix: "Manga", page: page) else {
            return Fail(error: NetworkMockError.dataNotFound)
                .eraseToAnyPublisher()
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return Just(data)
            .decode(type: MangaModel.self, decoder: decoder)
            .eraseToAnyPublisher()
    }
    
    private func jsonData(prefix: String, page: Int) -> Data? {
        guard
            let jsonURL = Bundle(for: NetworkServiceTest.self).url(forResource: "\(prefix)-\(page)", withExtension: "json"),
            let data = try? Data(contentsOf: jsonURL)
        else {
            return nil
        }
        return data
    }
}
