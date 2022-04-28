import XCTest
import Combine
@testable import AnimeMangaTopItems

class MainTest: XCTestCase {

    private var cancellables: Set<AnyCancellable> = []

    private lazy var viewModel: MainViewModel = .init(top: .anime, serviceProvider: .init(network: NetworkServiceMock(), loader: ImageLoaderMock()))

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        UserDefaults.standard.animeItems = []
        UserDefaults.standard.mangaItems = []
        cancellables.removeAll()
    }
    
    // MARK: 初始狀態
    func testInitState() {
        // given
        
        // when
        
        // then
        XCTAssertEqual(viewModel.dataSubject.value.count, 1)
        XCTAssertEqual(viewModel.dataSubject.value[0].datas.value.count, 2)
        XCTAssertEqual(viewModel.isLoading.value, false)
    }

    // MARK: 切換頁籤
    func testChangeTab() {
        // given
        var isLoadings: [Bool] = []
        viewModel.isLoading
            .sink { value in
                isLoadings.append(value)
            }
            .store(in: &cancellables)
        

        // when
        viewModel.change(top: .manga)

        // then
        XCTAssertEqual(viewModel.dataSubject.value.count, 1)
        XCTAssertEqual(viewModel.dataSubject.value[0].datas.value.count, 2)
        XCTAssertEqual(isLoadings, [false, true, false])

        // given
        isLoadings.removeAll()

        // when
        viewModel.change(top: .favorite)

        // then
        XCTAssertEqual(viewModel.dataSubject.value.count, 2)
        XCTAssertEqual(viewModel.dataSubject.value[0].datas.value.count, 0)
        XCTAssertEqual(viewModel.dataSubject.value[1].datas.value.count, 0)
        XCTAssertEqual(isLoadings, [])

        // given
        isLoadings.removeAll()

        // when
        viewModel.change(top: .anime)

        // then
        XCTAssertEqual(viewModel.dataSubject.value.count, 1)
        XCTAssertEqual(viewModel.dataSubject.value[0].datas.value.count, 2)
        XCTAssertEqual(isLoadings, [])
    }

    // MARK: 開起連結
    func testOpenLink() {
        // given
        guard let destURL: URL = .init(string: "https://myanimelist.net/anime/5114/Fullmetal_Alchemist__Brotherhood") else {
            XCTFail("設定URL網址失敗")
            return
        }
        var toURL: URL?
        viewModel.linkURL
            .sink { url in
                toURL = url
            }
            .store(in: &cancellables)

        // when
        viewModel.linkTo(url: destURL)

        // then
        XCTAssertEqual(destURL, toURL)
    }

    // MARK: 提示訊息
    func testAlertMessage() {
        // given
        let message = "錯誤訊息"
        var msg: String?
        viewModel.message
            .sink { value in
                msg = value
            }
            .store(in: &cancellables)

        // when
        viewModel.alert(msg: message)

        // then
        XCTAssertEqual(msg, message)
    }
    
    // MARK: 取得更多資料
    func testFetchMore() {
        // given
        var isLoadings: [Bool] = []
        viewModel.isLoading
            .sink { value in
                isLoadings.append(value)
            }
            .store(in: &cancellables)

        // when
        viewModel.fetch()

        // then
        XCTAssertEqual(viewModel.dataSubject.value.count, 1)
        XCTAssertEqual(viewModel.dataSubject.value[0].datas.value.count, 4)
        XCTAssertEqual(isLoadings, [false, true, false])

        // given
        isLoadings.removeAll()

        // when
        viewModel.fetch()

        // then
        XCTAssertEqual(viewModel.dataSubject.value.count, 1)
        XCTAssertEqual(viewModel.dataSubject.value[0].datas.value.count, 6)
        XCTAssertEqual(isLoadings, [true, false])

        // given
        isLoadings.removeAll()

        // when
        viewModel.fetch()

        // then
        XCTAssertEqual(viewModel.dataSubject.value.count, 1)
        XCTAssertEqual(viewModel.dataSubject.value[0].datas.value.count, 6)
        XCTAssertTrue(isLoadings.isEmpty)
    }

    // MARK: 加入與移除我的最愛
    func testFavor() {
        var isFavor = true
        var indexPath: IndexPath = .init(item: 0, section: 0)

        // given
        viewModel.change(top: .anime)
        let animeItem = viewModel.item(indexPath: indexPath)

        // when
        viewModel.favor(indexPath: indexPath, isFavor: isFavor)

        // then
        XCTAssertEqual(animeItem.isFavor, isFavor)
        XCTAssertTrue(UserDefaults.standard.animeItems.contains { String($0.mal_id) == animeItem.id })
                
        // given
        viewModel.change(top: .manga)
        let mangaItem = viewModel.item(indexPath: indexPath)
        
        // when
        viewModel.favor(indexPath: indexPath, isFavor: isFavor)
        
        // then
        XCTAssertEqual(mangaItem.isFavor, isFavor)
        XCTAssertTrue(UserDefaults.standard.mangaItems.contains { String($0.mal_id) == mangaItem.id })
        
        // given
        viewModel.change(top: .favorite)
        
        // then
        XCTAssertEqual(viewModel.dataSubject.value.count, 2)
        XCTAssertEqual(viewModel.dataSubject.value[0].datas.value.count, 1)
        XCTAssertEqual(viewModel.dataSubject.value[0].datas.value.first?.id, animeItem.id)
        XCTAssertEqual(viewModel.dataSubject.value[1].datas.value.count, 1)
        XCTAssertEqual(viewModel.dataSubject.value[1].datas.value.first?.id, mangaItem.id)

        // given
        isFavor.toggle()
        indexPath = .init(item: 0, section: 1)

        // when
        viewModel.favor(indexPath: indexPath, isFavor: isFavor)

        // then
        XCTAssertEqual(viewModel.dataSubject.value.count, 2)
        XCTAssertEqual(viewModel.dataSubject.value[0].datas.value.count, 1)
        XCTAssertEqual(viewModel.dataSubject.value[0].datas.value.first?.id, animeItem.id)
        XCTAssertEqual(viewModel.dataSubject.value[1].datas.value.count, 0)
    }
}
