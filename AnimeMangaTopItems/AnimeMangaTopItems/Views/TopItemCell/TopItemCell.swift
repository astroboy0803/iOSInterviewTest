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
        
        backgroundColor = .white

        imgView.contentMode = .scaleAspectFit
        
        titleLabel.numberOfLines = 0
        titleLabel.font = .preferredFont(forTextStyle: .title2)
        
        rankLabel.font = .preferredFont(forTextStyle: .headline)
        
        airedLabel.text = "aired"
        airedLabel.font = .preferredFont(forTextStyle: .callout)
        
        toLabel.text = "to"
        [startLabel, toLabel, endLabel].forEach {
            $0.font = .preferredFont(forTextStyle: .body)
        }
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

            rankLabel.topAnchor.constraint(equalTo: imgView.topAnchor),
            rankLabel.leadingAnchor.constraint(equalTo: imgView.trailingAnchor, constant: 5),
            rankLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            rankLabel.heightAnchor.constraint(lessThanOrEqualTo: imgView.heightAnchor, multiplier: 0.2),
            
            titleLabel.topAnchor.constraint(equalTo: rankLabel.bottomAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: rankLabel.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: rankLabel.trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: airedLabel.topAnchor),
            
            airedLabel.leadingAnchor.constraint(equalTo: rankLabel.leadingAnchor),
            airedLabel.trailingAnchor.constraint(equalTo: rankLabel.trailingAnchor),
            airedLabel.heightAnchor.constraint(lessThanOrEqualTo: imgView.heightAnchor, multiplier: 0.2),

            startLabel.topAnchor.constraint(equalTo: airedLabel.bottomAnchor),
            startLabel.leadingAnchor.constraint(equalTo: rankLabel.leadingAnchor),
            startLabel.bottomAnchor.constraint(equalTo: imgView.bottomAnchor),
            startLabel.widthAnchor.constraint(lessThanOrEqualTo: titleLabel.widthAnchor, multiplier: 0.4),
            startLabel.heightAnchor.constraint(lessThanOrEqualTo: imgView.heightAnchor, multiplier: 0.2),
            
            toLabel.topAnchor.constraint(equalTo: startLabel.topAnchor),
            toLabel.leadingAnchor.constraint(equalTo: startLabel.trailingAnchor),
            toLabel.bottomAnchor.constraint(equalTo: startLabel.bottomAnchor),
            toLabel.widthAnchor.constraint(lessThanOrEqualTo: titleLabel.widthAnchor, multiplier: 0.2),

            endLabel.topAnchor.constraint(equalTo: startLabel.topAnchor),
            endLabel.leadingAnchor.constraint(equalTo: toLabel.trailingAnchor),
            endLabel.bottomAnchor.constraint(equalTo: startLabel.bottomAnchor),
            endLabel.trailingAnchor.constraint(lessThanOrEqualTo: rankLabel.trailingAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup(to viewModel: TopItemCellable) {
        cancelLoading()
        titleLabel.text = viewModel.title
        rankLabel.text = "Rank: \(viewModel.rank)"
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
