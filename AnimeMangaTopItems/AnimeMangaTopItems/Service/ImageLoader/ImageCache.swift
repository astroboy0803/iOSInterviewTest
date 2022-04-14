import UIKit

internal final class ImageCache: NSObject, ImageCacheType {

    private let cache: NSCache<AnyObject, AnyObject>

    init(countMB: Int = 100) {
        cache = .init()
        super.init()
        cache.totalCostLimit = countMB * 1024 * 1024
        cache.delegate = self
    }

    func image(url: URL) -> UIImage? {
        let obj = cache.object(forKey: url as AnyObject)
        let img = obj as? UIImage
        return img
    }

    func insert(image: UIImage, for url: URL) {
        let imgSize: Int
        if let cgImage = image.cgImage {
            imgSize = cgImage.bytesPerRow * cgImage.height
        } else {
            imgSize = .zero
        }
        cache.setObject(image as AnyObject, forKey: url as AnyObject, cost: imgSize)
    }

    func remove(for url: URL) {
        cache.removeObject(forKey: url as AnyObject)
    }

    func removeAll() {
        cache.removeAllObjects()
    }

    subscript(url: URL) -> UIImage? {
        get {
            image(url: url)
        }
        set {
            guard let image = newValue else {
                remove(for: url)
                return
            }
            insert(image: image, for: url)
        }
    }
}

extension ImageCache: NSCacheDelegate {
    func cache(_ cache: NSCache<AnyObject, AnyObject>, willEvictObject obj: Any) {

    }
}
