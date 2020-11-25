//
//  Photos.swift
//  PhotoBrowser
//
//  Created by Anton Shcherba on 11/24/20.
//

import Foundation

struct PhotosPage: Codable {
    let page: Int?
    let pages: Int?
    let perpage: Int?
    let total: Int?
    let photo: [Photo]?

    enum CodingKeys: String, CodingKey {
        case page = "page"
        case pages = "pages"
        case perpage = "perpage"
        case total = "total"
        case photo = "photo"
    }
}
