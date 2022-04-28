import UIKit
import Combine

internal class TopItemViewModel: TopItemCellable {
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

    internal init(id: String, title: String, rank: Int, start: String, end: String?, isFavor: Bool, url: Result<URL, TopItemViewModel.URLEmpty>, loader: AnyPublisher<UIImage?, Never>) {
        self.id = id
        self.title = title
        self.rank = rank
        self.start = start
        self.end = end
        self.isFavor = isFavor
        self.url = url
        self.loader = loader
    }
}

extension TopItemViewModel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: TopItemViewModel, rhs: TopItemViewModel) -> Bool {
        lhs.id == rhs.id
    }
}
