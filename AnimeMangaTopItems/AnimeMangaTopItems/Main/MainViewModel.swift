import Foundation
import Combine

internal final class MainViewModel {

    private var cancellables: Set<AnyCancellable>

    private let currentTop: CurrentValueSubject<Top, Never>
    
    private let animeItems: CurrentValueSubject<[TopItemViewModel], Never>
    
    private let mangaItems: CurrentValueSubject<[TopItemViewModel], Never>
    
    private var items: [TopItemViewModel] {
        switch currentTop.value {
        case .anime:
            return animeItems.value
        case .manga:
            return mangaItems.value
        }
    }
    
    let dataSubject: CurrentValueSubject<[TopItemViewModel], Never>
    
    let message: PassthroughSubject<String, Never>
    
    private var animeCurrentPage: Int
    private var animeLastPage: Int
    
    private var mangaCurrentPage: Int
    private var mangaLastPage: Int
    
    private let serviceProvider: ServicesProvider
    
    private let dateFormat: String
    
    init(top: Top, serviceProvider: ServicesProvider) {
        cancellables = []
        animeItems = .init([])
        mangaItems = .init([])
        dataSubject = .init([])
        currentTop = .init(top)
        message = .init()
        self.serviceProvider = serviceProvider
        
        animeCurrentPage = .zero
        animeLastPage = .max
        mangaCurrentPage = .zero
        mangaLastPage = .max
        dateFormat = "d LLL, yyyy"
        
        setBinding()
    }
    
    private func setBinding() {
        currentTop
            .sink { top in
                self.dataSubject.value = self.items
                guard self.dataSubject.value.isEmpty else {
                    return
                }
                self.download(top: top, page: 1)
            }
            .store(in: &cancellables)
        
        animeItems
            .sink(receiveValue: showItems(top: .anime))
            .store(in: &cancellables)
        mangaItems
            .sink(receiveValue: showItems(top: .manga))
            .store(in: &cancellables)
    }
    
    private func download(top: Top, page: Int) {
        switch top {
        case .anime:
            animeCurrentPage = page
            serviceProvider.network.fetchAnime(page: page)
                .sink(receiveCompletion: doCompletion) { dataModel in
                    self.animeCurrentPage = dataModel.pagination.current_page
                    self.animeLastPage = dataModel.pagination.last_visible_page
                    self.animeItems.value = dataModel.data
                        .map {
                            let result: Result<URL, TopItemViewModel.URLEmpty>
                            if let urlString = $0.url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: urlString) {
                                result = .success(url)
                            } else {
                                result = .failure(.invalid(msg: $0.url))
                            }
                            let start = self.serviceProvider.dateFormatter.string(dateFormat: self.dateFormat, date: $0.aired.from)
                            let end: String?
                            if let eDate = $0.aired.to {
                                end = self.serviceProvider.dateFormatter.string(dateFormat: self.dateFormat, date: eDate)
                            } else {
                                end = nil
                            }
                            return .init(id: $0.mal_id, title: $0.title, rank: $0.rank, start: start, end: end, url: result, loader: self.serviceProvider.loader.loadImage(from: $0.images.jpg.image_url))
                        }
                }
                .store(in: &cancellables)

        case .manga:
            mangaCurrentPage = page
            serviceProvider.network.fetchManga(page: page)
                .sink(receiveCompletion: doCompletion) { dataModel in
                    self.mangaCurrentPage = dataModel.pagination.current_page
                    self.mangaLastPage = dataModel.pagination.last_visible_page
                    self.mangaItems.value = dataModel.data
                        .map {
                            let result: Result<URL, TopItemViewModel.URLEmpty>
                            if let urlString = $0.url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: urlString) {
                                result = .success(url)
                            } else {
                                result = .failure(.invalid(msg: $0.url))
                            }
                            let start = self.serviceProvider.dateFormatter.string(dateFormat: self.dateFormat, date: $0.published.from)
                            let end: String?
                            if let eDate = $0.published.to {
                                end = self.serviceProvider.dateFormatter.string(dateFormat: self.dateFormat, date: eDate)
                            } else {
                                end = nil
                            }
                            return .init(id: $0.mal_id, title: $0.title, rank: $0.rank, start: start, end: end, url: result, loader: self.serviceProvider.loader.loadImage(from: $0.images.jpg.image_url))
                        }
                }
                .store(in: &cancellables)
        }
    }
    
    private func doCompletion(completion: Subscribers.Completion<Error>) {
        switch completion {
        case .finished:
            break
        case let .failure(error):
            guard let network = error as? NetworkService.NetworkError else {
                self.message.send("擷取資料失敗")
                return
            }
            self.message.send(network.message)
        }
    }
    
    private func showItems(top: Top) -> ([TopItemViewModel]) -> () {
        return { items in
            if self.currentTop.value == top {
                self.dataSubject.value = items
            }
        }
    }
    
    func change(top: Top) {
        self.currentTop.value = top
    }
}
