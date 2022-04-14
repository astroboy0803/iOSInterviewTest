import UIKit
import Combine

internal final class MainView: UIView {

    let segControl: UISegmentedControl

    let collectionView: UICollectionView

    private var allViews: [UIView] {
        [segControl, collectionView]
    }
    
    let selected: CurrentValueSubject<Int, Never>

    init(items: [Top], layout: UICollectionViewLayout = UICollectionViewFlowLayout()) {
        selected = .init(.zero)
        segControl = .init(items: items.map { $0.title })
        collectionView = .init(frame: .zero, collectionViewLayout: layout)
        super.init(frame: .zero)

        segControl.selectedSegmentIndex = selected.value
        setupViews()
        setupEvent()
    }
    
    private func setupEvent() {
        segControl.addTarget(self, action: #selector(toggle(sender:)), for: .valueChanged)
    }
    
    @objc
    private func toggle(sender: UISegmentedControl) {
        selected.value = sender.selectedSegmentIndex
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        backgroundColor = .white
        collectionView.backgroundColor = .white

        segControl.setTitleTextAttributes([
            NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .headline)
        ], for: .selected)
        segControl.setTitleTextAttributes([
            NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .subheadline)
        ], for: .normal)

        addSubviews()
        setupConstraints()
    }

    private func addSubviews() {
        allViews.forEach {
            addSubview($0)
        }
    }

    private func setupConstraints() {
        allViews.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        NSLayoutConstraint.activate([
            segControl.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 10),
            segControl.centerXAnchor.constraint(equalTo: centerXAnchor),
            segControl.widthAnchor.constraint(equalTo: widthAnchor, constant: -20),
            collectionView.topAnchor.constraint(equalTo: segControl.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])
    }
}
