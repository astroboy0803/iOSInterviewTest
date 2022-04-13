import UIKit
import Combine

internal struct TopItemViewModel: TopItemCellable, Identifiable {
    enum URLEmpty: Error {
        case invalid(msg: String)
    }
    
    let id: Int
    let title: String
    let rank: Int
    let start: String
    let end: String?
    let url: Result<URL, URLEmpty>
    let loader: AnyPublisher<UIImage?, Never>
}
