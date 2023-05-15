//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Galih Samudra on 14/05/23.
//

import Foundation

public final class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date
    public typealias SaveResult = Error?
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func load(completion: @escaping (Error?) -> Void) {
         
        store.retrieve(completion: completion)
    }
    
    public func save(_ feed : [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedCompletion { [weak self] error in
            guard let self = self else { return }
            if let cacheDeletionError = error {
                completion(cacheDeletionError )
            } else {
                self.cache(feed, completion: completion)
            }
        }
    }
    
    private func cache(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.insert(feed.toLocalFeedItem(), timeStamp: currentDate(), completion:  { [weak self] error in
            guard let _ = self else { return }
            completion(error)
        })
    }
}

private extension Array where Element == FeedImage {
    func toLocalFeedItem() -> [LocalFeedImage] {
        return map{ LocalFeedImage(id: $0.id,
                                  description: $0.description,
                                  location: $0.location,
                                  url: $0.url) }
    }
}
