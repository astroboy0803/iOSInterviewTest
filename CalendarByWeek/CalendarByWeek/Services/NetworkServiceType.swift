import Foundation
import Combine

protocol NetworkServiceType {
    func fetch(queryValue: String) -> AnyPublisher<Data, URLError>
}
