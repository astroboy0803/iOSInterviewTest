import Combine
import UIKit

internal protocol ImageLoaderType: AnyObject {
    func loadImage(from url: URL) -> AnyPublisher<UIImage?, Never>
}
