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

    private let commonLayout: UICollectionViewCompositionalLayout

    private let favorLayout: UICollectionViewCompositionalLayout

    init(servicesProvider: ServicesProvider) {
        commonLayout = Self.commonCompositionLayout
        favorLayout = Self.headerWithCompositionLayout
        mainView = .init(items: Top.allCases, layout: commonLayout)
        self.servicesProvider = servicesProvider
        viewModel = .init(top: Top.allCases[mainView.selected.value], serviceProvider: servicesProvider)
        cancellables = []
        imgLoader = .init()
        cellCancellables = [:]
        super.init(nibName: nil, bundle: nil)
        setBinding()
        setupCollection()
    }

    private func setupCollection() {
        mainView.collectionView.register(TopHeaderCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TopHeaderCell.reuseIdentifier)
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
                self.updateLayout(top: top)
                self.viewModel.change(top: top)
            }
            .store(in: &cancellables)

        viewModel.isLoading
            .receive(on: DispatchQueue.main)
            .sink { value in
                if value {
                    self.mainView.startAnimate()
                } else {
                    self.mainView.stopAnimate()
                }
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

    private func updateLayout(top: Top) {
        if top == .favorite {
            mainView.collectionView.collectionViewLayout = favorLayout
            return
        }
        if mainView.collectionView.collectionViewLayout !== commonLayout {
            mainView.collectionView.collectionViewLayout = commonLayout
        }
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
    private func makeDataSource() -> UICollectionViewDiffableDataSource<TopSectionViewModel, TopItemViewModel> {
        let dataSource = UICollectionViewDiffableDataSource<TopSectionViewModel, TopItemViewModel>(collectionView: mainView.collectionView) { collectionView, indexPath, item -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TopItemCell.reuseIdentifier, for: indexPath)
            if let topItemCell = cell as? TopItemCell {
                topItemCell.setup(to: item)
                self.cellCancellables[topItemCell.cellID]?.cancel()
                self.cellCancellables.removeValue(forKey: topItemCell.cellID)
                self.cellCancellables[topItemCell.cellID] = topItemCell.isFavor
                    .sink(receiveValue: { info in
                        guard
                            info.dataID == item.id,
                            info.isFavor != item.isFavor
                        else {
                            return
                        }
                        self.viewModel.favor(indexPath: indexPath, isFavor: info.isFavor)
                    })
            }
            return cell
        }

        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionHeader else {
                return nil
            }
            let section = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]

            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TopHeaderCell.reuseIdentifier, for: indexPath) as? TopHeaderCell
            header?.setup(title: section.sid)

            return header
        }

        return dataSource
    }

    private func applySnapshot(_ sections: [TopSectionViewModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<TopSectionViewModel, TopItemViewModel>()
        // 只有一個section, 就直接放整數
        snapshot.appendSections(sections)
        sections.forEach { (section) in
            snapshot.appendItems(section.datas.value, toSection: section)
        }
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

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y + scrollView.frame.height >= scrollView.contentSize.height {
            self.viewModel.fetch()
        }
    }
}

// MARK: - Compositional Layout
extension MainViewController {
    static var commonCompositionLayout: UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout(section: sectionLayout)
    }

    static var headerWithCompositionLayout: UICollectionViewCompositionalLayout {
        let section = sectionLayout

        // Supplementary header view setup
        let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(20))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerFooterSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        section.boundarySupplementaryItems = [sectionHeader]

        return UICollectionViewCompositionalLayout(section: section)
    }

    static var sectionLayout: NSCollectionLayoutSection {
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

        return NSCollectionLayoutSection(group: group)
    }
}
