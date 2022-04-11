import UIKit

internal final class WeekDayCell: UICollectionViewCell {

    static let reuseIdentifier = "WeekDayCell"

    private let weekDayLabel: UILabel
    private let dayLabel: UILabel

    private var allViews: [UIView] {
        [weekDayLabel, dayLabel]
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(dataProvider: WeekDayCellViewModel) {
        self.weekDayLabel.text = dataProvider.week
        self.dayLabel.text = dataProvider.day
        if dataProvider.canBooked {
            self.weekDayLabel.textColor = .black
            self.dayLabel.textColor = .black
        } else {
            self.weekDayLabel.textColor = .systemGray
            self.dayLabel.textColor = .systemGray
        }
    }

    override init(frame: CGRect) {
        weekDayLabel = .init()
        dayLabel = .init()
        super.init(frame: frame)
        setUI()
    }

    private func setUI() {
        backgroundColor = .white

        weekDayLabel.textAlignment = .center
        dayLabel.textAlignment = .center

        weekDayLabel.font = .preferredFont(forTextStyle: .body)

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

        NSLayoutConstraint.activate([
            weekDayLabel.topAnchor.constraint(equalTo: topAnchor),
            weekDayLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            weekDayLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            weekDayLabel.bottomAnchor.constraint(equalTo: centerYAnchor),

            dayLabel.topAnchor.constraint(equalTo: weekDayLabel.bottomAnchor),
            dayLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            dayLabel.leadingAnchor.constraint(equalTo: weekDayLabel.leadingAnchor),
            dayLabel.trailingAnchor.constraint(equalTo: weekDayLabel.trailingAnchor)
        ])
    }
}

