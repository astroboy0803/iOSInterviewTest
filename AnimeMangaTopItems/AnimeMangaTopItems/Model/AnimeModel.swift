import Foundation

struct AnimeModel: Codable {
    struct AnimeData: Codable {
        struct Aired: Codable {
            let from: Date
            let to: Date?
        }

        let mal_id: Int
        let images: Images
        let title: String
        let rank: Int
        let url: String
        let aired: Aired
    }
    let data: [AnimeData]
    let pagination: Pagination
}
