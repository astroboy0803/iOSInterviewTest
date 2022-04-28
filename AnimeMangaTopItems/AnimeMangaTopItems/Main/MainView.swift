import UIKit
import Combine

internal final class MainView: UIView {

    let segControl: UISegmentedControl

    let collectionView: UICollectionView

    let activityView: UIActivityIndicatorView

    let containView: UIView

    private var allViews: [UIView] {
        [segControl, collectionView, containView, activityView]
    }

    let selected: CurrentValueSubject<Int, Never>

    init(items: [Top], layout: UICollectionViewLayout = UICollectionViewFlowLayout()) {
        selected = .init(.zero)
        segControl = .init(items: items.map { $0.title })
        collectionView = .init(frame: .zero, collectionViewLayout: layout)
        activityView = .init()
        containView = .init()
        super.init(frame: .zero)

        segControl.selectedSegmentIndex = selected.value
        setupViews()
        setupEvent()
    }

    func stopAnimate() {
        containView.isHidden = true
        activityView.stopAnimating()
    }

    func startAnimate() {
        containView.isHidden = false
        activityView.startAnimating()
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

        activityView.style = .large
        activityView.color = .white
        activityView.backgroundColor = .black.withAlphaComponent(0.7)
        activityView.layer.cornerRadius = 5

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
        [segControl, collectionView, containView].forEach {
            addSubview($0)
        }
        containView.addSubview(activityView)
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
            collectionView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -10),

            containView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            containView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            containView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            containView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),

            activityView.centerXAnchor.constraint(equalTo: containView.centerXAnchor),
            activityView.centerYAnchor.constraint(equalTo: containView.centerYAnchor),
            activityView.heightAnchor.constraint(equalToConstant: 80),
            activityView.widthAnchor.constraint(equalTo: activityView.heightAnchor)
        ])
    }
}
