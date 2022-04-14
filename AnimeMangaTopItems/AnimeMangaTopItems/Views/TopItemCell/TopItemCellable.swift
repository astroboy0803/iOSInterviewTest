import UIKit
import Combine

internal protocol TopItemCellable {
    var id: String { get }
    var title: String { get }
    var rank: Int { get }
    var start: String { get }
    var end: String? { get }
    var isFavor: Bool { get }
    var loader: AnyPublisher<UIImage?, Never> { get }
}
