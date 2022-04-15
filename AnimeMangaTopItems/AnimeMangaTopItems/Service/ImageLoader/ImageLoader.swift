import UIKit
import Combine

internal final class ImageLoader: ImageLoaderType {

    private let cache: ImageCacheType
    
    private let session: URLSession

    init(session: URLSession = URLSession.shared, cache: ImageCacheType = ImageCache()) {
        self.session = session
        self.cache = cache
    }

    func loadImage(from url: URL) -> AnyPublisher<UIImage?, Never> {
        if let image = cache.image(url: url) {
            return Just(image)
                .eraseToAnyPublisher()
        }
        return session.dataTaskPublisher(for: url)
            .map { data, _ -> UIImage? in
                let image = UIImage(data: data)
                return image
            }
            .catch { _ in
                Just(nil)
            }
            .handleEvents(receiveOutput: { image in
                self.cache[url] = image
            })
            .eraseToAnyPublisher()
    }
}
