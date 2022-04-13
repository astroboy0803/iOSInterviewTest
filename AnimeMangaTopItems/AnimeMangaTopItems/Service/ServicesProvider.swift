import Foundation

internal final class ServicesProvider {
    let network: NetworkServiceType
    let loader: ImageLoaderType
    let dateFormatter: DateFormatterService

    init(network: NetworkServiceType, loader: ImageLoaderType) {
        self.dateFormatter = .init()
        self.network = network
        self.loader = loader
    }
}
