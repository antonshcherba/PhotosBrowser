//
//  URLComponents.swift
//  PhotoBrowser
//
//  Created by Anton Shcherba on 11/24/20.
//

import Foundation

extension URLComponents {
    init?(baseURL: String,
         components: URLComponents) {
        self.init(string: baseURL)
        self.path = components.path
        self.queryItems = components.queryItems
    }
    
    init(path: String,
         queryItems: [URLQueryItem]) {
        self.init()
        self.path = path
        if !queryItems.isEmpty {
            self.queryItems = queryItems
        }
    }
}
