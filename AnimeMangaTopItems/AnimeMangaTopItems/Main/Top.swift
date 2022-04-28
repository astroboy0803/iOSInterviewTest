import Foundation

enum Top: Int, CaseIterable {
    case anime
    case manga
    case favorite

    var title: String {
        switch self {
        case .anime:
            return "Anime"
        case .manga:
            return "Manga"
        case .favorite:
            return "Favor"
        }
    }
}
