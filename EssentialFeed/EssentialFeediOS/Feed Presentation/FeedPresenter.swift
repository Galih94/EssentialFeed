//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by Galih Samudra on 06/06/23.
//
import EssentialFeed

protocol FeedView {
    func display(feed: [FeedImage])
}

protocol FeedLoadingView {
    func display(isLoading: Bool)
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
        loadingView?.display(isLoading: true)
        feedLoader?.load(completion: { [weak self] result in
            if let feed = try? result.get() {
                self?.feedView?.display(feed: feed)
            }
            self?.loadingView?.display(isLoading: false)
        })
    }
}
