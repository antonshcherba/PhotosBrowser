//
//  DataProvider.swift
//  PhotoBrowser
//
//  Created by Anton Shcherba on 11/25/20.
//

import Foundation
import Combine

protocol DataProvider {
    func loadPhoto(_ photo: Photo, completion: @escaping (Result<Data, APIError>) -> Void)
}

class DataAPI: DataProvider, ObservableObject {
    private let configurator: Configurator
    private var baseURL: String { configurator.dataURL }
    
    private enum Endpoint {
        case loadPhoto(photo: Photo)
        
        var queryPath: URLComponents {
            switch self {
            case let .loadPhoto(photo: photo):
                return URLComponents(path: "/\(photo.server ?? "")/\(photo.id ?? "")_\(photo.secret ?? "").jpg", queryItems: [])
            }
        }
    }
    
    init(configurator: Configurator) {
        self.configurator = configurator
    }
    
    func loadPhoto(_ photo: Photo, completion: @escaping (Result<Data, APIError>) -> Void) {
        let url = request(for: .loadPhoto(photo: photo))
        download(with: url, completion: completion)
    }
    
    private func request(for endpoint: Endpoint) -> URLRequest {
        guard let url = URLComponents(baseURL: baseURL, components: endpoint.queryPath)?.url else {
            preconditionFailure("Bad url")
        }

        return URLRequest(url: url)
    }
    
    public func download(with request: URLRequest,
                          completion: @escaping((Result<Data, APIError>) -> Void)) {
        let task = URLSession.shared.downloadTask(with: request) { (url, response, error) in
            guard error == nil else {
                completion(.failure(.serverError))
                return
            }
            
            do {
                guard let url = url else {
                    completion(.failure(.serverError))
                    return
                }
                
                let data = try Data(contentsOf: url)
                completion(.success(data))
            } catch {
                completion(.failure(.internalError))
            }
        }
        
        task.resume()
    }
}
