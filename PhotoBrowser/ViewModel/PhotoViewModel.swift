//
//  PhotoViewModel.swift
//  PhotoBrowser
//
//  Created by Anton Shcherba on 11/24/20.
//

import Foundation

import Foundation
import Combine

class PhotoViewModel: ObservableObject {
    enum Const {
    }
    
    @Published var image: Data?
    @Published var error: APIError?
    
    private var publishers = [AnyCancellable]()
    private var provider: DataProvider = DataAPI(configurator: Configurator())
    private let photo: Photo?

    init(photo: Photo? = nil) {
        self.photo = photo
    }
    
    func loadPhoto()  {
        guard let photo = photo else { return }
        
        provider.loadPhoto(photo) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case let .success(data):
                self.store(data: data)
            case let .failure(error):
                self.error = error
            }
        }
    }
    
    private func store(data: Data) {
        self.image = data
    }
}
