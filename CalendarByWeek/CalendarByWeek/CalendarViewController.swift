import UIKit
import Combine

internal final class CalendarViewController: UIViewController {

    private let titleLabel: UILabel

    private let prevButton: UIButton

    private let nextButton: UIButton

    private let dateLabel: UILabel

    private let localeLabel: UILabel

    private let collectionView: UICollectionView

    private let activityView: UIActivityIndicatorView

    private var allViews: [UIView] {
        [titleLabel, prevButton, nextButton, dateLabel, localeLabel, collectionView, activityView]
    }

    private var allButtons: [UIButton] {
        [prevButton, nextButton]
    }
    
    private let viewModel: CalendarViewModel
    
    private var cancellables: Set<AnyCancellable>
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let servicesProvider: ServicesProvider
    
    init(servicesProvider: ServicesProvider) {
        titleLabel = .init()
        prevButton = .init()
        nextButton = .init()
        dateLabel = .init()
        localeLabel = .init()
        activityView = .init()

        collectionView = .init(frame: .zero, collectionViewLayout: CalandarWeeklyLayout())

        self.servicesProvider = servicesProvider
        
        viewModel = .init(servicesProvider: servicesProvider)
        cancellables = []
        
        super.init(nibName: nil, bundle: nil)

        collectionView.dataSource = self

        setUI()
        setEvents()
    }
    
    private func setUI() {
        view.backgroundColor = .white
        collectionView.backgroundColor = .white

        activityView.transform = .init(scaleX: 1.5, y: 1.5)

        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.text = "授課時間"

        prevButton.setTitle("<", for: .normal)
        nextButton.setTitle(">", for: .normal)

        allButtons.forEach {
            $0.setTitleColor(.init(displayP3Red: 2.0/255, green: 202.0/255, blue: 185.0/255, alpha: 1), for: .normal)
            $0.setTitleColor(.init(displayP3Red: 6.0/255, green: 107.0/255, blue: 98.0/255, alpha: 1), for: .highlighted)
            $0.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        }

        dateLabel.font = .preferredFont(forTextStyle: .callout)
        localeLabel.font = .preferredFont(forTextStyle: .footnote)
        localeLabel.textColor = .systemGray

        addViews()
        setLayout()
        registers()
        
        setBinding()
    }

    private func addViews() {
        allViews.forEach {
            view.addSubview($0)
        }
    }

    private func setLayout() {
        allViews.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            activityView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            activityView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            activityView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            activityView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),

            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),

            prevButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            prevButton.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            prevButton.trailingAnchor.constraint(equalTo: titleLabel.centerXAnchor),
            prevButton.bottomAnchor.constraint(equalTo: localeLabel.bottomAnchor),

            nextButton.topAnchor.constraint(equalTo: prevButton.topAnchor),
            nextButton.bottomAnchor.constraint(equalTo: prevButton.bottomAnchor),
            nextButton.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor),
            nextButton.widthAnchor.constraint(equalTo: prevButton.widthAnchor),

            dateLabel.topAnchor.constraint(equalTo: prevButton.topAnchor),
            dateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dateLabel.bottomAnchor.constraint(equalTo: prevButton.centerYAnchor),
            dateLabel.leadingAnchor.constraint(greaterThanOrEqualTo: prevButton.trailingAnchor),
            dateLabel.trailingAnchor.constraint(lessThanOrEqualTo: nextButton.leadingAnchor),

            localeLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor),
            localeLabel.centerXAnchor.constraint(equalTo: dateLabel.centerXAnchor),
            localeLabel.leadingAnchor.constraint(greaterThanOrEqualTo: prevButton.trailingAnchor),
            localeLabel.trailingAnchor.constraint(lessThanOrEqualTo: nextButton.leadingAnchor),

            collectionView.topAnchor.constraint(equalTo: localeLabel.bottomAnchor, constant: 10),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            collectionView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10)
        ])
    }

    private func setEvents() {
        prevButton.addTarget(self, action: #selector(goPrev(sender:)), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(goNext(sender:)), for: .touchUpInside)
    }

    final private func registers() {
        collectionView.register(WeekDayCell.self, forCellWithReuseIdentifier: WeekDayCell.reuseIdentifier)
        collectionView.register(OrderTimeCell.self, forCellWithReuseIdentifier: OrderTimeCell.reuseIdentifier)
    }

    @objc
    private func goPrev(sender: UIButton) {
        viewModel.goBack()
    }
    
    @objc
    private func goNext(sender: UIButton) {
        viewModel.goNext()
    }
    
    private func setBinding() {
        viewModel.dateInterval
            .receive(on: DispatchQueue.main)
            .assign(to: \.text, on: dateLabel)
            .store(in: &cancellables)
        
        viewModel.prevEnable
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [button = prevButton, nextButton] isEnabled in
                button.isEnabled = isEnabled
                let color = isEnabled ? nextButton.titleColor(for: .normal) : .systemGray4
                button.setTitleColor(color, for: .normal)
            })
            .store(in: &cancellables)
        
        viewModel.isLoading
            .receive(on: DispatchQueue.main)
            .sink { [coverView = activityView] isLoading in
                if isLoading {
                    coverView.startAnimating()
                } else {
                    coverView.stopAnimating()
                }
            }
            .store(in: &cancellables)
        
        viewModel.message
            .receive(on: DispatchQueue.main)
            .sink { message in
                let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "確定", style: .default, handler: nil)
                alert.addAction(okAction)
                self.present(alert, animated: true)
            }
            .store(in: &cancellables)
        
        viewModel.dataSubject
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.collectionView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.timezoneInfo
            .receive(on: DispatchQueue.main)
            .map { "*時間以 \($0) 顯示" }
            .assign(to: \.text, on: localeLabel)
            .store(in: &cancellables)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}

extension CalendarViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel.dataSubject.value.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.dataSubject.value[section].count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let item = viewModel.dataSubject.value[indexPath.section][indexPath.item]
        switch item {
        case let .header(week, day, canBooked):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WeekDayCell.reuseIdentifier, for: indexPath)
            if let weekdayCell = cell as? WeekDayCell {
                weekdayCell.setup(dataProvider: .init(week: week, day: day, canBooked: canBooked))
            }
            return cell
        case let .value(time, isBooked):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OrderTimeCell.reuseIdentifier, for: indexPath)
            if let oTimeCell = cell as? OrderTimeCell {
                oTimeCell.setup(dataProvider: .init(time: time, isBooked: isBooked))
            }
            return cell
        }
    }
}
