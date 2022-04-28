import Foundation
import Combine

internal final class MainViewModel {

    enum SectionID: String {
        case manga
        case anime
        case favorAnime = "Anime"
        case favorManga = "Manga"
    }

    private var cancellables: Set<AnyCancellable>

    private let currentTop: CurrentValueSubject<Top, Never>

    private let animeItems: CurrentValueSubject<[AnimeModel.AnimeData], Never>

    private let mangaItems: CurrentValueSubject<[MangaModel.MangaData], Never>

    private var sections: [TopSectionViewModel] {
        switch currentTop.value {
        case .anime:
            return [
                .init(sid: SectionID.anime.rawValue, top: .anime, datas: convert(animes: animeItems.value))
            ]
        case .manga:
            return [
                .init(sid: SectionID.anime.rawValue, top: .manga, datas: convert(mangas: mangaItems.value))
            ]
        case .favorite:
            return [
                .init(sid: SectionID.favorAnime.rawValue, top: .favorite, datas: convert(animes: UserDefaults.standard.animeItems)),
                .init(sid: SectionID.favorManga.rawValue, top: .favorite, datas: convert(mangas: UserDefaults.standard.mangaItems))
            ]
        }
    }

    let dataSubject: CurrentValueSubject<[TopSectionViewModel], Never>

    let message: PassthroughSubject<String, Never>

    let linkURL: PassthroughSubject<URL, Never>

    let isLoading: CurrentValueSubject<Bool, Never>

    private var animeCurrentPage: Int
    private var animeLastPage: Int

    private var mangaCurrentPage: Int
    private var mangaLastPage: Int

    private let serviceProvider: ServicesProvider

    private let datePattern: String

    init(top: Top, serviceProvider: ServicesProvider) {
        cancellables = []

        // data
        animeItems = .init([])
        mangaItems = .init([])

        dataSubject = .init([])
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

        setBinding()
    }

    private func setBinding() {
        currentTop
            .sink { top in
                let sections = self.sections
                self.dataSubject.send(sections)
                switch top {
                case .favorite:
                    return
                case .anime, .manga:
                    guard sections[0].datas.value.isEmpty else {
                        return
                    }
                    self.download(top: top, page: 1)
                }
            }
            .store(in: &cancellables)

        animeItems
            .sink { animes in
                if self.currentTop.value == .anime {
                    self.dataSubject.send([
                        .init(sid: SectionID.anime.rawValue, top: .anime, datas: self.convert(animes: animes))
                    ])
                }
            }
            .store(in: &cancellables)

        mangaItems
            .sink { mangas in
                if self.currentTop.value == .manga {
                    self.dataSubject.send([
                        .init(sid: SectionID.manga.rawValue, top: .manga, datas: self.convert(mangas: mangas))
                    ])
                }
            }
            .store(in: &cancellables)
    }

