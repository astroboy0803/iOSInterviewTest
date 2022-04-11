import Foundation

internal final class ServicesProvider {
    let dateFormatService: DateFormatterService
    let networkService: NetworkServiceType
    
    init(networkService: NetworkServiceType) {
        self.dateFormatService = .init()
        self.networkService = networkService
    }
}
