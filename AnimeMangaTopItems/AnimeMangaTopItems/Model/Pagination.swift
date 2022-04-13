import Foundation

struct Pagination: Codable {
    struct Items: Codable {
        let count: Int
        let per_page: Int
        let total: Int
    }
    let current_page: Int
    let last_visible_page: Int
    let items: Items
}
