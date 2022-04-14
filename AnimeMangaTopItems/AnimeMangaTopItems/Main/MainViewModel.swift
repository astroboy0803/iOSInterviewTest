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

    let dataSubject: PassthroughSubject<[TopItemViewModel], Never>

    let message: PassthroughSubject<String, Never>

    let linkURL: PassthroughSubject<URL, Never>

    let isLoading: CurrentValueSubject<Bool, Never>

    private var animeCurrentPage: Int
    private var animeLastPage: Int

    private var mangaCurrentPage: Int
    private var mangaLastPage: Int

    private let serviceProvider: ServicesProvider

    private let datePattern: String

    private var favorAnimes: CurrentValueSubject<Set<String>, Never>

    private var favorMangas: CurrentValueSubject<Set<String>, Never>

    init(top: Top, serviceProvider: ServicesProvider) {
        cancellables = []
        animeItems = .init([])
        mangaItems = .init([])
        dataSubject = .init()
        currentTop = .init(top)
        message = .init()
        linkURL = .init()
        isLoading = .init(false)
        self.serviceProvider = serviceProvider

        animeCurrentPage = .zero
        animeLastPage = .max
        mangaCurrentPage = .zero
        mangaLastPage = .max
        datePattern = "d LLL, yyyy"

        favorAnimes = .init(Set(UserDefaults.standard.anime))
        favorMangas = .init(Set(UserDefaults.standard.manga))

        setBinding()
    }

    private func setBinding() {
        currentTop
            .sink { top in
                let items = self.items
                self.dataSubject.send(items)
                guard items.isEmpty else {
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

        favorAnimes
            .sink { favors in
                UserDefaults.standard.anime = Array(favors)
            }
            .store(in: &cancellables)

        favorMangas
            .sink { favors in
                UserDefaults.standard.manga = Array(favors)
            }
            .store(in: &cancellables)
    }

    private func download(top: Top, page: Int) {
        guard !isLoading.value else {
            return
        }
        isLoading.value = true
        switch top {
        case .anime:
            serviceProvider.network.fetchAnime(page: page)
                .sink(receiveCompletion: doCompletion) { dataModel in
                    self.animeCurrentPage = dataModel.pagination.current_page
                    self.animeLastPage = dataModel.pagination.last_visible_page
                    self.animeItems.value.append(contentsOf: dataModel.data
                        .map {
                            let result: Result<URL, TopItemViewModel.URLEmpty>
                            if let urlString = $0.url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: urlString) {
                                result = .success(url)
                            } else {
                                result = .failure(.invalid(msg: $0.url))
                            }
                            let start = self.serviceProvider.dateFormatter.string(dateFormat: self.datePattern, date: $0.aired.from)
                            let end: String?
                            if let eDate = $0.aired.to {
                                end = self.serviceProvider.dateFormatter.string(dateFormat: self.datePattern, date: eDate)
                            } else {
                                end = nil
                            }
                            let id = String($0.mal_id)
                            let isFavor = self.favorAnimes.value.contains(id)
                            return .init(id: id, title: $0.title, rank: $0.rank, start: start, end: end, isFavor: isFavor, url: result, loader: self.serviceProvider.loader.loadImage(from: $0.images.jpg.image_url))
                        })
                    self.isLoading.value = false
                }
                .store(in: &cancellables)

        case .manga:
            serviceProvider.network.fetchManga(page: page)
                .sink(receiveCompletion: doCompletion) { dataModel in
                    self.mangaCurrentPage = dataModel.pagination.current_page
                    self.mangaLastPage = dataModel.pagination.last_visible_page
                    self.mangaItems.value.append(contentsOf: dataModel.data
                        .map {
                            let result: Result<URL, TopItemViewModel.URLEmpty>
                            if let urlString = $0.url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: urlString) {
                                result = .success(url)
                            } else {
                                result = .failure(.invalid(msg: $0.url))
                            }
                            let start = self.serviceProvider.dateFormatter.string(dateFormat: self.datePattern, date: $0.published.from)
                            let end: String?
                            if let eDate = $0.published.to {
                                end = self.serviceProvider.dateFormatter.string(dateFormat: self.datePattern, date: eDate)
                            } else {
                                end = nil
                            }
                            let id = String($0.mal_id)
                            let isFavor = self.favorMangas.value.contains(id)
                            return .init(id: id, title: $0.title, rank: $0.rank, start: start, end: end, isFavor: isFavor, url: result, loader: self.serviceProvider.loader.loadImage(from: $0.images.jpg.image_url))
                        })
                    self.isLoading.value = false
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

    private func showItems(top: Top) -> ([TopItemViewModel]) -> Void {
        return { items in
            if self.currentTop.value == top {
                self.dataSubject.send(items)
            }
        }
    }

    // MARK: - Input
    func change(top: Top) {
        guard top != self.currentTop.value else {
            return
        }
        self.currentTop.value = top
    }

    func linkTo(url: URL) {
        linkURL.send(url)
    }

    func alert(msg: String) {
        message.send(msg)
    }

    func favor(id: String, isFavor: Bool) {
        let favorSubject: CurrentValueSubject<Set<String>, Never>
        let itemSubject: CurrentValueSubject<[TopItemViewModel], Never>
        switch currentTop.value {
        case .anime:
            favorSubject = favorAnimes
            itemSubject = animeItems
        case .manga:
            favorSubject = favorMangas
            itemSubject = mangaItems
        }
        if isFavor && !favorSubject.value.contains(id) {
            favorSubject.value.insert(id)
        } else if !isFavor && favorSubject.value.contains(id) {
            favorSubject.value.remove(id)
        }
        guard let index = itemSubject.value.firstIndex(where: { $0.id == id }) else {
            return
        }
        itemSubject.value[index].isFavor = isFavor
    }

    func item(indexPath: IndexPath) -> TopItemViewModel {
        self.items[indexPath.item]
    }

    func fetch() {
        switch currentTop.value {
        case .anime:
            guard animeCurrentPage < animeLastPage else {
                return
            }
            self.download(top: .anime, page: animeCurrentPage + 1)
        case .manga:
            guard mangaCurrentPage < mangaLastPage else {
                return
            }
            self.download(top: .manga, page: mangaCurrentPage + 1)
        }
    }
}

extension UserDefaults {
    var anime: [String] {
        get {
            value(forKey: "anime") as? [String] ?? []
        }
        set {
            set(newValue, forKey: "anime")
        }
    }

    var manga: [String] {
        get {
            value(forKey: "manga") as? [String] ?? []
        }
        set {
            set(newValue, forKey: "manga")
        }
    }
}
