import UIKit
import Combine

internal struct TopItemViewModel {
    let title: String
    let rank: Int
    let start: String
    let end: String?
    let loader: AnyPublisher<UIImage?, Never>?
}
