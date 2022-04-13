import UIKit
import Combine

internal protocol TopItemCellable {
    var title: String { get }
    var rank: Int { get }
    var start: String { get }
    var end: String? { get }
    var loader: AnyPublisher<UIImage?, Never> { get }
}
