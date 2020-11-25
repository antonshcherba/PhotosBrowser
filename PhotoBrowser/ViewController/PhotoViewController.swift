//
//  PhotoViewController.swift
//  PhotoBrowser
//
//  Created by Anton Shcherba on 11/24/20.
//

import UIKit
import SwiftUI
import Combine

class PhotoViewController: UIViewController {
    
    var photoIndex = 0
    @ObservedObject var viewModel: PhotoViewModel = PhotoViewModel()
    
    @IBOutlet private var photoView: UIImageView!
    @IBOutlet private var loadingView: UIActivityIndicatorView!
    private var publishers = [AnyCancellable]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupData()
    }
    
    func setupData() {
        loadingView.isHidden = false
        loadingView.startAnimating()
        viewModel.$image
            .receive(on: RunLoop.main)
            .sink { [weak self] data in
                guard let data = data else { return }
                self?.photoView.image = UIImage(data: data)
                self?.loadingView.isHidden = true
                self?.loadingView.stopAnimating()
            }.store(in: &publishers)
        
        viewModel.$error
            .receive(on: RunLoop.main)
            .sink { [weak self] error in
                guard let error = error else { return }
                self?.showError(error)
                self?.loadingView.isHidden = true
                self?.loadingView.stopAnimating()
            }.store(in: &publishers)
        
        viewModel.loadPhoto()
    }
    
    private func showError(_ error: APIError) {
        let alertController = UIAlertController(title: error.title,
                                                message: error.message,
                                                preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
