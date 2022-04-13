import UIKit

internal protocol ImageCacheType: AnyObject {
    func image(url: URL) -> UIImage?
    func insert(image: UIImage, for url: URL)
    func remove(for url: URL)
    func removeAll()
    subscript(_ url: URL) -> UIImage? { get set }
}
