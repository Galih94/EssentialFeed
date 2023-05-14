//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Galih Samudra on 14/05/23.
//

import Foundation



public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    
    func insert(_ items: [FeedItem], timeStamp: Date, completion: @escaping InsertionCompletion)
    func deleteCachedCompletion(completion: @escaping DeletionCompletion)
}

public final class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func save(items: [FeedItem], completion: @escaping (Error?) -> Void) {
        store.deleteCachedCompletion { [weak self] error in
            guard let self = self else { return }
            if let cacheDeletionError = error {
                completion(cacheDeletionError )
            } else {
                self.cache(items: items, completion: completion)
            }
        }
    }
    
    private func cache(items: [FeedItem], completion: @escaping (Error?) -> Void) {
        store.insert(items, timeStamp: currentDate(), completion:  { [weak self] error in
            guard let _ = self else { return }
            completion(error)
        })
    }
}
