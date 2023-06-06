//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by Galih Samudra on 06/06/23.
//
import EssentialFeed

struct FeedLoadingViewModel {
    let isLoading: Bool
}

struct FeedViewModel {
    let feed: [FeedImage]
}

protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}

final class FeedPresenter {
    typealias Observer<T> = (T) -> Void
    private let feedLoader: FeedLoader?
    var feedView: FeedView?
    var loadingView: FeedLoadingView?
    
    init(feedLoader: FeedLoader? = nil) {
        self.feedLoader = feedLoader
    }
    
    func loadFeed() {
        loadingView?.display(FeedLoadingViewModel(isLoading: true))
        feedLoader?.load(completion: { [weak self] result in
            if let feed = try? result.get() {
                self?.feedView?.display(FeedViewModel(feed: feed))
            }
            self?.loadingView?.display(FeedLoadingViewModel(isLoading: false))
        })
    }
}
