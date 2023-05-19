//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Galih Samudra on 19/05/23.
//

import Foundation
import CoreData

public final class CoreDataFeedStore: FeedStore {
    public init() {}
    
    public func insert(_ feed: [EssentialFeed.LocalFeedImage], timeStamp: Date, completion: @escaping InsertionCompletion) {
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.empty)
    }
    
}