    private func convert(animes: [AnimeModel.AnimeData]) -> [TopItemViewModel] {
        animes
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
                let isFavor = self.isFavor(top: .anime, id: id)
                return .init(id: id, title: $0.title, rank: $0.rank, start: start, end: end, isFavor: isFavor, url: result, loader: self.serviceProvider.loader.loadImage(from: $0.images.jpg.image_url))
            }
    }

    private func convert(mangas: [MangaModel.MangaData]) -> [TopItemViewModel] {
        mangas
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
                let isFavor = isFavor(top: .manga, id: id)
                return .init(id: id, title: $0.title, rank: $0.rank, start: start, end: end, isFavor: isFavor, url: result, loader: self.serviceProvider.loader.loadImage(from: $0.images.jpg.image_url))
            }
    }

    private func isFavor(top: Top, id: String) -> Bool {
        switch top {
        case .anime:
            return UserDefaults.standard.animeItems.contains(where: { String($0.mal_id) == id })
        case .manga:
            return UserDefaults.standard.mangaItems.contains(where: { String($0.mal_id) == id })
        case .favorite:
            return true
        }
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
                    self.animeItems.value.append(contentsOf: dataModel.data)
                    self.isLoading.value = false
                }
                .store(in: &cancellables)

        case .manga:
            serviceProvider.network.fetchManga(page: page)
                .sink(receiveCompletion: doCompletion) { dataModel in
                    self.mangaCurrentPage = dataModel.pagination.current_page
                    self.mangaLastPage = dataModel.pagination.last_visible_page
                    self.mangaItems.value.append(contentsOf: dataModel.data)
                    self.isLoading.value = false
                }
                .store(in: &cancellables)
        case .favorite:
            break
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

    // MARK: - Input

    // MARK: 切換顯示內容
    func change(top: Top) {
        guard top != self.currentTop.value else {
            return
        }
        self.currentTop.value = top
    }

    // MARK: 開啟網頁
    func linkTo(url: URL) {
        linkURL.send(url)
    }

    // MARK: 提示訊息
    func alert(msg: String) {
        message.send(msg)
    }

    // MARK: 加入或移除我的最愛
    func favor(indexPath: IndexPath, isFavor: Bool) {
        let top = currentTop.value
        switch top {
        case .anime:
            updateTopItem(indexPath: indexPath, isFavor: isFavor)
        case .manga:
            updateTopItem(indexPath: indexPath, isFavor: isFavor)
        case .favorite:
            break
        }
        updateStore(indexPath: indexPath, top: top, isFavor: isFavor)
    }

    private func updateTopItem(indexPath: IndexPath, isFavor: Bool) {
        item(indexPath: indexPath).isFavor = isFavor
    }

    private func updateStore(indexPath: IndexPath, top: Top, isFavor: Bool) {
        switch top {
        case .anime:
            var animeDatas = UserDefaults.standard.animeItems
            let item = animeItems.value[indexPath.item]
            let index = animeDatas.firstIndex {
                $0.mal_id == item.mal_id
            }
            if isFavor && index == nil {
                animeDatas.append(item)
            } else if !isFavor, let index = index {
                animeDatas.remove(at: index)
            }
            UserDefaults.standard.animeItems = animeDatas
        case .manga:
            var mangaDatas = UserDefaults.standard.mangaItems
            let item = mangaItems.value[indexPath.item]
            let index = mangaDatas.firstIndex {
                $0.mal_id == item.mal_id
            }
            if isFavor && index == nil {
                mangaDatas.append(item)
            } else if !isFavor, let index = index {
                mangaDatas.remove(at: index)
            }
            UserDefaults.standard.mangaItems = mangaDatas
        case .favorite:
            guard let aTop = Top(rawValue: indexPath.section) else {
                return
            }
            switch aTop {
            case .anime:
                var datas = UserDefaults.standard.animeItems
                datas.remove(at: indexPath.item)
                UserDefaults.standard.animeItems = datas
            case .manga:
                var datas = UserDefaults.standard.mangaItems
                datas.remove(at: indexPath.item)
                UserDefaults.standard.mangaItems = datas
            case .favorite:
                break
            }
            self.dataSubject.send(sections)
        }
    }

    // MARK: 取得selected cell的資料
    func item(indexPath: IndexPath) -> TopItemViewModel {
        dataSubject.value[indexPath.section].datas.value[indexPath.item]
    }

    // MARK: 擷取更多資料
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
        case .favorite:
            return
        }
    }
}

extension UserDefaults {

    private var animeItemsKey: String {
        "__animeItemsKey__"
    }

    private var mangaItemsKey: String {
        "__mangaItemsKey__"
    }

    var animeItems: [AnimeModel.AnimeData] {
        get {
            guard
                let jsonData = data(forKey: animeItemsKey),
                let items = try? JSONDecoder().decode([AnimeModel.AnimeData].self, from: jsonData)
            else {
                return []
            }
            return items.sorted {
                $0.rank < $1.rank
            }
        }
        set {
            guard let jsonData = try? JSONEncoder().encode(newValue) else {
                return
            }
            set(jsonData, forKey: animeItemsKey)
        }
    }

    var mangaItems: [MangaModel.MangaData] {
        get {
            guard
                let jsonData = data(forKey: mangaItemsKey),
                let items = try? JSONDecoder().decode([MangaModel.MangaData].self, from: jsonData)
            else {
                return []
            }
            return items.sorted {
                $0.rank < $1.rank
            }
        }
        set {
            guard let jsonData = try? JSONEncoder().encode(newValue) else {
                return
            }
            set(jsonData, forKey: mangaItemsKey)
        }
    }
}
