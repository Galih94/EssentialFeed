//
//  InMemoryStore.swift
//  EssentialAppTests
//
//  Created by Galih Samudra on 24/06/23.
//

import EssentialFeed

class InMemoryStore {
    private(set) var feedCache: CachedFeed?
    private var feedImageDataCache: [URL: Data] = [:]
    
    private init(feedCache: CachedFeed? = nil) {
        self.feedCache = feedCache
    }
}

extension InMemoryStore: FeedStore {
    
    func deleteCachedFeed(completion: @escaping FeedStore.DeletionCompletion) {
        feedCache = nil
        completion(.success(()))
    }
    
    func insert(_ feed: [LocalFeedImage], timeStamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
        feedCache = CachedFeed(feed: feed, timeStamp: timeStamp)
        completion(.success(()))
    }
    
    func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        completion(.success(feedCache))
    }
    
}

extension InMemoryStore: FeedImageDataStore {
    func insert(_ data: Data, for url: URL) throws {
        feedImageDataCache[url] = data
    }
    
    func retrieve(dataForURL url: URL) throws -> Data? {
        return feedImageDataCache[url]
    }
}

extension InMemoryStore {
    
    static var empty: InMemoryStore {
        return InMemoryStore()
    }
    
    static var withExpiredFeedCache: InMemoryStore {
        return InMemoryStore(feedCache: CachedFeed(feed: [], timeStamp: Date.distantPast))
    }
    
    static var withNonExpiredFeedCache: InMemoryStore {
        return InMemoryStore(feedCache: CachedFeed(feed: [], timeStamp: Date()))
    }
    
}
