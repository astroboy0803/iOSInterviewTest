import Foundation
import Combine

internal protocol NetworkServiceType: AnyObject {
    func fetchAnime(page: Int) -> AnyPublisher<AnimeModel, Error>
    func fetchManga(page: Int) -> AnyPublisher<MangaModel, Error>
}
