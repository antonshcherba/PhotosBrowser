//
//  PhotosListViewController.swift
//  PhotoBrowser
//
//  Created by Anton Shcherba on 11/24/20.
//

import UIKit
import Combine
import SwiftUI

class PhotosListViewController: UIViewController {
    
    var currentIndex = 0
    @ObservedObject var viewModel: PhotosListViewModel = PhotosListViewModel()
    private var publishers = [AnyCancellable]()
    
    @IBOutlet weak var pageControllerHolderView: UIView!
    lazy var pageViewController: UIPageViewController = {
        return UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupData()
    }
    
    func setupData() {
        viewModel.$photos
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.setCurrentPage()
            }.store(in: &publishers)
        
        viewModel.$error
            .receive(on: RunLoop.main)
            .sink { [weak self] error in
                guard let error = error else { return }
                self?.showError(error)
            }.store(in: &publishers)
        
        viewModel.loadPhotos()
    }
    
    func setupView() {
        setupPageViewController()
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

extension PhotosListViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore
                                viewController: UIViewController) -> UIViewController? {
        guard let beforePage = viewController as? PhotoViewController else { return nil }
        let beforePageIndex = beforePage.photoIndex
        let newIndex = beforePageIndex - 1
        if newIndex < 0 { return nil }
        return getPageFor(index: newIndex)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let afterPage = viewController as? PhotoViewController else { return nil }
        let afterPageIndex = afterPage.photoIndex
        let newIndex = afterPageIndex + 1
        if newIndex < 0 { return nil }
        
        if (newIndex+1) > viewModel.photos.count {
            viewModel.loadNextPage()
        }
        return getPageFor(index: newIndex)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let controller = pageViewController.viewControllers?.first as? PhotoViewController else { return }
        
        currentIndex = controller.photoIndex
    }
    
    func setupPageViewController() {
        self.pageViewController.dataSource = self
        self.pageViewController.delegate = self
        self.pageViewController.view.frame = .zero
        
        setCurrentPage()
        self.addChild(self.pageViewController)
        
        self.pageControllerHolderView.addSubview(self.pageViewController.view)
        self.pageViewController.didMove(toParent: self)
        
        self.pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        self.pageViewController.view.topAnchor.constraint(equalTo: self.pageControllerHolderView.topAnchor).isActive = true
        self.pageViewController.view.leftAnchor.constraint(equalTo: self.pageControllerHolderView.leftAnchor).isActive = true
        self.pageViewController.view.bottomAnchor.constraint(equalTo: self.pageControllerHolderView.bottomAnchor).isActive = true
        self.pageViewController.view.rightAnchor.constraint(equalTo: self.pageControllerHolderView.rightAnchor).isActive = true
    }
    
    func getPageFor(index: Int) -> PhotoViewController? {
        let storyboard = UIStoryboard(name: String(describing: PhotoViewController.self),
                                      bundle: nil)
        
        guard  let controller  = storyboard.instantiateInitialViewController() as? PhotoViewController else { return nil }
        controller.viewModel = .init(photo: viewModel.photos[safe: index])
        controller.photoIndex = index
        return controller
    }
    
    func setCurrentPage() {
        let pageController = getPageFor(index: currentIndex)
        guard let initialPageController = pageController else { return }
        self.pageViewController.setViewControllers([initialPageController], direction: .forward, animated: false, completion: nil)
    }
}
