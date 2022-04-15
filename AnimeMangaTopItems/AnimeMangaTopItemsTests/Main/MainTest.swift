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
        cancellables.removeAll()
    }
        
    // MARK: 切換頁籤
    func testChangeTab() throws {
        // given
        var dataCounts: [Int] = []
        viewModel.dataSubject
            .sink(receiveValue: { values in
                dataCounts.append(values.count)
            })
            .store(in: &cancellables)
        var isLoadings: [Bool] = []
        viewModel.isLoading
            .sink { value in
                isLoadings.append(value)
            }
            .store(in: &cancellables)
        
        // when
        viewModel.change(top: .manga)
        
        // then
        XCTAssertEqual(dataCounts, [0, 2])
        XCTAssertEqual(isLoadings, [false, true, false])
        
        // when
        dataCounts.removeAll()
        viewModel.change(top: .anime)
        
        // then
        XCTAssertEqual(dataCounts, [2])
        XCTAssertEqual(isLoadings, [false, true, false])
    }
    
    // MARK: 開起連結
    func testOpenLink() throws {
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
    func testAlertMessage() throws {
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
    
    // MARK: 加入與移除我的最愛
    func testFavor() throws {
        // given
        var isFavor = true
        let item = viewModel.item(indexPath: .init(item: 0, section: 0))
        
        // when
        viewModel.favor(id: item.id, isFavor: isFavor)
        
        // then
        XCTAssertEqual(item.isFavor, isFavor)
        XCTAssertTrue(UserDefaults.standard.anime.contains(item.id))
        
        // given
        isFavor.toggle()
        
        // when
        viewModel.favor(id: item.id, isFavor: isFavor)
        
        // then
        XCTAssertEqual(item.isFavor, isFavor)
        XCTAssertFalse(UserDefaults.standard.anime.contains(item.id))
    }
    
    // MARK: 取得更多資料
    func testFetchMore() throws {
        // given
        var datas: [TopItemViewModel] = []
        viewModel.dataSubject
            .sink(receiveValue: { values in
                datas = values
            })
            .store(in: &cancellables)
        var isLoadings: [Bool] = []
        viewModel.isLoading
            .sink { value in
                isLoadings.append(value)
            }
            .store(in: &cancellables)
        
        // when
        viewModel.fetch()
        
        // then
        XCTAssertEqual(datas.count, 4)
        XCTAssertEqual(isLoadings, [false, true, false])
        
        // given
        isLoadings.removeAll()
        
        // when
        viewModel.fetch()
        
        // then
        XCTAssertEqual(datas.count, 6)
        XCTAssertEqual(isLoadings, [true, false])
        
        // given
        isLoadings.removeAll()
        
        // when
        viewModel.fetch()
        
        // then
        XCTAssertEqual(datas.count, 6)
        XCTAssertTrue(isLoadings.isEmpty)
    }
}
