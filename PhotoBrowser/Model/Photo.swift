//
//  Photo.swift
//  PhotoBrowser
//
//  Created by Anton Shcherba on 11/24/20.
//

import Foundation

struct Photo: Codable {
    let id: String?
    let owner: String?
    let secret: String?
    let server: String?
    let farm: Int?
    let title: String?
    let ispublic: Int?
    let isfriend: Int?
    let isfamily: Int?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case owner = "owner"
        case secret = "secret"
        case server = "server"
        case farm = "farm"
        case title = "title"
        case ispublic = "ispublic"
        case isfriend = "isfriend"
        case isfamily = "isfamily"
    }
}
