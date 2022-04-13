import UIKit
import Combine

class MainViewController: UIViewController {

    private let mainView: MainView

    private let viewModel: MainViewModel

    private var cancellables: Set<AnyCancellable>

    private let imgLoader: ImageLoader

    init() {
        mainView = .init(items: ["Anime", "Manga"])
        viewModel = .init()
        cancellables = []
        imgLoader = .init()
        super.init(nibName: nil, bundle: nil)
        setBinding()

        mainView.collectionView.register(TopItemCell.self, forCellWithReuseIdentifier: TopItemCell.reuseIdentifier)
        mainView.collectionView.dataSource = self
        mainView.collectionView.delegate = self
    }

    private func setBinding() {
        viewModel.datas
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.mainView.collectionView.reloadData()
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

        // TODO
        viewModel.loadTest()
    }
}

extension MainViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.datas.value.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TopItemCell.reuseIdentifier, for: indexPath)
        if let topItemCell = cell as? TopItemCell {
            let data = viewModel.datas.value[indexPath.item]
            topItemCell.setup(to: .init(title: data.title, rank: data.rank, start: data.aired.from.description, end: data.aired.to?.description, loader: imgLoader.loadImage(from: data.images.jpg.image_url)))
        }
        return cell
    }
}

extension MainViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        .init(top: 5, left: 0, bottom: 0, right: 0)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        .init(width: collectionView.frame.width - 10, height: 150)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        5
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        5
    }
}
