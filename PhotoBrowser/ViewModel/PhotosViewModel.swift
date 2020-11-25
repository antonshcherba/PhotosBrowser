//
//  PhotosViewModel.swift
//  PhotoBrowser
//
//  Created by Anton Shcherba on 11/24/20.
//

import Foundation
import Combine

class PhotosListViewModel: ObservableObject {
    enum Const {
        static let itemsPerPage = 15
        static let firstPageIndex = 0
    }
    
    @Published var photos: [Photo] = []
    @Published var error: APIError?
    
    private var publishers = [AnyCancellable]()
    private var provider: PhotosProvider = PhotosAPI(configurator: Configurator())
    private var page: Int = Const.firstPageIndex
    private var pageNumber: Int = Const.itemsPerPage
    
    func loadPhotos()  {        
        provider.photosList(page: page,
                           pageNumber: pageNumber)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.error = error
                }
            }) { [weak self] page in
                self?.store(page: page)
            }.store(in: &publishers)
    }
    
    func loadNextPage() {
        page += 1
        loadPhotos()
    }
    
    private func store(page: PhotosResponse) {
        self.photos += page.photos?.photo?.compactMap { $0 } ?? []
    }
}
