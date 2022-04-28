import Foundation
import Combine

class TopSectionViewModel {
    let sid: String
    var top: Top
    var datas: CurrentValueSubject<[TopItemViewModel], Never>

    init(sid: String, top: Top, datas: [TopItemViewModel]) {
        self.sid = sid
        self.datas = .init(datas)
        self.top = top
    }
}

extension TopSectionViewModel: TopHeaderCellable {
    var title: String {
        top.title
    }
}

extension TopSectionViewModel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(sid)
    }

    static func == (lhs: TopSectionViewModel, rhs: TopSectionViewModel) -> Bool {
        lhs.sid == rhs.sid
    }
}
