import Foundation
import Combine

internal final class MainViewModel {

    private var cancellables: Set<AnyCancellable>

    private(set) var datas: CurrentValueSubject<[AnimeModel.AnimeData], Never>

    init() {
        datas = .init([])
        cancellables = []
    }

    // TODO: 
    func loadTest() {
        // TODO: test loading
//        NetworkService().fetch(path: "/v4/top/anime", page: 1, type: AnimeModel.self)

        NetworkService().fetchAnime(page: 1)
            .sink { completion in
                print(completion)
            } receiveValue: { model in
                self.datas.value.append(contentsOf: model.data)
            }
            .store(in: &cancellables)

//        NetworkService().fetchManga(page: 1)
//            .sink { completion in
//                print(completion)
//            } receiveValue: { model in
//                print(model.data)
//            }
//            .store(in: &cancellables)
    }
}
