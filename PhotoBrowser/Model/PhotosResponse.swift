//
//  PhotosResponse.swift
//  PhotoBrowser
//
//  Created by Anton Shcherba on 11/24/20.
//

import Foundation

struct PhotosResponse: Codable {
    let photos: PhotosPage?
    let stat: String?

    enum CodingKeys: String, CodingKey {
        case photos = "photos"
        case stat = "stat"
    }
}
