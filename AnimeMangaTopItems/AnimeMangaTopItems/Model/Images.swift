import Foundation

struct Images: Codable {
    struct JPG: Codable {
        let image_url: URL
        let large_image_url: URL
        let small_image_url: URL
    }
    let jpg: JPG
}
