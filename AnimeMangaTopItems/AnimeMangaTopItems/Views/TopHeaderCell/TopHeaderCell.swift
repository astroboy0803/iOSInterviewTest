import UIKit

class TopHeaderCell: UICollectionReusableView {
    static var reuseIdentifier: String {
        String(describing: TopHeaderCell.self)
    }

    private var titleLabel: UILabel

    private var allViews: [UIView] {
        [titleLabel]
    }

    override init(frame: CGRect) {
        titleLabel = .init()
        super.init(frame: frame)
        setupUI()
    }

    private func setupUI() {
        addSubviews()
        setupConstraints()

        self.backgroundColor = .white

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .title1).pointSize, weight: .bold)
        titleLabel.textAlignment = .left
        titleLabel.numberOfLines = 1
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
            self.titleLabel.topAnchor.constraint(equalTo: topAnchor),
            self.titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            self.titleLabel.leadingAnchor.constraint(equalTo: readableContentGuide.leadingAnchor),
            self.titleLabel.trailingAnchor.constraint(equalTo: readableContentGuide.trailingAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup(title: String) {
        self.titleLabel.text = title
    }
}
