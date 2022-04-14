import Foundation

enum Top: Int, CaseIterable {
    case anime
    case manga

    var title: String {
        switch self {
        case .anime:
            return "Anime"
        case .manga:
            return "Manga"
        }
    }
}
