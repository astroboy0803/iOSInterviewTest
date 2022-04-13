import UIKit
import Combine
import SafariServices

class MainViewController: UIViewController {
    
    private let mainView: MainView

    private let viewModel: MainViewModel

    private var cancellables: Set<AnyCancellable>

    private let imgLoader: ImageLoader
    
    private let servicesProvider: ServicesProvider

    init(servicesProvider: ServicesProvider) {
        mainView = .init(items: Top.allCases)
        self.servicesProvider = servicesProvider
        viewModel = .init(top: Top.allCases[mainView.selected.value], serviceProvider: servicesProvider)
        cancellables = []
        imgLoader = .init()
        super.init(nibName: nil, bundle: nil)
        setBinding()

        mainView.collectionView.register(TopItemCell.self, forCellWithReuseIdentifier: TopItemCell.reuseIdentifier)
        mainView.collectionView.dataSource = self
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
            .sink { _ in
                self.mainView.collectionView.reloadData()
            }
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

extension MainViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.dataSubject.value.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TopItemCell.reuseIdentifier, for: indexPath)
        if let topItemCell = cell as? TopItemCell {
            let item = viewModel.dataSubject.value[indexPath.item]
            topItemCell.setup(to: item)
        }
        return cell
    }
}

extension MainViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = viewModel.dataSubject.value[indexPath.item]
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
