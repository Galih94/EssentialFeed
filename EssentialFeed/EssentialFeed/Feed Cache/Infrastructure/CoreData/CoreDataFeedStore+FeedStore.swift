//
//  CoreDataFeedStore+FeedStore.swift
//  EssentialFeed
//
//  Created by Galih Samudra on 19/06/23.
//

extension CoreDataFeedStore: FeedStore {
    public func insert(_ feed: [EssentialFeed.LocalFeedImage], timeStamp: Date, completion: @escaping InsertionCompletion) {
        performAsync { context in
            completion(Result {
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.timeStamp = timeStamp
                managedCache.feed = ManagedFeedImage.image(from: feed, in: context)
                
                try context.save()
            })
        }
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        performAsync { context in
            completion(Result {
                try ManagedCache.find(in: context).map( context.delete(_:) ).map( context.save )
            })
        }
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        performAsync { context in
            completion(Result {
                try ManagedCache.find(in: context).map {
                    CachedFeed(feed: $0.localFeed, timeStamp: $0.timeStamp)
                }
            })
        }
    }
}
