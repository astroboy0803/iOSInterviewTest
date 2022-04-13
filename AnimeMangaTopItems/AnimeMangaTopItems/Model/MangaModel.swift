import Foundation

struct MangaModel: Codable {
    struct MangaData: Codable {
        struct Published: Codable {
            let from: Date
            let to: Date?
        }

        let mal_id: Int
        let images: Images
        let title: String
        let rank: Int
        let url: String
        let published: Published
    }
    let data: [MangaData]
    let pagination: Pagination
}
