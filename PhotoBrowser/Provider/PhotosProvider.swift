//
//  PhotosProvider.swift
//  PhotoBrowser
//
//  Created by Anton Shcherba on 11/24/20.
//

import Foundation
import Combine

protocol PhotosProvider {
    func photosList(page: Int?,
                   pageNumber: Int) -> AnyPublisher<PhotosResponse, APIError>
}

class PhotosAPI: PhotosProvider, ObservableObject {
    private let configurator: Configurator
    private var baseURL: String { configurator.baseURL }
    private var dataURL: String { configurator.dataURL }
    
    private enum Endpoint {
        case getPhotos(page: Int, pageNumber: Int, configurator: Configurator)
        
        var queryPath: URLComponents {
            switch self {
            case let .getPhotos(page: page, pageNumber: pageNumber, configurator: configurator):
                let items = [URLQueryItem(name: "method", value: "flickr.photos.getRecent"),
                             URLQueryItem(name: "oauth_consumer_key", value: configurator.token),
                             URLQueryItem(name: "format", value: "json"),
                             URLQueryItem(name: "nojsoncallback", value: "1"),
                             URLQueryItem(name: "page", value: "\(page)"),
                             URLQueryItem(name: "per_page", value: "\(pageNumber)")]
                return URLComponents(path: "/services/rest",
                                   queryItems: items)
            }
        }
    }
    
    private enum Method: String {
        case GET
    }
    
    init(configurator: Configurator) {
        self.configurator = configurator
    }
    
    func photosList(page: Int?, pageNumber: Int = 50) -> AnyPublisher<PhotosResponse, APIError> {
        request(endpoint: .getPhotos(page: page ?? 0,
                                     pageNumber: pageNumber,
                                     configurator: configurator),
                method: .GET)
    }
    
    private func request(for endpoint: Endpoint, method: Method) -> URLRequest {
        guard let url = URLComponents(baseURL: baseURL, components: endpoint.queryPath)?.url else {
            preconditionFailure("Bad url")
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        return request
    }
    
    private func request<T: Codable>(endpoint: Endpoint, method: Method) -> AnyPublisher<T,APIError> {
        let urlRequest = request(for: endpoint, method: method)
        
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .mapError { error -> APIError in
                return APIError.serverError
            }
            .map {
                return $0.data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error in
                return APIError.parsingError
            }
            .eraseToAnyPublisher()
    }
}
