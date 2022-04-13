import Foundation

internal final class ServicesProvider {
    let network: NetworkServiceType

    init(network: NetworkServiceType) {
        self.network = network
    }

}
