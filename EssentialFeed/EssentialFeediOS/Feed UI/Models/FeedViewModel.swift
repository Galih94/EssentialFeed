//
//  FeedViewModel.swift
//  EssentialFeediOS
//
//  Created by Galih Samudra on 05/06/23.
//
import EssentialFeed

final class FeedViewModel {
    private let feedLoader: FeedLoader?
    var onChange: ( (FeedViewModel) -> Void )?
    var onFeedLoad: (([FeedImage]) -> Void)?
    var isLoading: Bool = false {
        didSet {
            onChange?(self)
        }
    }
    
    init(feedLoader: FeedLoader? = nil) {
        self.feedLoader = feedLoader
    }
    
    func loadFeed() {
        isLoading = true
        feedLoader?.load(completion: { [weak self] result in
            if let feed = try? result.get() {
                self?.onFeedLoad?(feed)
            }
            self?.isLoading = false
        })
    }
}
