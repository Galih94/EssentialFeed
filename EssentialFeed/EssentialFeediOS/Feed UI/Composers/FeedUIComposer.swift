//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Galih Samudra on 02/06/23.
//
import UIKit
import EssentialFeed

public final class FeedUIComposer {
    private init() {}
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageLoader) -> FeedViewController {
        let presenter = FeedPresenter()
        let presentationAdapter = FeedLoaderPresentationAdapter(feedLoader: feedLoader, presenter: presenter)
        let refreshController = FeedRefreshViewController(delegate: presentationAdapter)
        let feedController = FeedViewController(refreshController: refreshController)
        presenter.feedView = FeedViewAdapter(controller: feedController, imageLoader: imageLoader)
        presenter.loadingView = WeakRefVirtualProxy(refreshController)
        
        return feedController
    }
    
    
}

private final class WeakRefVirtualProxy<T: AnyObject> {
    private weak var object: T?
    init(_ object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: FeedLoadingView where T: FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel) {
        object?.display(viewModel)
    }
}

private final class FeedViewAdapter: FeedView {
    private weak var controller: FeedViewController?
    private let imageLoader: FeedImageLoader
    
    init(controller: FeedViewController, imageLoader: FeedImageLoader) {
        self.controller = controller
        self.imageLoader = imageLoader
    }
    
    
    func display(_ viewModel: FeedViewModel) {
        controller?.tableModel = viewModel.feed.map { model in
            FeedImageCellController(viewModel: FeedImageViewModel(model: model, imageLoader: imageLoader, imageTransformer: UIImage.init))
        }
    }
}

private final class FeedLoaderPresentationAdapter: FeedRefreshViewControllerDelegate {
    private let feedLoader: FeedLoader
    private let presenter: FeedPresenter
    
    init(feedLoader: FeedLoader, presenter: FeedPresenter) {
        self.feedLoader = feedLoader
        self.presenter = presenter
    }
    
    func didRequestFeedRefresh() {
        presenter.didStartLoadingFeed()
        
        feedLoader.load { [weak self] result in
            switch result {
            case let .success(feed):
                self?.presenter.didFinishLoadingFeed(with: feed)
            case let .failure(error):
                self?.presenter.didFinishLoading(with: error)
            }
        }
    }
}

