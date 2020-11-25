//
//  APIError.swift
//  PhotoBrowser
//
//  Created by Anton Shcherba on 11/24/20.
//

import Foundation

enum APIError: Error {
    case internalError
    case serverError
    case parsingError
    
    var title: String {
        switch self {
        case .internalError:
            return "Internal error!"
        case .serverError:
            return "Server error :("
        case .parsingError:
            return "Incorrect data!"
        }
    }
    
    var message: String { "Something wrong happened" }
}
