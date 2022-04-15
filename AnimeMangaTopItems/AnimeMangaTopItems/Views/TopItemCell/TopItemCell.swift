import UIKit
import Combine

internal final class TopItemCell: UICollectionViewCell {
    struct FavorInfo {
        let dataID: String
        var isFavor: Bool
    }

    static var reuseIdentifier: String {
        String(describing: TopItemCell.self)
    }

    @IBOutlet private var imgView: UIImageView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var rankLabel: UILabel!
    @IBOutlet private var startLabel: UILabel!
    @IBOutlet private var toLabel: UILabel!
    @IBOutlet private var endLabel: UILabel!
    @IBOutlet private var favorButton: UIButton!

    private var imgCancellable: AnyCancellable?

    private var favorCancellable: AnyCancellable?

    let isFavor: CurrentValueSubject<FavorInfo, Never>

    let cellID: String

    override init(frame: CGRect) {
        cellID = UUID().uuidString
        isFavor = .init(FavorInfo(dataID: "", isFavor: false))
        super.init(frame: frame)
        setupEvent()
    }
    
    @IBAction private func toggle(sender: UIButton) {
        isFavor.value.isFavor.toggle()
    }

    private func setupEvent() {
        favorCancellable = isFavor
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { value in
                let imgName = value.isFavor ? "heart.fill" : "heart"
                self.favorButton.setImage(.init(systemName: imgName), for: .normal)
            })
    }
    
    required init?(coder: NSCoder) {
        cellID = UUID().uuidString
        isFavor = .init(FavorInfo(dataID: "", isFavor: false))
        super.init(coder: coder)
        setupEvent()
    }

    func setup(to viewModel: TopItemCellable) {
        cancelLoading()
        titleLabel.text = viewModel.title
        rankLabel.text = "Rank: \(viewModel.rank)"
        startLabel.text = viewModel.start
        endLabel.text = viewModel.end
        toLabel.isHidden = viewModel.end == nil
        imgCancellable = viewModel.loader
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [unowned self] image in
                self.showImage(image: image)
            })
        isFavor.value = .init(dataID: viewModel.id, isFavor: viewModel.isFavor)
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
        imgCancellable?.cancel()
    }
}
