import UIKit

internal final class MainView: UIView {

    let segControl: UISegmentedControl

    let collectionView: UICollectionView

    private var allViews: [UIView] {
        [segControl, collectionView]
    }

    init(items: [String]) {
        segControl = .init(items: items)
        segControl.selectedSegmentIndex = .zero

        // TODO
        collectionView = .init(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        super.init(frame: .zero)

        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        backgroundColor = .white

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
            collectionView.leadingAnchor.constraint(equalTo: segControl.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: segControl.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])
    }
}
