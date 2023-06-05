//
//  FeedViewModel.swift
//  EssentialFeediOS
//
//  Created by Galih Samudra on 05/06/23.
//
import EssentialFeed

final class FeedViewModel {
    private enum State {
        case pending
        case loading
        case loaded([FeedImage])
        case failed
    }
    private let feedLoader: FeedLoader?
    var onChange: ( (FeedViewModel) -> Void )?
    private var state = State.pending {
        didSet { onChange?(self) }
    }
    var isLoading: Bool {
        switch state {
        case .loading:
            return true
        case .loaded, .pending, .failed:
            return false
        }
    }
    var feed: [FeedImage]? {
        switch state {
        case .loading, .pending, .failed:
            return nil
        case let .loaded(feed):
            return feed
        }
    }
    
    
    init(feedLoader: FeedLoader? = nil) {
        self.feedLoader = feedLoader
    }
    
    func loadFeed() {
        state = .loading
        feedLoader?.load(completion: { [weak self] result in
            if let feed = try? result.get() {
                self?.state = .loaded(feed)
            } else {
                self?.state = .failed
            }
        })
    }
}
