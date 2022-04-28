import Foundation

internal final class URLProtocolMock: URLProtocol {

    typealias networkHandler = (URLRequest) throws -> (HTTPURLResponse, Data?)

    static var handler: networkHandler?

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        guard let handler = URLProtocolMock.handler else {
            assertionFailure("沒有提供URLProtocol Mock Handler")
            return
        }

        do {
            let (resp, data) = try handler(request)
            client?.urlProtocol(self, didReceive: resp, cacheStoragePolicy: .notAllowed)
            if let data = data {
                client?.urlProtocol(self, didLoad: data)
            }
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {

    }
}
