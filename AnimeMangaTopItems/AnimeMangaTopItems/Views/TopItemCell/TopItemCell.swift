import UIKit
import Combine

internal final class TopItemCell: UICollectionViewCell {
    static let reuseIdentifier = "TopItemCell"

    private let imgView: UIImageView
    private let titleLabel: UILabel
    private let rankLabel: UILabel
    private let airedLabel: UILabel
    private let startLabel: UILabel
    private let toLabel: UILabel
    private let endLabel: UILabel

    private var cancellable: AnyCancellable?

    private var allViews: [UIView] {
        [imgView, titleLabel, rankLabel, airedLabel, startLabel, toLabel, endLabel]
    }

    override init(frame: CGRect) {
        imgView = .init()
        titleLabel = .init()
        rankLabel = .init()
        airedLabel = .init()
        startLabel = .init()
        toLabel = .init()
        endLabel = .init()
        super.init(frame: frame)

        setupUI()
    }

    private func setupUI() {
        addSubviews()
        setupConstraints()

        imgView.contentMode = .scaleAspectFit

        backgroundColor = .systemBlue
        airedLabel.text = "aired"
        toLabel.text = "to"
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
            imgView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imgView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imgView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1),
            imgView.widthAnchor.constraint(equalTo: imgView.heightAnchor, multiplier: 2/3),

            titleLabel.topAnchor.constraint(equalTo: imgView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: imgView.trailingAnchor, constant: 5),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            titleLabel.heightAnchor.constraint(equalTo: imgView.heightAnchor, multiplier: 0.25),

            rankLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            rankLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            rankLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            rankLabel.heightAnchor.constraint(equalTo: titleLabel.heightAnchor),

            airedLabel.topAnchor.constraint(equalTo: rankLabel.bottomAnchor),
            airedLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            airedLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            airedLabel.heightAnchor.constraint(equalTo: titleLabel.heightAnchor),

            startLabel.topAnchor.constraint(equalTo: airedLabel.bottomAnchor),
            startLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            startLabel.heightAnchor.constraint(equalTo: titleLabel.heightAnchor),
            startLabel.widthAnchor.constraint(equalTo: titleLabel.widthAnchor, multiplier: 0.45),

            toLabel.topAnchor.constraint(equalTo: startLabel.topAnchor),
            toLabel.leadingAnchor.constraint(equalTo: startLabel.trailingAnchor),
            toLabel.heightAnchor.constraint(equalTo: titleLabel.heightAnchor),
            toLabel.widthAnchor.constraint(equalTo: titleLabel.widthAnchor, multiplier: 0.1),

            endLabel.topAnchor.constraint(equalTo: startLabel.topAnchor),
            endLabel.leadingAnchor.constraint(equalTo: toLabel.trailingAnchor),
            endLabel.heightAnchor.constraint(equalTo: titleLabel.heightAnchor),
            endLabel.widthAnchor.constraint(equalTo: titleLabel.widthAnchor, multiplier: 0.45)

        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup(to viewModel: TopItemCellable) {
        cancelLoading()
        titleLabel.text = viewModel.title
        rankLabel.text = String(viewModel.rank)
        startLabel.text = viewModel.start
        endLabel.text = viewModel.end
        toLabel.isHidden = viewModel.end == nil
        cancellable = viewModel.loader
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [unowned self] image in
                self.showImage(image: image)
            })
    }

    private func showImage(image: UIImage?) {
        cancelLoading()
        UIView.transition(with: self.imgView,
        duration: 0.3,
        options: [.curveEaseOut, .transitionCrossDissolve],
        animations: {
            self.imgView.image = image
        })
    }

    private func cancelLoading() {
        imgView.image = nil
        cancellable?.cancel()
    }
}
