import Combine
import UIKit
@testable import AnimeMangaTopItems

internal final class ImageLoaderMock: ImageLoaderType {
    
    private lazy var imgData: Data? = {
        guard
            let imgURL = Bundle(for: NetworkServiceTest.self).url(forResource: "Gintama", withExtension: "jpeg"),
            let data = try? Data(contentsOf: imgURL)
        else {
            return nil
        }
        return data
    }()
    
    func loadImage(from url: URL) -> AnyPublisher<UIImage?, Never> {
        let image: UIImage?
        if url.absoluteString == "https://cdn.myanimelist.net/images/anime/3/72078.jpg", let imgData = self.imgData {
            image = .init(data: imgData)
        } else {
            image = nil
        }
        return Just(image)
            .eraseToAnyPublisher()
    }
}
