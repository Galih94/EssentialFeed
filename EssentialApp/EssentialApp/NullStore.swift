//
//  NullStore.swift
//  EssentialApp
//
//  Created by Galih Samudra on 21/07/23.
//

import Foundation
import EssentialFeed

class NullStore: FeedStore & FeedImageDataStore {
    func insert(_ feed: [EssentialFeed.LocalFeedImage], timeStamp: Date, completion: @escaping InsertionCompletion) {
        completion(.success(()))
    }
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        completion(.success(()))
    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.success(.none))
    }
    
    func insert(_ data: Data, for url: URL) throws {}
    
    func retrieve(dataForURL url: URL) throws -> Data? { return .none }
    
}
