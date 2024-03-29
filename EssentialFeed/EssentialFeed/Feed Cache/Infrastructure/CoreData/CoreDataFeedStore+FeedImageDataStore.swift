//
//  CoreDataFeedStore+FeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Galih Samudra on 19/06/23.
//

extension CoreDataFeedStore: FeedImageDataStore {
    public func insert(_ data: Data, for url: URL) throws {
        try performSync(action: { context in
            Result {
                try ManagedFeedImage.first(with: url, in: context)
                    .map { $0.data = data }
                    .map ( context.save )
            }
        })
    }
    
    public func retrieve(dataForURL url: URL) throws -> Data? {
        try performSync(action: { context in
            Result {
                try ManagedFeedImage.data(with: url, in: context)
            }
        })
    }
}

