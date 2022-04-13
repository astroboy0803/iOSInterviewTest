import UIKit
import Combine

internal final class ImageLoader: ImageLoaderType {

    private let cache: ImageCacheType

    init(cache: ImageCacheType = ImageCache()) {
        self.cache = cache
    }

    func loadImage(from url: URL) -> AnyPublisher<UIImage?, Never> {
        if let image = cache.image(url: url) {
            print(">>> get cache image")
            return Just(image)
                .eraseToAnyPublisher()
        }
        return URLSession.shared.dataTaskPublisher(for: url)
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
