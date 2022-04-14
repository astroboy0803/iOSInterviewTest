import UIKit
import Combine
import SafariServices

class MainViewController: UIViewController {
    
    private let mainView: MainView

    private let viewModel: MainViewModel

    private var cancellables: Set<AnyCancellable>
    
    private var cellCancellables: [String: AnyCancellable]

    private let imgLoader: ImageLoader
    
    private let servicesProvider: ServicesProvider
    
    private lazy var dataSource = makeDataSource()

    init(servicesProvider: ServicesProvider) {
        mainView = .init(items: Top.allCases, layout: Self.collectionViewLayout)
        self.servicesProvider = servicesProvider
        viewModel = .init(top: Top.allCases[mainView.selected.value], serviceProvider: servicesProvider)
        cancellables = []
        imgLoader = .init()
        cellCancellables = [:]
        super.init(nibName: nil, bundle: nil)
        setBinding()

        mainView.collectionView.register(TopItemCell.self, forCellWithReuseIdentifier: TopItemCell.reuseIdentifier)
        mainView.collectionView.dataSource = dataSource
        mainView.collectionView.delegate = self
    }

    private func setBinding() {
        mainView.selected
            .sink { value in
                guard let top = Top(rawValue: value) else {
                    return
                }
                self.viewModel.change(top: top)
            }
            .store(in: &cancellables)
        
        viewModel.dataSubject
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: self.applySnapshot(_:))
            .store(in: &cancellables)
        
        viewModel.message
            .receive(on: DispatchQueue.main)
            .sink { message in
                let alert = UIAlertController(title: message, message: "", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "確定", style: .default, handler: nil)
                alert.addAction(okAction)
                self.present(alert, animated: true)
            }
            .store(in: &cancellables)
        
        viewModel.linkURL
            .receive(on: DispatchQueue.main)
            .sink { url in
                let safariVC = SFSafariViewController(url: url)
                safariVC.modalPresentationStyle = .popover
                self.present(safariVC, animated: true)
            }
            .store(in: &cancellables)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}

// MARK: - Diff Data Source
extension MainViewController {
    private func makeDataSource() -> UICollectionViewDiffableDataSource<Int, TopItemViewModel> {
        let dataSource = UICollectionViewDiffableDataSource<Int, TopItemViewModel>(collectionView: mainView.collectionView) { collectionView, indexPath, item -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TopItemCell.reuseIdentifier, for: indexPath)
            if let topItemCell = cell as? TopItemCell {
                let item = self.viewModel.item(indexPath: indexPath)
                topItemCell.setup(to: item)
                self.cellCancellables[topItemCell.cellID]?.cancel()
                self.cellCancellables.removeValue(forKey: topItemCell.cellID)
                self.cellCancellables[topItemCell.cellID] = topItemCell.isFavor
                    .sink(receiveValue: { info in
                        guard info.dataID == item.id else {
                            return
                        }
                        self.viewModel.favor(id: info.dataID, isFavor: info.isFavor)
                    })
            }
            return cell
        }
        
        return dataSource
    }
    
    private func applySnapshot(_ model: [TopItemViewModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, TopItemViewModel>()
        // 只有一個section, 就直接放整數
        let section: Int = .zero
        snapshot.appendSections([section])
        snapshot.appendItems(model, toSection: section)
        self.dataSource.apply(snapshot)
    }
}

extension MainViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = viewModel.item(indexPath: indexPath)
        switch item.url {
        case let .success(url):
            viewModel.linkTo(url: url)
        case let .failure(error):
            switch error {
            case let .invalid(msg):
                viewModel.alert(msg: msg)
            }
        }
    }
}

// MARK: - Compositional Layout
extension MainViewController {
    static var collectionViewLayout: UICollectionViewCompositionalLayout {
        // grid
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(0.5))
        
        // 水平
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        // contentInsets就像css的padding -> 內縮 留白
        // contentOffsets就像css的margin -> 設定邊界
        group.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 8, bottom: 2, trailing: 8)

        // section間格
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 2, bottom: 0, trailing: 2)

        return UICollectionViewCompositionalLayout(section: section)
    }
}
