import UIKit
import Combine

internal struct TopItemViewModel: TopItemCellable {
    enum URLEmpty: Error {
        case invalid(msg: String)
    }
    let id: String
    let title: String
    let rank: Int
    let start: String
    let end: String?
    var isFavor: Bool
    let url: Result<URL, URLEmpty>
    let loader: AnyPublisher<UIImage?, Never>
}

extension TopItemViewModel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: TopItemViewModel, rhs: TopItemViewModel) -> Bool {
        lhs.id == rhs.id
    }
}
