//
//  FeedViewModel.swift
//  EssentialFeediOS
//
//  Created by Galih Samudra on 05/06/23.
//
import EssentialFeed

final class FeedViewModel {
    private let feedLoader: FeedLoader?
    var onLoadingStateChange: ( (Bool) -> Void )?
    var onFeedLoad: (([FeedImage]) -> Void)?
    
    init(feedLoader: FeedLoader? = nil) {
        self.feedLoader = feedLoader
    }
    
    func loadFeed() {
        onLoadingStateChange?(true)
        feedLoader?.load(completion: { [weak self] result in
            if let feed = try? result.get() {
                self?.onFeedLoad?(feed)
            }
            self?.onLoadingStateChange?(false)
        })
    }
}
