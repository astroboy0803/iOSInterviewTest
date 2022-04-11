import UIKit

internal final class OrderTimeCell: UICollectionViewCell {
    static let reuseIdentifier = "OrderTimeCell"

    private let timeLabel: UILabel

    private var allViews: [UIView] {
        [timeLabel]
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        timeLabel = .init()
        super.init(frame: frame)
        setUI()
    }
    
    func setup(dataProvider: OrderTimeCellViewModel) {
        timeLabel.text = dataProvider.time
        if dataProvider.isBooked {
            timeLabel.layer.borderColor = UIColor.systemGray.cgColor
            timeLabel.layer.borderWidth = 1
            timeLabel.textColor = .systemGray
            timeLabel.layer.backgroundColor = UIColor.clear.cgColor
        } else {
            timeLabel.layer.borderColor = UIColor.clear.cgColor
            timeLabel.layer.borderWidth = 0
            timeLabel.textColor = .init(displayP3Red: 12.0/255, green: 201.0/255, blue: 184.0/255, alpha: 1)
            timeLabel.layer.backgroundColor = UIColor(displayP3Red: 228.0/255, green: 249.0/255, blue: 247.0/255, alpha: 1).cgColor
        }
    }

    private func setUI() {
        backgroundColor = .white

        timeLabel.font = .preferredFont(forTextStyle: .body)
        timeLabel.layer.cornerRadius = 10
        timeLabel.textAlignment = .center

        addViews()
        setLayout()
    }

    private func addViews() {
        allViews.forEach {
            addSubview($0)
        }
    }

    private func setLayout() {
        allViews.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        let constraint = [
            timeLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            timeLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            timeLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            timeLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5)
        ]
        
        constraint.forEach {
            $0.priority = .init(750)
        }
        
        NSLayoutConstraint.activate(constraint)
    }
}
